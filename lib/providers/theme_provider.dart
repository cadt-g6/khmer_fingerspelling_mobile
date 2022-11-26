import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  bool isDarkMode() {
    if (themeMode == ThemeMode.system) {
      Brightness? brightness = SchedulerBinding.instance.window.platformBrightness;
      return brightness == Brightness.dark;
    } else {
      return themeMode == ThemeMode.dark;
    }
  }

  void toggleThemeMode() {
    themeMode = isDarkMode() ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
