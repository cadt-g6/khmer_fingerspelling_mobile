import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/constants/config_constant.dart';
import 'package:khmer_fingerspelling_flutter/models/character_model.dart';
import 'package:khmer_fingerspelling_flutter/views/characters/characters_view_model.dart';

class CharactersMobile extends StatelessWidget {
  const CharactersMobile({
    super.key,
    required this.viewModel,
  });

  final CharactersViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Characters"),
          bottom: buildTabBar(context),
        ),
        body: TabBarView(
          children: [
            buildGridView(context, viewModel.consonants),
            buildGridView(context, viewModel.stackConsonants),
            buildGridView(context, viewModel.vowels),
            buildGridView(context, viewModel.subVowels),
            buildGridView(context, viewModel.independentVowels),
          ],
        ),
      ),
    );
  }

  TabBar buildTabBar(BuildContext context) {
    return const TabBar(
      isScrollable: true,
      tabs: [
        Tab(text: "Consonants"),
        Tab(text: "Stack Consonants"),
        Tab(text: "Vowels"),
        Tab(text: "Sub Vowels"),
        Tab(text: "Independent Vowels"),
      ],
    );
  }

  Widget buildGridView(BuildContext context, List<CharacterModel>? characters) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: characters?.length ?? 0,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width ~/ 120,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (BuildContext context, int index) {
        final char = characters![index];
        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: ConfigConstant.circlarRadius2,
          ),
          child: Stack(
            children: [
              Image.asset("assets/images/consonants/yo.jpg"),
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: ConfigConstant.circlarRadius2,
                  ),
                  child: Text(
                    " ${char.khmer} ",
                    strutStyle: const StrutStyle(forceStrutHeight: true),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
