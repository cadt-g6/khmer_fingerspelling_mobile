import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/constants/config_constant.dart';
import 'package:khmer_fingerspelling_flutter/views/home/home_view_model.dart';

class PredictationTile extends StatelessWidget {
  const PredictationTile({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.primary;
    Color foregroundColor = Theme.of(context).colorScheme.onPrimary;

    return ValueListenableBuilder<int?>(
      valueListenable: viewModel.predictionIndexNotifier,
      builder: (context, selectedIndex, child) {
        return buildFadeInWrapper(
          selectedIndex: selectedIndex,
          child: Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            color: backgroundColor,
            child: ListTile(
              title: Text('Predicted: "ក"', style: TextStyle(color: foregroundColor)),
              subtitle: Text("Confident: ${(selectedIndex ?? 0) * 10}%", style: TextStyle(color: foregroundColor)),
              trailing: Icon(Icons.keyboard_arrow_down, color: foregroundColor),
              leading: SizedBox.square(dimension: 40, child: Icon(Icons.light, color: foregroundColor)),
              onTap: () {
                viewModel.showPredictInfo(
                  context,
                  viewModel.predictedPositions[viewModel.predictionIndexNotifier.value!],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildFadeInWrapper({
    required int? selectedIndex,
    required Widget child,
  }) {
    return AnimatedOpacity(
      duration: ConfigConstant.fadeDuration,
      curve: Curves.ease,
      opacity: selectedIndex != null ? 1 : 0.0,
      child: AnimatedContainer(
        duration: ConfigConstant.duration,
        curve: Curves.ease,
        transform: Matrix4.identity()..translate(0.0, selectedIndex != null ? 0.0 : -4.0),
        child: child,
      ),
    );
  }
}
