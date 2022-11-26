import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/theme/theme_config.dart';
import 'package:khmer_fingerspelling_flutter/providers/theme_provider.dart';
import 'package:khmer_fingerspelling_flutter/views/home/home_view.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(debugLabel: "App");

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      navigatorKey: navigatorKey,
      themeMode: themeProvider.themeMode,
      theme: ThemeConfig.config.lightTheme(context),
      darkTheme: ThemeConfig.config.darkTheme(context),
      home: const HomeView(),
    );
  }
}
