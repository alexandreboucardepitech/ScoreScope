import 'package:scorescope/models/enum/language_options.dart';
import 'package:scorescope/models/enum/theme_options.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';

class Options {
  final bool allNotifications;
  final bool friendRequest;
  final bool friendRequestAccepted;
  final bool reaction;
  final bool comment;
  final bool favoriteTeamMatch;
  final bool weeklyRecap;
  final LanguageOptions? language;
  final ThemeOptions theme;
  final VisionnageMatch defaultVisionnageMatch;
  final bool utiliserCache;

  Options({
    this.allNotifications = true,
    this.friendRequest = true,
    this.friendRequestAccepted = true,
    this.reaction = true,
    this.comment = true,
    this.favoriteTeamMatch = true,
    this.weeklyRecap = true,
    this.language,
    this.theme = ThemeOptions.system,
    this.defaultVisionnageMatch = VisionnageMatch.tele,
    this.utiliserCache = true,
  });

  Map<String, dynamic> toJson() => {
        'allNotifications': allNotifications,
        'friendRequest': friendRequest,
        'friendRequestAccepted': friendRequestAccepted,
        'reaction': reaction,
        'comment': comment,
        'favoriteTeamMatch': favoriteTeamMatch,
        'weeklyRecap': weeklyRecap,
        if (language != null) 'language': language!.code,
        'theme': theme.name,
        'defaultVisionnageMatch': defaultVisionnageMatch.labelFR,
        'utiliserCache': utiliserCache,
      };

  factory Options.fromJson(Map<String, dynamic> json) {
    final language = LanguageOptions.fromString(json['language'] as String?);
    final theme = ThemeOptions.fromString(json['theme'] as String?) ??
        ThemeOptions.system;
    final defaultVisionnageMatch = VisionnageMatchExt.fromString(
            json['defaultVisionnageMatch'] as String? ??
                VisionnageMatch.tele.labelFR) ??
        VisionnageMatch.tele;

    return Options(
      allNotifications: json['allNotifications'] as bool? ?? true,
      friendRequest: json['friendRequest'] as bool? ?? true,
      friendRequestAccepted: json['friendRequestAccepted'] as bool? ?? true,
      reaction: json['reaction'] as bool? ?? true,
      comment: json['comment'] as bool? ?? true,
      favoriteTeamMatch: json['favoriteTeamMatch'] as bool? ?? true,
      weeklyRecap: json['weeklyRecap'] as bool? ?? true,
      language: language,
      theme: theme,
      defaultVisionnageMatch: defaultVisionnageMatch,
      utiliserCache: json['utiliserCache'] as bool? ?? true,
    );
  }
}
