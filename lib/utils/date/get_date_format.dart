import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/language_options.dart';
import 'package:scorescope/services/repository_provider.dart';

String getDateFormat() {
  String dateLanguage = 'fr_FR';
  AppUser? currentUser = RepositoryProvider.userRepository.currentUser;
  if (currentUser != null &&
      currentUser.options.language == LanguageOptions.english)
    dateLanguage = 'en_US';
  return dateLanguage;
}
