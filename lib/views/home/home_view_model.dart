import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/base/base_view_model.dart';
import 'package:khmer_fingerspelling_flutter/core/constants/config_constant.dart';
import 'package:khmer_fingerspelling_flutter/core/services/messenger_service.dart';
import 'package:khmer_fingerspelling_flutter/core/theme/theme_config.dart';
import 'package:khmer_fingerspelling_flutter/tflite/image_utils.dart';
import 'package:khmer_fingerspelling_flutter/tflite/predicted_position.dart';
import 'package:khmer_fingerspelling_flutter/tflite/tflite_models.dart';
import 'package:khmer_fingerspelling_flutter/views/home/local_widgets/predicted_dialog.dart';

class HomeViewModel extends BaseViewModel {
  late final ValueNotifier<bool> showImageSelector;
  late final ValueNotifier<int?> predictionIndexNotifier;

  List<PredictedPosition> get predictedPositions => _predictedPositions;
  Size? get currentImageSize => _currentImageSize;
  File? get currentImage => _currentImage;
  Size? get currentImageAspectRatio {
    if (currentImageSize == null) return null;
    return Size(
      currentImageSize!.width / min(currentImageSize!.width, currentImageSize!.height),
      currentImageSize!.height / min(currentImageSize!.width, currentImageSize!.height),
    );
  }

  File? _currentImage;
  Size? _currentImageSize;
  List<PredictedPosition> _predictedPositions = [];

  HomeViewModel() {
    showImageSelector = ValueNotifier(false);
    predictionIndexNotifier = ValueNotifier(null);
    TfliteModels.handTrackingModel.load();

    predictionIndexNotifier.addListener(() {
      updateCurrentPosition(null);
    });
  }

  @override
  void dispose() {
    showImageSelector.dispose();
    predictionIndexNotifier.dispose();
    TfliteModels.handTrackingModel.close();
    super.dispose();
  }

  void setImage(File? image, Size? imageSize) {
    if (currentImage?.path == image?.path) return;
    _currentImage = image;
    _currentImageSize = imageSize;
    _predictedPositions = [];
    predictionIndexNotifier.value = null;
    notifyListeners();
  }

  Future<void> predict() async {
    if (_currentImage == null) return;

    List<PredictedPosition>? result = await TfliteModels.handTrackingModel.filePredict(_currentImage!);
    _predictedPositions = result ?? [];
    notifyListeners();

    Future.delayed(ConfigConstant.duration).then((value) {
      predictionIndexNotifier.value = result?.isNotEmpty == true ? 0 : null;
    });
  }

  PredictedPosition? _currentPosition;
  void updateCurrentPosition(PredictedPosition? position) {
    _currentPosition = position;
  }

  Future<void> showPredictInfo(
    BuildContext context,
    PredictedPosition position,
  ) async {
    bool isApple = ThemeConfig.config.isApple(Theme.of(context).platform);
    File? croppedFile = await MessengerService.instance.showLoading(
      future: () async {
        return ImageUtils().cropImage(
          currentImage!,
          currentImageSize!,
          _currentPosition ?? position,
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
          );
        },
      );
    }

    croppedFile.delete();
  }

  Size findRelativeImageWidthHeight(BoxConstraints constraints, Size imageSize) {
    double width = constraints.maxWidth;
    double height = constraints.maxHeight;

    if (constraints.maxHeight > constraints.maxWidth) {
      // w:1000 - w:500
      // h:300  - h:x
      height = constraints.maxWidth * imageSize.height / imageSize.width;
    } else {
      // w:1000 - w:x
      // h:300  - h:100
      width = imageSize.width * constraints.maxHeight / imageSize.height;
    }

    return Size(width, height);
  }
}
