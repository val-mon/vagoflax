import 'dart:io';

import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
// ignore: implementation_imports
import 'package:cloudinary_api/src/request/model/uploader_params.dart';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

var cloudinary = Cloudinary.fromStringUrl(
  'cloudinary://${dotenv.get('CLOUDINARY_APIKEY')}:${dotenv.get('CLOUDINARY_APISECRET')}@${dotenv.get('CLOUDINARY_CLOUDNAME')}',
);

class CloudinaryService {
  void main() async {
    cloudinary.config.urlConfig.secure =
        true; // the sdk will generate https urls for your images
  }

  // sends image to cloudinary and returns secure url of the uploaded image
  static Future<String?> uploadProfilePicture(
    File imageFile,
    String userId,
  ) async {
    try {
      var response = await cloudinary.uploader().upload(
        imageFile,
        params: UploadParams(
          publicId: userId,
          uniqueFilename: true,
          overwrite: true,
        ),
      );

      if (response?.error != null) {
        SnackBar(content: Text("Cloudinary upload error: ${response?.error}"));
        return null;
      }

      return response?.data?.secureUrl;
    } catch (e) {
      SnackBar(content: Text("Cloudinary upload error: ${e.toString()}"));
      return null;
    }
  }
}
