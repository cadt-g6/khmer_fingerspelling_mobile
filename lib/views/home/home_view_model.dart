import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/base/base_view_model.dart';
import 'package:khmer_fingerspelling_flutter/core/services/messenger_service.dart';
import 'package:khmer_fingerspelling_flutter/core/theme/theme_config.dart';
import 'package:khmer_fingerspelling_flutter/tflite/image_utils.dart';
import 'package:khmer_fingerspelling_flutter/tflite/predicted_position.dart';
import 'package:khmer_fingerspelling_flutter/tflite/tflite_models.dart';
import 'package:khmer_fingerspelling_flutter/views/home/local_widgets/predicted_dialog.dart';

class HomeViewModel extends BaseViewModel {
  late final ValueNotifier<bool> showImageSelector;

  File? get currentImage => _currentImage;
  Size? get currentImageSize => _currentImageSize;
  Size? get currentImageAspectRatio {
    if (currentImageSize == null) return null;
    return Size(
      currentImageSize!.width / min(currentImageSize!.width, currentImageSize!.height),
      currentImageSize!.height / min(currentImageSize!.width, currentImageSize!.height),
    );
  }

  List<PredictedPosition> get predictedPositions => _predictedPositions;

  File? _currentImage;
  Size? _currentImageSize;
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

  void setImage(File? image, Size? imageSize) {
    if (currentImage?.path == image?.path) return;
    _currentImage = image;
    _currentImageSize = imageSize;
    _predictedPositions = [];
    notifyListeners();
  }

  Future<void> predict() async {
    if (_currentImage == null) return;

    List<PredictedPosition>? result = await TfliteModels.handTrackingModel.filePredict(_currentImage!);
    _predictedPositions = result ?? [];
    notifyListeners();
  }

  Future<void> showPredictInfo(
    BuildContext context,
    PredictedPosition position,
    PredictedPosition relativePosition,
  ) async {
    bool isApple = ThemeConfig.config.isApple(Theme.of(context).platform);
    File? croppedFile = await MessengerService.instance.showLoading(
      future: () async {
        return ImageUtils().cropImage(
          currentImage!,
          currentImageSize!,
          position,
        );
      },
      context: context,
      debugSource: "HomeMobile#buildRect",
    );

    if (croppedFile == null) return;
    if (isApple) {
      await showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return PredictedDialog(
            position: position,
            image: croppedFile,
            relativePosition: relativePosition,
          );
        },
      );
    } else {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return PredictedDialog(
            position: position,
            image: croppedFile,
            relativePosition: relativePosition,
          );
        },
      );
    }

    croppedFile.delete();
  }
}
