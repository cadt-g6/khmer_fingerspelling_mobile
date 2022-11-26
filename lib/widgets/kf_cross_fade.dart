import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/constants/config_constant.dart';

class KfCrossFade extends StatelessWidget {
  const KfCrossFade({
    Key? key,
    required this.firstChild,
    required this.secondChild,
    required this.showFirst,
    this.alignment = Alignment.topCenter,
    this.duration = ConfigConstant.duration,
  }) : super(key: key);

  final Widget firstChild;
  final Widget secondChild;
  final bool showFirst;
  final AlignmentGeometry alignment;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      alignment: alignment,
      firstChild: firstChild,
      secondChild: secondChild,
      sizeCurve: Curves.ease,
      crossFadeState: showFirst ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: duration,
    );
  }
}
