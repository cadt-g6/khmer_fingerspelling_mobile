import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/providers/prediction_provider.dart';
import 'package:khmer_fingerspelling_flutter/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ProviderScope extends StatelessWidget {
  const ProviderScope({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
        ListenableProvider<PredictionProvider>(
          create: (context) => PredictionProvider.instance,
        ),
      ],
      child: child,
    );
  }
}
