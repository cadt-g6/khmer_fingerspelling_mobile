import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:khmer_fingerspelling_flutter/tflite/predicted_position.dart';
import 'package:tflite/tflite.dart';

class TfliteModels {
  static final handTrackingModel = TfliteModels._(
    'assets/models/hand_tracking_model.tflite',
    'assets/models/hand_tracking_labels.txt',
  );

  TfliteModels._(
    this.modelPath, [
    this.labelPath = '',
  ]);

  final String modelPath;
  final String labelPath;

  bool loaded = false;
  Future<void> load() async {
    if (loaded) return;

    String? status = await Tflite.loadModel(
      model: modelPath,
      labels: labelPath,
      isAsset: true,
      numThreads: 1,
    );

    loaded = status == 'success';
    if (kDebugMode) {
      print("load model status: $loaded");
    }
  }

  Future<List<PredictedPosition>?> filePredict(File image) async {
    return _predict(() async {
      return Tflite.detectObjectOnImage(
        path: image.path,
        imageMean: 128.5,
        imageStd: 128.5,
      );
    });
  }

  Future<List<PredictedPosition>?> _predict(Future<List<dynamic>?> Function() predict) async {
    if (!loaded) await load();

    try {
      final result = await predict();
      result?.sort((a, b) => b['confidenceInClass'] > a['confidenceInClass'] ? 1 : -1);

      return result?.where((detector) {
        double confidenceInClass = detector['confidenceInClass'] ?? 0.0;
        if (result.length > 1) {
          return confidenceInClass > 0.17;
        } else {
          return true;
        }
      }).map((detector) {
        return PredictedPosition(
          detector['rect']['x'],
          detector['rect']['y'],
          detector['rect']['w'],
          detector['rect']['h'],
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) print(e);
      return null;
    }
  }

  Future<void> close() async {
    await Tflite.close();
    loaded = false;
  }
}
