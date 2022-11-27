import 'dart:io';
import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/tflite/predicted_position.dart';
import 'package:khmer_fingerspelling_flutter/views/home/detector_rect.dart';
import 'package:khmer_fingerspelling_flutter/views/home/home_view_model.dart';
import 'package:khmer_fingerspelling_flutter/views/home/local_widgets/detector_dot.dart';
import 'package:khmer_fingerspelling_flutter/views/home/local_widgets/empty_widget.dart';
import 'package:khmer_fingerspelling_flutter/views/home/local_widgets/home_app_bar.dart';
import 'package:khmer_fingerspelling_flutter/views/home/local_widgets/image_selector.dart';
import 'package:khmer_fingerspelling_flutter/views/home/local_widgets/predictation_tile.dart';

class HomeMobile extends StatelessWidget {
  const HomeMobile({
    super.key,
    required this.viewModel,
  });

  final HomeViewModel viewModel;
  bool get hasImage => viewModel.currentImage != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: buildAppBar(context),
      drawer: const Drawer(),
      body: Stack(
        children: [
          buildEmpty(),
          if (hasImage) buildBody(viewModel.currentImage!),
          buildImageSelector(),
          PredictationTile(viewModel: viewModel),
        ],
      ),
    );
  }

  Widget buildEmpty() {
    return EmptyWidget(onPressed: () {
      viewModel.showImageSelector.value = !viewModel.showImageSelector.value;
    });
  }

  Widget buildBody(File image) {
    List<PredictedPosition> positions = [...viewModel.predictedPositions];
    positions.sort((a, b) => b.w * b.h > a.w * a.h ? 1 : -1);

    return LayoutBuilder(
      builder: (context, constraints) {
        Size? relativeImageSize = viewModel.findRelativeImageWidthHeight(
          constraints,
          viewModel.currentImageSize!,
        );
        return Center(
          child: SizedBox(
            width: relativeImageSize.width,
            height: relativeImageSize.height,
            child: Stack(
              children: [
                Image.file(
                  image,
                  width: relativeImageSize.width,
                  height: relativeImageSize.height,
                  fit: relativeImageSize.height > relativeImageSize.width ? BoxFit.fitHeight : BoxFit.fitWidth,
                ),
                for (int index = 0; index < positions.length; index++)
                  buildDetectorDot(
                    relativeImageSize,
                    positions,
                    index,
                  ),
                buildDetectorRect(
                  positions,
                  relativeImageSize,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildDetectorRect(
    List<PredictedPosition> positions,
    Size relativeImageSize,
  ) {
    return ValueListenableBuilder<int?>(
      valueListenable: viewModel.predictionIndexNotifier,
      builder: (context, index, child) {
        if (index == null) return const SizedBox.shrink();
        return DetectorRect(
          key: ValueKey(index),
          position: viewModel.predictedPositions[index],
          relativeImageSize: relativeImageSize,
          onLongPress: () => viewModel.predictionIndexNotifier.value = null,
          onPositionUpdate: (position) => viewModel.updateCurrentPosition(position),
          onTap: (position) {
            viewModel.showPredictInfo(context, position);
          },
        );
      },
    );
  }

  Widget buildDetectorDot(
    Size? relativeImageSize,
    List<PredictedPosition> positions,
    int index,
  ) {
    return DetectorDot(
      parentImageAspectRatio: viewModel.currentImageAspectRatio!,
      parentSize: relativeImageSize!,
      rectPosition: positions[index],
      predictionIndexNotifier: viewModel.predictionIndexNotifier,
      isSelected: () {
        int predictionIndex = viewModel.predictedPositions.indexOf(positions[index]);
        return predictionIndex == viewModel.predictionIndexNotifier.value;
      },
      onTap: (selected) {
        if (selected) {
          viewModel.predictionIndexNotifier.value = null;
        } else {
          int predictionIndex = viewModel.predictedPositions.indexOf(positions[index]);
          viewModel.predictionIndexNotifier.value = predictionIndex;
        }
      },
    );
  }

  Widget buildImageSelector() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ImageSelector(
        showImageSelector: viewModel.showImageSelector,
        onImageSelected: (image, imageAspectRatio) {
          viewModel.setImage(image, imageAspectRatio);
          viewModel.predict();
        },
      ),
    );
  }

  PreferredSize buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: HomeAppBar(viewModel: viewModel),
    );
  }
}
