import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/constants/config_constant.dart';
import 'package:khmer_fingerspelling_flutter/providers/prediction_provider.dart';
import 'package:khmer_fingerspelling_flutter/views/home/home_view_model.dart';
import 'package:khmer_fingerspelling_flutter/widgets/kf_animated_icon.dart';
import 'package:provider/provider.dart';

class PredictationTile extends StatelessWidget {
  const PredictationTile({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final PredictionProvider provider = Provider.of<PredictionProvider>(context);

    return ValueListenableBuilder<PredictionState>(
      valueListenable: provider.stateNotifier,
      builder: (context, state, child) {
        Color backgroundColor = state == PredictionState.predicted
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary;

        Color foregroundColor = state == PredictionState.predicted
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSecondary;

        return buildFadeInWrapper(
          state: state,
          child: AnimatedContainer(
            duration: ConfigConstant.fadeDuration,
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            color: backgroundColor,
            child: ValueListenableBuilder(
              valueListenable: provider.stateNotifier,
              builder: (context, state, child) {
                return ListTile(
                  title: buildTitle(
                    foregroundColor,
                    state,
                    provider.currentPrediction?.classifierResult.label,
                  ),
                  subtitle: buildSubtitle(
                    foregroundColor,
                    state,
                    provider.currentPrediction?.classifierResult.accuracy,
                  ),
                  trailing: KfAnimatedIcons(
                    showFirst: state == PredictionState.cropping || state == PredictionState.predicting,
                    firstChild: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(foregroundColor),
                      ),
                    ),
                    secondChild: Icon(Icons.keyboard_arrow_down, color: foregroundColor),
                  ),
                  leading: SizedBox.square(dimension: 40, child: Icon(Icons.light, color: foregroundColor)),
                  onTap: () {
                    viewModel.showPredictInfo(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildSubtitle(
    Color foregroundColor,
    PredictionState state,
    double? confident,
  ) {
    String subtitle;

    switch (state) {
      case PredictionState.cropping:
      case PredictionState.predicting:
      case PredictionState.none:
        subtitle = "...";
        break;
      case PredictionState.predicted:
        subtitle = "Confident: ${confident?.toStringAsFixed(2)} %";
        break;
    }

    return Text(
      subtitle,
      style: TextStyle(color: foregroundColor),
    );
  }

  Text buildTitle(
    Color foregroundColor,
    PredictionState state,
    String? label,
  ) {
    String title;

    switch (state) {
      case PredictionState.cropping:
      case PredictionState.predicting:
        title = "Predicting";
        break;
      case PredictionState.predicted:
        title = 'Predicted: "$label"';
        break;
      case PredictionState.none:
        title = "Reloaded";
        break;
    }

    return Text(
      title,
      style: TextStyle(color: foregroundColor),
    );
  }

  Widget buildFadeInWrapper({
    required PredictionState state,
    required Widget child,
  }) {
    bool show = state != PredictionState.none;
    return AnimatedOpacity(
      duration: ConfigConstant.fadeDuration,
      curve: Curves.ease,
      opacity: show ? 1 : 0.0,
      child: AnimatedContainer(
        duration: ConfigConstant.duration,
        curve: Curves.ease,
        transform: Matrix4.identity()..translate(0.0, show ? 0.0 : -4.0),
        child: child,
      ),
    );
  }
}
