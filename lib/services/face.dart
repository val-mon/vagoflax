import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart' show rootBundle;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceRecognitionService {
  FaceRecognitionService._();
  static final FaceRecognitionService instance = FaceRecognitionService._();

  static const _modelAsset = 'assets/model/mobile_face_net.tflite';
  static const _inputSize = 112;
  static const _outputSize = 192;
  static const _workingMargin = 1.6;
  static const _cropMargin = 1.25;

  final _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: true,
    ),
  );

  Interpreter? _interpreter;

  Future<void> _ensureModelLoaded() async {
    if (_interpreter != null) return;
    final buffer = await rootBundle.load(_modelAsset);
    _interpreter = Interpreter.fromBuffer(buffer.buffer.asUint8List());
  }

  /// Detects the (biggest) face in [imageFile] and returns its signature
  Future<List<double>?> getFaceSignature(File imageFile) async {
    await _ensureModelLoaded();

    final inputImage = InputImage.fromFile(imageFile);
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) return null;

    // if several faces appear, keep the biggest (closest to the camera)
    faces.sort(
      (a, b) => (b.boundingBox.width * b.boundingBox.height).compareTo(
        a.boundingBox.width * a.boundingBox.height,
      ),
    );
    final face = faces.first;

    var decoded = img.decodeImage(await imageFile.readAsBytes());
    if (decoded == null) return null;
    // ML Kit already accounts for the EXIF orientation, the image package does
    // not: bake it in so the bounding box lines up with the pixels we crop.
    decoded = img.bakeOrientation(decoded);

    // the model takes a batch of one image: [1, 112, 112, 3]
    final input = [_preprocess(decoded, face)];

    final output = List.generate(1, (_) => List.filled(_outputSize, 0.0));
    _interpreter!.run(input, output);

    return _l2Normalize(List<double>.from(output[0]));
  }

  /// Scales the embedding to a length of 1 for [distance] to be meaningful.
  List<double> _l2Normalize(List<double> embedding) {
    var sum = 0.0;
    for (final value in embedding) {
      sum += value * value;
    }
    final norm = math.sqrt(sum);
    if (norm == 0) return embedding;
    return embedding.map((value) => value / norm).toList();
  }

  /// Cuts a square of [side] pixels centered on ([cx], [cy])
  img.Image _squareCrop(img.Image image, double cx, double cy, double side) {
    final size = side
        .round()
        .clamp(1, math.min(image.width, image.height))
        .toInt();
    final x = (cx - size / 2).round().clamp(0, image.width - size).toInt();
    final y = (cy - size / 2).round().clamp(0, image.height - size).toInt();

    return img.copyCrop(image, x: x, y: y, width: size, height: size);
  }

  /// Crops the face, straightens it, resizes it and normalizes pixels.
  List _preprocess(img.Image image, Face face) {
    final box = face.boundingBox;
    final faceSize = math.max(box.width, box.height);

    // Generous square first, so rotating it doesn't pull in empty corners
    final working = _squareCrop(
      image,
      box.center.dx,
      box.center.dy,
      faceSize * _workingMargin,
    );

    // headEulerAngleZ is the roll in degrees, same unit as copyRotate
    final rotated = img.copyRotate(
      working,
      angle: -(face.headEulerAngleZ ?? 0),
    );

    // then the actual crop, centered on the straightened patch
    final cropped = _squareCrop(
      rotated,
      rotated.width / 2,
      rotated.height / 2,
      faceSize * _cropMargin,
    );
    final resized = img.copyResize(
      cropped,
      width: _inputSize,
      height: _inputSize,
    );

    return List.generate(
      _inputSize,
      (y) => List.generate(_inputSize, (x) {
        final pixel = resized.getPixel(x, y);
        return [
          (pixel.r - 127.5) / 127.5,
          (pixel.g - 127.5) / 127.5,
          (pixel.b - 127.5) / 127.5,
        ];
      }),
    );
  }

  /// Euclidean distance between two signatures —> lower means more similar
  double distance(List<double> a, List<double> b) {
    if (a.length != b.length) return double.infinity;
    double sum = 0;
    for (var i = 0; i < a.length; i++) {
      final diff = a[i] - b[i];
      sum += diff * diff;
    }
    return sum <= 0 ? 0 : math.sqrt(sum);
  }

  /// Returns the user in [users] whose signature is closest to [signature]
  T? findClosestMatch<T>(
    List<double> signature,
    List<T> users,
    List<double> Function(T user) signatureOf, {
    double threshold = 0.95,
  }) {
    T? best;
    var bestDistance = double.infinity;

    for (final user in users) {
      final known = signatureOf(user);
      if (known.isEmpty) continue; // user with no face registered
      final d = distance(signature, known);
      // print('Distance to ${user.toString()}: $d');
      if (d < bestDistance) {
        bestDistance = d;
        best = user;
      }
    }

    return bestDistance <= threshold ? best : null;
  }

  void dispose() {
    _faceDetector.close();
    _interpreter?.close();
  }
}
