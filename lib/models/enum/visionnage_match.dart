import 'package:scorescope/utils/translate/language_controller.dart';

enum VisionnageMatch {
  tele,
  stade,
  bar,
}

extension VisionnageMatchExt on VisionnageMatch {
  String get emoji {
    switch (this) {
      case VisionnageMatch.tele:
        return '📺';
      case VisionnageMatch.bar:
        return '🍺';
      case VisionnageMatch.stade:
        return '🏟️';
    }
  }

  String get label {
    switch (this) {
      case VisionnageMatch.tele:
        return translate.tele;
      case VisionnageMatch.bar:
        return translate.bar;
      case VisionnageMatch.stade:
        return translate.stade;
    }
  }

  String get labelFR {
    switch (this) {
      case VisionnageMatch.tele:
        return "Télé";
      case VisionnageMatch.bar:
        return "Bar";
      case VisionnageMatch.stade:
        return "Stade";
    }
  }

  static VisionnageMatch? fromString(String value) {
    if (value == translate.tele) {
      return VisionnageMatch.tele;
    }
    if (value == translate.bar) {
      return VisionnageMatch.bar;
    }
    if (value == translate.stade) {
      return VisionnageMatch.stade;
    }
    return null;
  }
}
