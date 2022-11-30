import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/app.dart';
import 'package:khmer_fingerspelling_flutter/provider_scope.dart';
import 'package:khmer_fingerspelling_flutter/views/characters/characters_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CharactersViewModel.instance.load();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
