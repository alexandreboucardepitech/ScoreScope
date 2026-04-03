import 'package:flutter/material.dart';

class AppLogos {
  static const String accent =
      'assets/logos/ScoreScope_Mark_accent_1024x1024.png';

  static const String dark = 'assets/logos/ScoreScope_Mark_dark_1024x1024.png';

  static const String light =
      'assets/logos/ScoreScope_Mark_light_1024x1024.png';

  static const String outline =
      'assets/logos/ScoreScope_Mark_outline_1024x1024.png';

  static const String primary =
      'assets/logos/ScoreScope_Mark_primary_1024x1024.png';

  static const String transparentDark =
      'assets/logos/ScoreScope_Mark_transparentDark_1024x1024.png';

  static const String transparentLight =
      'assets/logos/ScoreScope_Mark_transparentLight_1024x1024.png';

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Widget logoAccent(BuildContext context, {double size = 48}) =>
      Image.asset(
        accent,
        width: size,
        height: size,
      );
  static Widget logoMark(BuildContext context, {double size = 48}) =>
      Image.asset(
        isDark(context) ? dark : light,
        width: size,
        height: size,
      );
  static Widget logoOutline(BuildContext context, {double size = 48}) =>
      Image.asset(
        outline,
        width: size,
        height: size,
      );
  static Widget logoPrimary(BuildContext context, {double size = 48}) =>
      Image.asset(
        primary,
        width: size,
        height: size,
      );
  static Widget logoTransparent(BuildContext context, {double size = 48}) =>
      Image.asset(
        isDark(context) ? transparentDark : transparentLight,
        width: size,
        height: size,
      );
}
