import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/constants/config_constant.dart';
import 'package:khmer_fingerspelling_flutter/core/services/messenger_service.dart';
import 'package:khmer_fingerspelling_flutter/core/utils/file_helper.dart';
import 'package:khmer_fingerspelling_flutter/views/home/home_view_model.dart';
import 'package:khmer_fingerspelling_flutter/widgets/kf_cross_fade.dart';
import 'package:khmer_fingerspelling_flutter/widgets/kf_fade_in.dart';
import 'package:provider/provider.dart';

class ImageSelector extends StatefulWidget {
  const ImageSelector({
    required this.onImageSelected,
    required this.showImageSelector,
    super.key,
  });

  final ValueNotifier<bool> showImageSelector;
  final void Function(File image, Size imageSize) onImageSelected;

  // ignore: library_private_types_in_public_api
  // _ImageSelectorState? of(BuildContext context) {
  //   return context.findAncestorStateOfType<_ImageSelectorState>();
  // }

  @override
  State<ImageSelector> createState() => _ImageSelectorState();
}

enum ImageDraggableState {
  dragging,
  inTarget,
  inactive,
}

class _ImageSelectorState extends State<ImageSelector> {
  late final ValueNotifier<ImageDraggableState> draggingStateNotifier;

  Set<String> imagePaths = {};
  Map<String, Size> imageSize = {};

  Future<void> addImage() async {
    String? key = await showModalActionSheet<String>(
      context: context,
      actions: [
        const SheetAction(label: "Camera", key: "camera"),
        const SheetAction(label: "Gallery", key: "gallery"),
        const SheetAction(label: "Url", key: "url"),
      ],
    );

    switch (key) {
      case "camera":
        break;
      case "gallery":
        break;
      case "url":
        getImageFromInput();
        break;
      default:
    }
  }

