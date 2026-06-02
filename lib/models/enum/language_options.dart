enum LanguageOptions {
  french('Français', 'FR'),
  english('English', 'EN');

  final String displayName;
  final String code;

  const LanguageOptions(this.displayName, this.code);

  static LanguageOptions? fromString(String? value) {
    switch (value) {
      case 'french':
      case 'FR':
        return LanguageOptions.french;
      case 'english':
      case 'EN':
        return LanguageOptions.english;
      default:
        return null;
    }
  }
}
