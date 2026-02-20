import 'package:scorescope/models/enum/language_options.dart';
import 'package:scorescope/models/enum/theme_options.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';
import 'package:scorescope/services/repository_provider.dart';

class Options {
  final bool allNotifications;
  final bool newFollowers;
  final bool likes;
  final bool comments;
  final bool replies;
  final bool favoriteTeamMatch;
  final bool results;
  final bool emailNotifications;
  final LanguageOptions language;
  final ThemeOptions theme;
  final VisionnageMatch defaultVisionnageMatch;

  Options({
    this.allNotifications = true,
    this.newFollowers = true,
    this.likes = true,
    this.comments = true,
    this.replies = true,
    this.favoriteTeamMatch = true,
    this.results = true,
    this.emailNotifications = true,
    this.language = LanguageOptions.french,
    this.theme = ThemeOptions.system,
    this.defaultVisionnageMatch = VisionnageMatch.tele,
  });

  Map<String, dynamic> toJson() => {
        'allNotifications': allNotifications,
        'newFollowers': newFollowers,
        'likes': likes,
        'comments': comments,
        'replies': replies,
        'favoriteTeamMatch': favoriteTeamMatch,
        'results': results,
        'emailNotifications': emailNotifications,
        'language': language.name,
        'theme': theme.name,
        'defaultVisionnageMatch': defaultVisionnageMatch.label,
      };

  factory Options.fromJson(Map<String, dynamic> json) {
    final language = LanguageOptions.fromString(json['language'] as String?) ??
        LanguageOptions.french;
    final theme = ThemeOptions.fromString(json['theme'] as String?) ??
        ThemeOptions.system;
    final defaultVisionnageMatch = VisionnageMatchExt.fromString(
            json['defaultVisionnageMatch'] as String) ??
        RepositoryProvider
            .userRepository.currentUser?.options.defaultVisionnageMatch ??
        VisionnageMatch.tele;

    return Options(
      allNotifications: json['allNotifications'] as bool? ?? false,
      newFollowers: json['newFollowers'] as bool? ?? false,
      likes: json['likes'] as bool? ?? false,
      comments: json['comments'] as bool? ?? false,
      replies: json['replies'] as bool? ?? false,
      favoriteTeamMatch: json['favoriteTeamMatch'] as bool? ?? false,
      results: json['results'] as bool? ?? false,
      emailNotifications: json['emailNotifications'] as bool? ?? false,
      language: language,
      theme: theme,
      defaultVisionnageMatch: defaultVisionnageMatch,
    );
  }
}
