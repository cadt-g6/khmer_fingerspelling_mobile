import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:khmer_fingerspelling_flutter/core/services/messenger_service.dart';
import 'package:khmer_fingerspelling_flutter/core/utils/file_helper.dart';
import 'package:khmer_fingerspelling_flutter/tflite/predicted_position.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class ImageUtils {
  Future<File?> cropImage(
    File imageFile,
    Size imageSize,
    PredictedPosition position,
  ) async {
    String filename = DateTime.now().toIso8601String();
    List<int>? cropBytes = await compute(_getCropBytes, {
      'imageFile': imageFile,
      'imageSize': imageSize,
      'position': position,
    });

    if (cropBytes == null) {
      MessengerService.instance.showSnackBar("Crop image failed!");
      return null;
    }

    File croppedFile = await FileHelper.helper.writeToFile(
      filename,
      cropBytes,
      FileParentType.other,
    );

    return croppedFile;
  }
}

List<int>? _getCropBytes(Map<String, dynamic> args) {
  File imageFile = args['imageFile'];
  Size imageSize = args['imageSize'];
  PredictedPosition position = args['position'];

  List<int> bytes = imageFile.readAsBytesSync();
  img.Image? image = img.decodeImage(bytes);
  if (image == null) return null;

  PredictedPosition cropPosition = PredictedPosition.withParams(
    x: position.x * imageSize.width,
    y: position.y * imageSize.height,
    w: position.w * imageSize.width,
    h: position.h * imageSize.height,
  );

  double add = 150;
  if (add > 0) {
    // in case excede size,
    // by default, img.copyCrop already handle this but not in sqaue size.
    double excedeWidth = (cropPosition.w + add) - imageSize.width;
    double excedeHeight = (cropPosition.h + add) - imageSize.height;
    add = add - max(0, max(excedeWidth, excedeHeight));

    cropPosition = PredictedPosition.withParams(
      x: cropPosition.x - add / 2,
      y: cropPosition.y - add / 2,
      w: cropPosition.w + add,
      h: cropPosition.h + add,
    );
  }

  img.Image cropped = img.copyCrop(
    image,
    cropPosition.x.toInt(),
    cropPosition.y.toInt(),
    cropPosition.w.toInt(),
    cropPosition.h.toInt(),
  );

  String filename = basename(imageFile.path);
  List<int>? cropBytes = img.encodeNamedImage(cropped, filename);
  return cropBytes;
}
