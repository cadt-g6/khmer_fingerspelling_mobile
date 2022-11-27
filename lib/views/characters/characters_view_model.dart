import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:khmer_fingerspelling_flutter/core/base/base_view_model.dart';
import 'package:khmer_fingerspelling_flutter/models/character_model.dart';

class CharactersViewModel extends BaseViewModel {
  List<CharacterModel> consonants = [];
  List<CharacterModel> stackConsonants = [];
  List<CharacterModel> vowels = [];
  List<CharacterModel> subVowels = [];
  List<CharacterModel> independentVowels = [];

  CharactersViewModel() {
    load();
  }

  Future<void> load() async {
    final consonantsStr = await rootBundle.loadString('assets/characters/consonants.json');
    final stackConsonantsStr = await rootBundle.loadString('assets/characters/stack_consonants.json');
    final vowelsStr = await rootBundle.loadString('assets/characters/vowels.json');
    final subVowelsStr = await rootBundle.loadString('assets/characters/sub_vowels.json');
    final independentVowelsStr = await rootBundle.loadString('assets/characters/independent_vowels.json');

    List<dynamic> characterGroups = [
      jsonDecode(consonantsStr),
      jsonDecode(stackConsonantsStr),
      jsonDecode(vowelsStr),
      jsonDecode(subVowelsStr),
      jsonDecode(independentVowelsStr),
    ];

    List<CharacterModel> characters = [];

    for (var json in characterGroups) {
      for (var char in json['data']) {
        characters.add(
          CharacterModel(
            type: json['type'],
            khmer: char['khmer'],
            latin: char['latin'],
            imagePath: [
              "assets/images",
              json['type'],
              char['latin'] + ".jpg",
            ].join("/"),
          ),
        );
      }
    }

    consonants = characters.where((e) => e.type == 'consonants').toList();
    stackConsonants = characters.where((e) => e.type == 'stack_consonants').toList();
    vowels = characters.where((e) => e.type == 'vowels').toList();
    subVowels = characters.where((e) => e.type == 'sub_vowels').toList();
    independentVowels = characters.where((e) => e.type == 'independent_vowels').toList();

    notifyListeners();
  }
}
