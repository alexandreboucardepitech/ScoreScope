enum LanguageOptions {
  french('Français'),
  english('English');

  final String displayName;

  const LanguageOptions(this.displayName);
  
  static LanguageOptions? fromString(String? value) {
    switch (value) {
      case 'french':
        return LanguageOptions.french;
      case 'english':
        return LanguageOptions.english;
      default:
        return null;
    }
  }
}
