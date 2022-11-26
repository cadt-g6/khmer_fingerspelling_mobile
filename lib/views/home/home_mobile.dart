import 'dart:io';
import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/tflite/predicted_position.dart';
import 'package:khmer_fingerspelling_flutter/views/home/home_view_model.dart';
import 'package:khmer_fingerspelling_flutter/views/home/local_widgets/empty_widget.dart';
import 'package:khmer_fingerspelling_flutter/views/home/local_widgets/home_app_bar.dart';
import 'package:khmer_fingerspelling_flutter/views/home/local_widgets/image_selector.dart';

class HomeMobile extends StatelessWidget {
  const HomeMobile({
    super.key,
    required this.viewModel,
  });

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: buildAppBar(context),
      body: Stack(
        children: [
          EmptyWidget(onPressed: () => viewModel.showImageSelector.value = !viewModel.showImageSelector.value),
          if (viewModel.currentImage != null) buildBody(viewModel.currentImage!),
          buildImageSelector(),
        ],
      ),
    );
  }

  Widget buildBody(File image) {
    return Center(
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            Image.file(
              image,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fitWidth,
            ),
            for (int index = 0; index < viewModel.predictedPositions.length; index++)
              buildRect(
                context,
                index,
                viewModel.predictedPositions[index],
                constraints,
              )
          ],
        );
      }),
    );
  }

  Widget buildRect(
    BuildContext context,
    int index,
    PredictedPosition position,
    BoxConstraints constraints,
  ) {
    double imageSize = constraints.maxWidth;

    double x = position.x;
    double y = position.y;
    double w = position.w;
    double h = position.h;

    x = x * imageSize / viewModel.currentImageAspectRatio!.height;
    w = w * imageSize / viewModel.currentImageAspectRatio!.height;

    y = y * imageSize / viewModel.currentImageAspectRatio!.width;
    h = h * imageSize / viewModel.currentImageAspectRatio!.width;

    double xw = x + w;
    double yh = y + h;

    PredictedPosition relativePosition = PredictedPosition(x, y, w, h);
    return Positioned.fromRect(
      rect: Rect.fromPoints(
        Offset(x, yh),
        Offset(xw, y),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async => viewModel.showPredictInfo(context, position, relativePosition),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                  Colors.brown,
                  Colors.cyan,
                ][(index + 1) % 7],
              ),
            ),
          ),
        ),
      ),
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
