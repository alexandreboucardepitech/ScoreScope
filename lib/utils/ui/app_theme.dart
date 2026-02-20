import 'package:flutter/material.dart';
import 'package:scorescope/models/enum/theme_options.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
  );
}

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeOptions option) {
    switch (option) {
      case ThemeOptions.light:
        _themeMode = ThemeMode.light;
        break;
      case ThemeOptions.dark:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeOptions.system:
        _themeMode = ThemeMode.system;
        break;
    }

    notifyListeners();
  }

  void initialize(ThemeOptions option) {
    setTheme(option);
  }
}
