class Emoji {
  final String emoji;
  final String name;
  final String category;
  final String subcategory;
  final List<String> variantEmojis;

  Emoji({
    required this.emoji,
    required this.name,
    required this.category,
    required this.subcategory,
    List<String>? variantEmojis,
  }) : variantEmojis = variantEmojis ?? [];
}
