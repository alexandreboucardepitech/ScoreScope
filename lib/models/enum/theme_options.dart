enum ThemeOptions {
  system('Système'),
  light('Clair'),
  dark('Sombre');

  final String displayName;

  const ThemeOptions(this.displayName);
  
  static ThemeOptions? fromString(String? value) {
    switch (value) {
      case 'system':
        return ThemeOptions.system;
      case 'light':
        return ThemeOptions.light;
      case 'dark':
        return ThemeOptions.dark;
      default:
        return null;
    }
  }
}