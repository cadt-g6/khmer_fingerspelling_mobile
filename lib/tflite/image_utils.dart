import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:khmer_fingerspelling_flutter/core/services/messenger_service.dart';
import 'package:khmer_fingerspelling_flutter/core/utils/file_helper.dart';
import 'package:khmer_fingerspelling_flutter/tflite/predicted_position.dart';

class ImageUtils {
  Future<File?> cropImage(
    File imageFile,
    Size imageSize,
    PredictedPosition position, {
    double extendSize = 0.0,
  }) async {
    String filename = DateTime.now().toIso8601String();
    List<int>? cropBytes = await compute(_getCropBytes, {
      'imageFile': imageFile,
      'imageSize': imageSize,
      'position': position,
      'extendSize': extendSize,
    });

    if (cropBytes == null) {
      MessengerService.instance.showSnackBar("Crop image failed!", success: false);
      return null;
    }

    File croppedFile = await FileHelper.helper.writeToFile(
      filename,
      cropBytes,
      FileParentType.other,
    );

    return croppedFile;
  }

  Future<File?> resizeImage(
    File imageFile,
    Size imageSize,
  ) async {
    List<int>? resizedByes = await compute(_resizeImageBytes, {
      'imageFile': imageFile,
      'imageSize': imageSize,
    });

    if (resizedByes == null) {
      MessengerService.instance.showSnackBar("Resize image failed!", success: false);
      return null;
    }

    File croppedFile = await FileHelper.helper.writeToFile(
      imageFile.path,
      resizedByes,
      FileParentType.other,
    );

    return croppedFile;
  }
}

List<int>? _resizeImageBytes(Map<String, dynamic> args) {
  File imageFile = args['imageFile'];
  Size imageSize = args['imageSize'];

  List<int> bytes = imageFile.readAsBytesSync();
  img.Image? image = img.decodeImage(bytes);
  if (image == null) return null;
  Size size;

  if (imageSize.width >= imageSize.height) {
    size = Size(240, imageSize.height * 240 / imageSize.width);
  } else {
    size = Size(imageSize.width * 240 / imageSize.height, 240);
  }

  final resized = img.copyResize(
    image,
    width: size.width.toInt(),
    height: size.height.toInt(),
  );

  List<int>? resizedByes = img.encodeJpg(resized);
  return resizedByes;
}

List<int>? _getCropBytes(Map<String, dynamic> args) {
  File imageFile = args['imageFile'];
  Size imageSize = args['imageSize'];
  PredictedPosition position = args['position'];
  double extendSize = args['extendSize'];

  List<int> bytes = imageFile.readAsBytesSync();
  img.Image? image = img.decodeImage(bytes);
  if (image == null) return null;

  PredictedPosition cropPosition = PredictedPosition.withParams(
    x: position.x * imageSize.width,
    y: position.y * imageSize.height,
    w: position.w * imageSize.width,
    h: position.h * imageSize.height,
  );

  if (extendSize > 0) {
    // in case excede size,
    // by default, img.copyCrop already handle this but not in sqaue size.
    double excedeWidth = (cropPosition.w + extendSize) - imageSize.width;
    double excedeHeight = (cropPosition.h + extendSize) - imageSize.height;
    extendSize = extendSize - max(0, max(excedeWidth, excedeHeight));

    cropPosition = PredictedPosition.withParams(
      x: cropPosition.x - extendSize / 2,
      y: cropPosition.y - extendSize / 2,
      w: cropPosition.w + extendSize,
      h: cropPosition.h + extendSize,
    );
  }

  img.Image cropped = img.copyCrop(
    image,
    cropPosition.x.toInt(),
    cropPosition.y.toInt(),
    cropPosition.w.toInt(),
    cropPosition.h.toInt(),
  );

  List<int>? cropBytes = img.encodeJpg(cropped);
  return cropBytes;
}
