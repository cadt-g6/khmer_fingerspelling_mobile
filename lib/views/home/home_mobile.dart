import 'dart:io';
import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/tflite/predicted_position.dart';
import 'package:khmer_fingerspelling_flutter/views/home/home_view_model.dart';
import 'package:khmer_fingerspelling_flutter/views/home/local_widgets/detector_rect.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      onDrawerChanged: (isOpened) => viewModel.drawerOpenedNotifier.value = isOpened,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: buildAppBar(context),
      drawer: const Drawer(),
      body: Stack(
        children: [
          EmptyWidget(onPressed: () => viewModel.showImageSelector.value = !viewModel.showImageSelector.value),
          if (viewModel.currentImage != null) buildBody(viewModel.currentImage!),
          buildImageSelector(),
          PredictationTile(viewModel: viewModel),
        ],
      ),
    );
  }

  Widget buildBody(File image) {
    List<PredictedPosition> positions = [...viewModel.predictedPositions];
    positions.sort((a, b) => b.w * b.h > a.w * a.h ? 1 : -1);

    return Center(
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            Image.file(
              image,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fitWidth,
            ),
            for (int index = 0; index < positions.length; index++)
              DetectorRect(
                viewModel: viewModel,
                context: context,
                index: viewModel.predictedPositions.indexOf(positions[index]),
                position: positions[index],
                constraints: constraints,
              )
          ],
        );
      }),
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
