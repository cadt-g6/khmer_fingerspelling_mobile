import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/app.dart';
import 'package:khmer_fingerspelling_flutter/provider_scope.dart';

void main() {
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
