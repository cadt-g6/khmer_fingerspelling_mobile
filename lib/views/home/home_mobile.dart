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
      appBar: AppBar(
        title: const Text("Khmer Fingerspelling"),
        actions: [
          IconButton(
            icon: const Icon(Icons.light),
            onPressed: () {
              context.read<ThemeProvider>().toggleThemeMode();
            },
          ),
        ],
      ),
    );
  }
}
