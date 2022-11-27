import 'dart:io';
import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/tflite/predicted_position.dart';

class PredictedDialog extends StatefulWidget {
  const PredictedDialog({
    super.key,
    required this.position,
    required this.image,
  });

  final PredictedPosition position;
  final File image;

  @override
  State<PredictedDialog> createState() => _PredictedDialogState();
}

class _PredictedDialogState extends State<PredictedDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Predicted",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 16.0),
            const Divider(height: 1),
            const SizedBox(height: 16.0),
            Text(
              "Image",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8.0),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor)),
              padding: const EdgeInsets.all(4),
              child: Image.file(
                widget.image,
                fit: BoxFit.cover,
                height: 100,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              "Table",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12.0),
            buildTable(context),
            const SizedBox(height: 24.0),
            const Divider(height: 1),
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.maybePop(context);
              },
            )
          ],
        ),
      ),
    );
  }

  Widget buildTable(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Theme.of(context).dividerColor),
      children: [
        [1, "Summary", "", ""],
        [0, "Character", "ក", ""],
        [0, "Confident", "0.6", ""],
        [1, "Position", "Original", ""],
        [0, "X", widget.position.x],
        [0, "Y", widget.position.y],
        [0, "Width", widget.position.w],
        [0, "Height", widget.position.h],
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
          ],
        );
      }).toList(),
    );
  }
}
