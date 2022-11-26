import 'package:flutter/material.dart';

class ThemeConfig {
  ThemeConfig._();
  static final ThemeConfig config = ThemeConfig._();

  bool isApple(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
    }
  }

  ThemeData lightTheme(BuildContext context) {
    return withConfiguration(ThemeData.from(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
    ));
  }

  ThemeData darkTheme(BuildContext context) {
    return withConfiguration(ThemeData.from(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    ));
  }

  ThemeData withConfiguration(ThemeData themeData) {
    return themeData.copyWith(
      splashFactory: isApple(themeData.platform) ? NoSplash.splashFactory : InkSparkle.splashFactory,
      textTheme: themeData.textTheme.apply(
        fontFamily: 'KantumruyPro',
      ),
    );
  }
}
