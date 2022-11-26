import 'dart:io';

import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/base/base_view_model.dart';

class HomeViewModel extends BaseViewModel {
  late final ValueNotifier<bool> showImageSelector;

  File? currentImage;
  Size? currentImageAspectRatio;

  HomeViewModel() {
    showImageSelector = ValueNotifier(false);
  }

  void setImage(
    File? image,
    Size? imageAspectRatio,
  ) {
    if (currentImage?.path == image?.path) return;

    currentImage = image;
    currentImageAspectRatio = imageAspectRatio;
    notifyListeners();
  }

  Future<void> predict() async {}
}
