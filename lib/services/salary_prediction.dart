import 'package:flutter_litert/flutter_litert.dart';
import 'package:vagoflax/models/salary_prediction_model.dart';

import 'salary_preprocessor.dart';

class SalaryPredictionService {
  static const String _modelAssetPath = 'assets/ml/model.tflite';

  final SalaryPreprocessor _preprocessor;

  Interpreter? _interpreter;

  SalaryPredictionService({SalaryPreprocessor? preprocessor})
    : _preprocessor = preprocessor ?? SalaryPreprocessor();

  bool get isInitialized => _interpreter != null && _preprocessor.isInitialized;

  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }

    await _preprocessor.initialize();

    _interpreter = await Interpreter.fromAsset(_modelAssetPath);

    _validateModel();
  }

  Future<double> predict(SalaryPredictionInput input) async {
    if (!isInitialized) {
      await initialize();
    }

    final interpreter = _interpreter;

    if (interpreter == null) {
      throw StateError('Salary prediction model is not initialized.');
    }

    final features = _preprocessor.transform(input);
    final modelInput = [features];
    final modelOutput = [
      [0.0],
    ];

    interpreter.run(modelInput, modelOutput);

    final normalizedSalary = modelOutput[0][0];
    final predictedSalary = _preprocessor.denormalizeTarget(normalizedSalary);

    if (!predictedSalary.isFinite) {
      throw StateError('The model returned an invalid salary prediction.');
    }

    return predictedSalary;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }

  void _validateModel() {
    final interpreter = _interpreter;

    if (interpreter == null) {
      throw StateError('Salary prediction model is not initialized.');
    }

    final inputTensor = interpreter.getInputTensor(0);
    final outputTensor = interpreter.getOutputTensor(0);

    final inputShape = inputTensor.shape;
    final outputShape = outputTensor.shape;

    if (inputShape.length != 2) {
      throw StateError('Expected a 2D model input, got $inputShape.');
    }

    if (inputShape[0] != 1) {
      throw StateError('Expected model batch size 1, got $inputShape.');
    }

    if (inputShape[1] != _preprocessor.inputDimension) {
      throw StateError(
        'Model expects ${inputShape[1]} features, but preprocessing produces ${_preprocessor.inputDimension}.',
      );
    }

    if (outputShape.length != 2 || outputShape[0] != 1 || outputShape[1] != 1) {
      throw StateError('Expected model output shape [1, 1], got $outputShape.');
    }
  }
}
