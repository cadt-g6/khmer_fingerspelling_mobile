import 'dart:math';
import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/constants/config_constant.dart';
import 'package:khmer_fingerspelling_flutter/providers/prediction_provider.dart';
import 'package:khmer_fingerspelling_flutter/views/characters/characters_view_model.dart';

class PredictedDialog extends StatefulWidget {
  const PredictedDialog({
    super.key,
    required this.prediction,
  });

  final PredictionCombinedModel prediction;

  @override
  State<PredictedDialog> createState() => _PredictedDialogState();
}

class _PredictedDialogState extends State<PredictedDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(12.0),
      child: Stack(
        children: [
          buildContents(context),
          buildActions(context),
        ],
      ),
    );
  }

  Widget buildActions(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        children: [
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: ConfigConstant.circlarRadius2,
            ),
            child: TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.maybePop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContents(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24 + 8, bottom: 32 + 48 + 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Predictions",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16.0),
          const Divider(height: 1),
          const SizedBox(height: 24.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Image",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 12.0),
                Container(
                  decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor)),
                  padding: const EdgeInsets.all(4),
                  transform: Matrix4.identity()..translate(-4.0, 0.0),
                  child: Image.file(
                    widget.prediction.image,
                    fit: BoxFit.cover,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 24.0),
                Text(
                  "Table",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12.0),
                buildTable(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTable(BuildContext context) {
    List<dynamic>? other = widget.prediction.posibilities.map((e) {
      return [0, getKhmer(e.label), e.label, "${e.accuracy.toStringAsFixed(2)} %"];
    }).toList();

    other = other.getRange(0, min(5, other.length)).toList();

    return Table(
      border: TableBorder.all(color: Theme.of(context).dividerColor),
      children: [
        [1, "Possibility", "In Latin", "Confident"],
        if (other.isNotEmpty) ...other,
        // [1, "Position", ""],
        // [0, "X", widget.position.x.toStringAsFixed(2)],
        // [0, "Y", widget.position.y.toStringAsFixed(2)],
        // [0, "Width", widget.position.w.toStringAsFixed(2)],
        // [0, "Height", widget.position.h.toStringAsFixed(2)],
      ].map((e) {
        bool header = e[0] == 1;
        TextStyle? textStyle = header ? Theme.of(context).textTheme.labelSmall : Theme.of(context).textTheme.bodyMedium;
        return TableRow(
          decoration: BoxDecoration(
            color: header ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                e[1].toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                e[2].toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                e.length > 3 ? e[3].toString() : "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String? getKhmer(String label) {
    final result = CharactersViewModel.instance.consonants.where((element) => element.latin == label);
    if (result.isNotEmpty) return result.first.khmer;
    return null;
  }
}
