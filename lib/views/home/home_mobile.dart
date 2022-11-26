import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/providers/theme_provider.dart';
import 'package:khmer_fingerspelling_flutter/views/home/home_view_model.dart';
import 'package:provider/provider.dart';

class HomeMobile extends StatelessWidget {
  const HomeMobile({
    super.key,
    required HomeViewModel viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.light),
            onPressed: () {
              context.read<ThemeProvider>().toggleThemeMode();
            },
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_a_photo_outlined,
              size: 64,
            ),
            TextButton(
              onPressed: () {},
              child: const Text("បញ្ចូលរូបភាព"),
            )
          ],
        ),
      ),
    );
  }
}
