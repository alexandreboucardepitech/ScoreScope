import 'package:flutter/material.dart';
import 'package:scorescope/utils/translate/app_localizations.dart';

extension L10nExtension on BuildContext {
  AppLocalizations get translate => AppLocalizations.of(this)!;
}