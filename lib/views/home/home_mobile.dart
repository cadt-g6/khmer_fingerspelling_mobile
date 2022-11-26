import 'package:flutter/material.dart';
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
    final image = viewModel.currentImage;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: buildAppBar(context),
      body: Stack(
        children: [
          EmptyWidget(onPressed: () => viewModel.showImageSelector.value = !viewModel.showImageSelector.value),
          if (image != null)
            Center(
              child: Image.file(image),
            ),
          buildImageSelector(),
        ],
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
