import 'package:flutter/material.dart';

class ColorPalette {
  // ----- BACKGROUND & SURFACES -----
  static const Color backgroundLight = Color(0xFFF4E9FB); // très doux
  static const Color backgroundDark = Color(0xFF0E0A12); // très foncé

  static const Color surfaceLight = Color(0xFFEDE0F7);
  static const Color surfaceDark = Color(0xFF1D1129);

  static const Color surfaceSecondaryLight = Color(0xFFE5D4F3);
  static const Color surfaceSecondaryDark = Color(0xFF2A1B3A);

  static const Color tileBackgroundLight = Color(0xFFF8F1FC);
  static const Color tileBackgroundDark = Color(0xFF1A141F);

  static const Color tileSelectedLight = Color(0x149426D9); // 8% violet
  static const Color tileSelectedDark = Color(0x1A9426D9); // 10%

  static const Color listHeaderLight = Color(0xFFDCC1F2);
  static const Color listHeaderDark = Color(0xFF241B2B);

  static const Color pictureBackgroundLight = Color(0xFFEFE7F5);
  static const Color pictureBackgroundDark = Color(0xFF1C1424);

  // ----- TEXT -----
  static const Color textPrimaryLight = Color(0xFF2A0B3D);
  static const Color textPrimaryDark = Color(0xFFF4E9FB);

  static const Color textSecondaryLight = Color(0xFF5F188B);
  static const Color textSecondaryDark = Color(0xFFCE9BED);

  static const Color textAccentLight = Color(0xFF9426D9);
  static const Color textAccentDark = Color(0xFFBB74E7);

  // ----- BUTTONS -----
  static const Color buttonPrimaryLight = Color(0xFF9426D9);
  static const Color buttonPrimaryDark = Color(0xFFBB74E7);

  static const Color buttonSecondaryLight = Color(0xFFE5D4F3);
  static const Color buttonSecondaryDark = Color(0xFF2A1B3A);

  static const Color buttonDisabledLight = Color(0xFFD9CDE7);
  static const Color buttonDisabledDark = Color(0xFF4E3B61);

  // ----- ACCENTS -----
  static const Color accentLight = Color(0xFF9426D9);
  static const Color accentDark = Color(0xFFBB74E7);

  static const Color accentVariantLight = Color(0xFFBB74E7);
  static const Color accentVariantDark = Color(0xFFE1C2F4);

  static const Color highlightLight = Color(0x339426D9);
  static const Color highlightDark = Color(0x339426D9);

  // ----- STATUS -----
  static const Color successLight = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF81C784);

  static const Color warningLight = Color(0xFFFFC107);
  static const Color warningDark = Color(0xFFFFD54F);

  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFEF9A9A);

  // ----- BORDERS -----
  static const Color borderLight = Color(0xFFBB9BCC);
  static const Color borderDark = Color(0xFF2A2233);

  static const Color dividerLight = Color(0x332A0B3D);
  static const Color dividerDark = Color(0x33F4E9FB);

  // ----- SHIMMER -----
  static const Color shimmerPrimaryLight = Color(0xFFEDE0F7);
  static const Color shimmerPrimaryDark = Color(0xFF1D1129);

  static const Color shimmerSecondaryLight = Color(0xFFF4E9FB);
  static const Color shimmerSecondaryDark = Color(0xFF2A1B3A);

  // ----- OPPOSITE -----
  static const Color oppositeLight = Color(0xFF0F0416);
  static const Color oppositeDark = Color(0xFFF4E9FB);

  // ----- GETTERS -----
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      isDark(context) ? backgroundDark : backgroundLight;

  static Color surface(BuildContext context) =>
      isDark(context) ? surfaceDark : surfaceLight;

  static Color surfaceSecondary(BuildContext context) =>
      isDark(context) ? surfaceSecondaryDark : surfaceSecondaryLight;

  static Color tileBackground(BuildContext context) =>
      isDark(context) ? tileBackgroundDark : tileBackgroundLight;

  static Color tileSelected(BuildContext context) =>
      isDark(context) ? tileSelectedDark : tileSelectedLight;

  static Color listHeader(BuildContext context) =>
      isDark(context) ? listHeaderDark : listHeaderLight;

  static Color pictureBackground(BuildContext context) =>
      isDark(context) ? pictureBackgroundDark : pictureBackgroundLight;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? textPrimaryDark : textPrimaryLight;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? textSecondaryDark : textSecondaryLight;

  static Color textAccent(BuildContext context) =>
      isDark(context) ? textAccentDark : textAccentLight;

  static Color buttonPrimary(BuildContext context) =>
      isDark(context) ? buttonPrimaryDark : buttonPrimaryLight;

  static Color buttonSecondary(BuildContext context) =>
      isDark(context) ? buttonSecondaryDark : buttonSecondaryLight;

  static Color buttonDisabled(BuildContext context) =>
      isDark(context) ? buttonDisabledDark : buttonDisabledLight;

  static Color accent(BuildContext context) =>
      isDark(context) ? accentDark : accentLight;

  static Color accentVariant(BuildContext context) =>
      isDark(context) ? accentVariantDark : accentVariantLight;

  static Color highlight(BuildContext context) =>
      isDark(context) ? highlightDark : highlightLight;

  static Color success(BuildContext context) =>
      isDark(context) ? successDark : successLight;

  static Color warning(BuildContext context) =>
      isDark(context) ? warningDark : warningLight;

  static Color error(BuildContext context) =>
      isDark(context) ? errorDark : errorLight;

  static Color border(BuildContext context) =>
      isDark(context) ? borderDark : borderLight;

  static Color divider(BuildContext context) =>
      isDark(context) ? dividerDark : dividerLight;

  static Color shimmerPrimary(BuildContext context) =>
      isDark(context) ? shimmerPrimaryDark : shimmerPrimaryLight;

  static Color shimmerSecondary(BuildContext context) =>
      isDark(context) ? shimmerSecondaryDark : shimmerSecondaryLight;

  static Color opposite(BuildContext context) =>
      isDark(context) ? oppositeDark : oppositeLight;
}
