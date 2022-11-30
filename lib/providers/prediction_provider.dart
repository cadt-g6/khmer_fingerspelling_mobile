import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/services/messenger_service.dart';
import 'package:khmer_fingerspelling_flutter/tflite/image_classification.dart';
import 'package:khmer_fingerspelling_flutter/tflite/image_utils.dart';
import 'package:khmer_fingerspelling_flutter/tflite/predicted_position.dart';
import 'package:logger/logger.dart';

class PredictionCombinedModel {
  final File image;
  final PredictedPosition position;
  final ImageClassifierResult classifierResult;
  final List<ImageClassifierResult> posibilities;

  PredictionCombinedModel(
    this.image,
    this.position,
    this.classifierResult,
    this.posibilities,
  );
}

enum PredictionState {
  none,
  cropping,
  predicting,
  predicted,
}

class PredictionProvider extends ChangeNotifier {
  late final ValueNotifier<PredictionState> stateNotifier;
  static final PredictionProvider instance = PredictionProvider._();

  List<String> baseUrls = ['http://127.0.0.1:5001', 'https://khmer-fingerspelling.herokuapp.com'];
  String get baseUrl => _baseUrl ?? baseUrls.last;
  String? _baseUrl;

  set baseUrl(String value) {
    _baseUrl = value;
    notifyListeners();
  }

  PredictionProvider._() {
    stateNotifier = ValueNotifier<PredictionState>(PredictionState.none);
  }

  @override
  void dispose() {
    stateNotifier.dispose();
    super.dispose();
  }

  void clearPrediction() {
    stateNotifier.value = PredictionState.none;
    if (_currentPrediction == null) return;

    _currentPrediction = null;
    notifyListeners();
  }

  PredictionCombinedModel? _currentPrediction;
  PredictionCombinedModel? get currentPrediction => _currentPrediction;
  List<ImageClassifierResult>? currentPredictedClassifications = [];

  Future<dynamic> predict({
    required File image,
    required Size imageSize,
    required PredictedPosition cropPosition,
  }) async {
    stateNotifier.value = PredictionState.cropping;
    List<double> sizes = [];

    double orgImageSize = image.lengthSync() / (1024 * 1024);
    sizes.add(orgImageSize);

    File? file = await ImageUtils().cropImage(
      image,
      imageSize,
      cropPosition,
    );

    double cropSize = (file?.lengthSync() ?? 0) / (1024 * 1024);
    sizes.add(cropSize);

    if (file != null) {
      final resizedFile = await ImageUtils()
          .resizeImage(file, Size(cropPosition.w * imageSize.width, cropPosition.h * imageSize.height));
      if (resizedFile != null) {
        double resizedSize = file.lengthSync() / (1024 * 1024);
        if (cropSize > resizedSize) {
          file = resizedFile;
          sizes.add(resizedSize);
        }
      }
    }

    if (kDebugMode) {
      print("PredictionProvider#predict:");
      print("Image size to send: ${sizes.join(", ")}");
    }

    if (file != null) {
      stateNotifier.value = PredictionState.predicting;

      List<ImageClassifierResult>? classifierResults;
      try {
        classifierResults = await ImageClassifier().predict(file);
      } catch (error) {
        MessengerService.instance.showSnackBar("Predict fail $error!", success: false);
        Logger().e(error);
      }

      final ImageClassifierResult? prediction = classifierResults?.isNotEmpty == true ? classifierResults?.first : null;
      if (prediction == null) {
        stateNotifier.value = PredictionState.none;
        return;
      }

      _currentPrediction = PredictionCombinedModel(file, cropPosition, prediction, classifierResults!);
      stateNotifier.value = PredictionState.predicted;
    } else {
      _currentPrediction = null;
      stateNotifier.value = PredictionState.none;
    }

    notifyListeners();
  }
}
