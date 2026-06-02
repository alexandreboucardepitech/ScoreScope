import 'package:flutter/material.dart';
import 'package:scorescope/models/enum/language_options.dart';
import 'package:scorescope/utils/translate/app_localizations.dart';
import 'package:scorescope/utils/translate/app_localizations_fr.dart';
import 'package:scorescope/utils/translate/app_localizations_en.dart';

// Variable globale accessible partout sans context
AppLocalizations translate = AppLocalizationsFr();

class LanguageController extends ChangeNotifier {
  Locale _locale = _deviceLocale();

  Locale get locale => _locale;

  void initialize(LanguageOptions? userLanguage) {
    if (userLanguage != null) {
      _locale = _toLocale(userLanguage);
    } else {
      _locale = _deviceLocale();
    }
    _updateTranslations();
    notifyListeners();
  }

  void setLanguage(LanguageOptions option) {
    _locale = _toLocale(option);
    _updateTranslations();
    notifyListeners();
  }

  void _updateTranslations() {
    translate = _locale.languageCode == 'en'
        ? AppLocalizationsEn()
        : AppLocalizationsFr();
  }

  static Locale _deviceLocale() {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return deviceLocale.languageCode == 'en'
        ? const Locale('en')
        : const Locale('fr');
  }

  static Locale _toLocale(LanguageOptions option) {
    return option == LanguageOptions.english
        ? const Locale('en')
        : const Locale('fr');
  }
}
