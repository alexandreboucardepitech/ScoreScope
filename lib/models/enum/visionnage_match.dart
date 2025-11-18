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
        return 'Télé';
      case VisionnageMatch.bar:
        return 'Bar';
      case VisionnageMatch.stade:
        return 'Stade';
    }
  }

  static VisionnageMatch? fromString(String value) {
    switch (value) {
      case 'Télé':
        return VisionnageMatch.tele;
      case 'Bar':
        return VisionnageMatch.bar;
      case 'Stade':
        return VisionnageMatch.stade;
    }
    return null;
  }
}