  Future<void> getImageFromInput() async {
    showTextInputDialog(
      context: context,
      title: "Insert image url",
      autoSubmit: true,
      textFields: [
        DialogTextField(
          hintText: "Image url",
          keyboardType: TextInputType.url,
          initialText: "https://miro.medium.com/max/1400/0*CvYL8OI0js7MWUlM",
          // "https://user-images.githubusercontent.com/29684683/204102649-185c05a5-98f5-457e-9fa1-cc08ad4c3168.png",
          // "https://img.freepik.com/premium-photo/multiracial-hands-coming-together_23-2148734043.jpg?w=2000",
          // "https://user-images.githubusercontent.com/29684683/204097524-812082bf-f526-44ad-baba-e34a512249b9.jpg",
          validator: (value) {
            if (value == null || value.trim().isEmpty) return "Must not null";
            if (Uri.tryParse(value.trim()) == null) return "Must be an url";
            return null;
          },
        ),
      ],
    ).then((value) async {
      if (value?.isNotEmpty == true) {
        final imageUrl = value![0].trim();
        final imageUri = Uri.parse(imageUrl);
        final imagePath = imageUri.pathSegments.join("_");

        File? file = await FileHelper.helper.getCachedFile(imagePath, FileParentType.imageUrl);
        file ??= await MessengerService.instance.showLoading(
          future: () async {
            final response = await http.get(imageUri);
            file = await FileHelper.helper.writeToFile(
              imagePath,
              response.bodyBytes,
              FileParentType.imageUrl,
            );
            return file;
          },
          context: context,
          debugSource: "_ImageSelectorState#getImageFromInput",
        );

        setState(() {
          imagePaths.add(file!.path);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    draggingStateNotifier = ValueNotifier(ImageDraggableState.inactive);
    FileHelper.helper.listAllImages().then((files) {
      if (files.isNotEmpty) {
        context.read<HomeViewModel>().showImageSelector.value = true;
        for (File file in files) {
          imagePaths.add(file.path);
        }
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.showImageSelector,
      builder: (context, show, child) {
        double height = kToolbarHeight + (kToolbarHeight + 16) + 2 + MediaQuery.of(context).padding.bottom;
        if (!show) height = 0;
        return AnimatedContainer(
          height: height,
          duration: ConfigConstant.duration,
          curve: Curves.ease,
          child: AnimatedOpacity(
            opacity: show ? 1.0 : 0.0,
            curve: Curves.ease,
            duration: ConfigConstant.fadeDuration,
            child: Wrap(
              children: [
                buildTile(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildTile(BuildContext context) {
    return Column(
      children: [
        buildImageHorizontalList(),
        const Divider(height: 1),
        buildActionRow(context),
      ],
    );
  }

  Widget buildActionRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0).copyWith(bottom: MediaQuery.of(context).padding.bottom),
      color: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.add_a_photo),
              onPressed: () {
                addImage();
              },
            ),
            Row(
              children: [
                // KfCrossFade(
                //   showFirst: context.read<HomeViewModel>().currentImage != null &&
                //       context.read<HomeViewModel>().predictedPositions.isEmpty == true,
                //   secondChild: const SizedBox(height: 48.0),
                //   duration: ConfigConstant.duration,
                //   alignment: Alignment.centerLeft,
                //   firstChild: TextButton.icon(
                //     icon: const Icon(Icons.image_search),
                //     label: const Text("Predict"),
                //     onPressed: () {
                //       context.read<HomeViewModel>().predict();
                //     },
                //   ),
                // ),
                KfCrossFade(
                  showFirst: context.read<HomeViewModel>().currentImage != null,
                  secondChild: const SizedBox(height: 48.0),
                  duration: ConfigConstant.duration,
                  alignment: Alignment.centerLeft,
                  firstChild: IconButton(
                    icon: const Icon(Icons.hide_image),
                    onPressed: () {
                      context.read<HomeViewModel>().setImage(null, null);
                    },
                  ),
                ),
                KfCrossFade(
                  showFirst: imagePaths.isEmpty,
                  secondChild: const SizedBox(height: 48.0),
                  duration: ConfigConstant.duration,
                  alignment: Alignment.centerLeft,
                  firstChild: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      context.read<HomeViewModel>().showImageSelector.value = false;
                    },
                  ),
                ),
                _DeletionDragTarget(
                  draggingStateNotifier: draggingStateNotifier,
                  onDeleteImage: (index) async {
                    final provider = context.read<HomeViewModel>();
                    final result = await showOkCancelAlertDialog(
                      context: context,
                      title: "Are you sure to delete?",
                      message: "You can't undo this action.",
                      isDestructiveAction: true,
                    );

                    if (result == OkCancelResult.cancel) return;
                    final filePath = imagePaths.elementAt(index);
                    setState(() {
                      imagePaths.remove(filePath);
                    });

                    File(filePath).delete();
                    if (provider.currentImage?.path == filePath) {
                      provider.setImage(null, null);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageHorizontalList() {
    return IgnorePointer(
      ignoring: imagePaths.isEmpty,
      child: KfFadeIn(
        duration: ConfigConstant.duration,
        child: SizedBox(
          height: kToolbarHeight + 16,
          child: ListView.separated(
            itemCount: imagePaths.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8.0),
            separatorBuilder: (context, index) => const SizedBox(width: 4.0),
            itemBuilder: (context, index) {
              return Draggable(
                data: index,
                onDragStarted: () => draggingStateNotifier.value = ImageDraggableState.dragging,
                onDragEnd: (_) => draggingStateNotifier.value = ImageDraggableState.inactive,
                feedback: Opacity(opacity: 0.5, child: buildImage(index)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor)),
                          child: buildImage(index),
                        ),
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              final filePath = imagePaths.elementAt(index);
                              widget.onImageSelected(
                                File(filePath),
                                imageSize[filePath]!,
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildImage(int index) {
    final File file = File(imagePaths.elementAt(index));
    return Image.file(
      file,
      fit: BoxFit.cover,
      width: kToolbarHeight,
      height: kToolbarHeight,
    )..image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener(
          (imageInfo, _) {
            int width = imageInfo.image.width;
            int height = imageInfo.image.height;
            imageSize[file.path] = Size(width.toDouble(), height.toDouble());
          },
        ),
      );
  }
}

class _DeletionDragTarget extends StatelessWidget {
  const _DeletionDragTarget({
    Key? key,
    required this.draggingStateNotifier,
    required this.onDeleteImage,
  }) : super(key: key);

  final ValueNotifier<ImageDraggableState> draggingStateNotifier;
  final void Function(int index) onDeleteImage;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ImageDraggableState>(
      valueListenable: draggingStateNotifier,
      builder: (context, state, child) {
        return KfCrossFade(
          showFirst: state == ImageDraggableState.inactive,
          duration: ConfigConstant.duration,
          alignment: Alignment.centerLeft,
          firstChild: const SizedBox(height: 48.0),
          secondChild: DragTarget<int>(
            onWillAccept: (imageIndex) => true,
            onLeave: (details) => draggingStateNotifier.value = ImageDraggableState.dragging,
            onMove: (details) => draggingStateNotifier.value = ImageDraggableState.inTarget,
            onAccept: (int index) => onDeleteImage(index),
            builder: (context, candidateData, rejectedData) {
              return AnimatedContainer(
                width: 48,
                height: 48,
                duration: ConfigConstant.fadeDuration,
                transform: Matrix4.identity()..scale(state == ImageDraggableState.inTarget ? 1.2 : 1.0),
                transformAlignment: Alignment.center,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .error
                      .withOpacity(state == ImageDraggableState.inTarget ? 0.1 : 0.0),
                ),
                child: KfCrossFade(
                  showFirst: state == ImageDraggableState.inTarget,
                  duration: ConfigConstant.duration,
                  alignment: Alignment.centerLeft,
                  firstChild: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                  secondChild: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
