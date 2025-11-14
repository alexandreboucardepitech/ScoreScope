import 'package:flutter/material.dart';

class ColorPalette {
  // Background
  static const Color backgroundLight = Color(0xFFE1C2F4); // color-100
  static const Color backgroundDark = Color(0xFF2A0B3D);  // color-900

  // Couleurs principales
  static const Color primaryLight = Color(0xFF9426D9); // color-500
  static const Color primaryDark = Color(0xFF9426D9); // color-500

  static const Color secondaryLight = Color(0xFFA84DE0); // color-400
  static const Color secondaryDark = Color(0xFF7A1FB2); // color-600

  static const Color tertiaryLight = Color(0xFFBB74E7); // color-300
  static const Color tertiaryDark = Color(0xFF5F188B); // color-700

  static const Color oppositeLight = Color(0xFF2A0B3D); // color-900
  static const Color oppositeDark = Color(0xFFF4E9FB); // color-50

  static const Color accentLight = Color(0xFF9426D9); // color-500
  static const Color accentDark = Color(0xFF9426D9); // color-500

  // Textes
  static const Color textPrimaryLight = Color(0xFF2A0B3D); // color-900
  static const Color textPrimaryDark = Color(0xFFF4E9FB); // color-50

  static const Color textSecondaryLight = Color(0xFF5F188B); // color-700
  static const Color textSecondaryDark = Color(0xFFCE9BED); // color-200

  static const Color textAccentLight = accentLight;
  static const Color textAccentDark = accentDark;

  // Borders / dividers
  static const Color borderLight = Color(0xFFBB74E7); // color-300
  static const Color borderDark = Color(0xFF441264); // color-800

  // Getters dynamiques
  static Color primary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? primaryDark : primaryLight;

  static Color secondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? secondaryDark : secondaryLight;

  static Color tertiary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? tertiaryDark : tertiaryLight;

  static Color opposite(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? oppositeDark : oppositeLight;

  static Color accent(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? accentDark : accentLight;

  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? backgroundDark : backgroundLight;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textPrimaryDark : textPrimaryLight;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textSecondaryDark : textSecondaryLight;

  static Color textAccent(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textAccentDark : textAccentLight;

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? borderDark : borderLight;
}
