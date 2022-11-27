import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/constants/config_constant.dart';
import 'package:khmer_fingerspelling_flutter/core/theme/color_scheme_extension.dart';

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
      tabBarTheme: TabBarTheme(
        labelColor: themeData.colorScheme.onSurface,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 2, color: themeData.colorScheme.primary),
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: ConfigConstant.circlarRadius2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: themeData.colorScheme.readOnly.surface2,
        centerTitle: false,
        elevation: 0.0,
        foregroundColor: themeData.colorScheme.onSurface,
      ),
      textTheme: themeData.textTheme.apply(
        fontFamily: 'KantumruyPro',
      ),
    );
  }
}
