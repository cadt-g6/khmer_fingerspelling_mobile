import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/base/view_model_provider.dart';
import 'package:khmer_fingerspelling_flutter/views/characters/characters_mobile.dart';
import 'package:khmer_fingerspelling_flutter/views/characters/characters_view_model.dart';

class CharactersView extends StatelessWidget {
  const CharactersView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider<CharactersViewModel>(
      create: (context) => CharactersViewModel(),
      builder: (context, viewModel, child) {
        return CharactersMobile(viewModel: viewModel);
      },
    );
  }
}
