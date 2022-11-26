import 'dart:io';

import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/base/base_view_model.dart';
import 'package:khmer_fingerspelling_flutter/tflite/predicted_position.dart';
import 'package:khmer_fingerspelling_flutter/tflite/tflite_models.dart';

class HomeViewModel extends BaseViewModel {
  late final ValueNotifier<bool> showImageSelector;

  File? get currentImage => _currentImage;
  Size? get currentImageAspectRatio => _currentImageAspectRatio;
  List<PredictedPosition> get predictedPositions => _predictedPositions;

  File? _currentImage;
  Size? _currentImageAspectRatio;
  List<PredictedPosition> _predictedPositions = [];

  HomeViewModel() {
    showImageSelector = ValueNotifier(false);
    TfliteModels.handTrackingModel.load();
  }

  @override
  void dispose() {
    showImageSelector.dispose();
    TfliteModels.handTrackingModel.close();
    super.dispose();
  }

  void setImage(File? image, Size? imageAspectRatio) {
    if (currentImage?.path == image?.path) return;
    _currentImage = image;
    _currentImageAspectRatio = imageAspectRatio;
    _predictedPositions = [];
    notifyListeners();
  }

  Future<void> predict() async {
    if (_currentImage == null) return;

    List<PredictedPosition>? result = await TfliteModels.handTrackingModel.filePredict(_currentImage!);
    _predictedPositions = result ?? [];
    notifyListeners();
  }
}
