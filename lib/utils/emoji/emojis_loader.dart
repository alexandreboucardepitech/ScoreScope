import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:scorescope/models/util/emoji.dart';

class EmojiLoader {
  static Map<String, dynamic>? _rawEmojis;
  static bool _loaded = false;

  static Map<String, List<Map<String, dynamic>>> _groupsByBase = {};
  static List<String> _orderedBaseCodes = [];

  static Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final data = await rootBundle.loadString('assets/util/emojis.json');
    final Map<String, dynamic> jsonMap = jsonDecode(data);
    _rawEmojis = jsonMap['emojis'] as Map<String, dynamic>;

    _groupsByBase = {};
    _orderedBaseCodes = [];

    // Parcours pour construire _groupsByBase et préserver l'ordre d'apparition
    for (final categoryEntry in _rawEmojis!.entries) {
      final category = categoryEntry.key;
      final subcats = categoryEntry.value as Map<String, dynamic>;
      for (final subEntry in subcats.entries) {
        final subcategory = subEntry.key;
        final list = (subEntry.value as List<dynamic>);
        for (final rawItem in list) {
          final item = rawItem as Map<String, dynamic>;
          final codes = (item['code'] as List).cast<String>();
          if (codes.isEmpty) continue;
          final baseCode = codes[0].toUpperCase();

          item['__category'] = category;
          item['__subcategory'] = subcategory;

          final group = _groupsByBase.putIfAbsent(baseCode, () => []);
          group.add(item);

          if (!_orderedBaseCodes.contains(baseCode)) {
            _orderedBaseCodes.add(baseCode);
          }
        }
      }
    }

    _loaded = true;
  }

  static Emoji _buildEmojiFromGroup(List<Map<String, dynamic>> group) {
    Map<String, dynamic>? mainEntry;
    for (final it in group) {
      final codes = (it['code'] as List).cast<String>();
      if (codes.length == 1) {
        mainEntry = it;
        break;
      }
    }
    mainEntry ??= group.first;

    final mainEmoji = mainEntry['emoji'] as String;
    final mainName = mainEntry['name'] as String;
    final category = mainEntry['__category'] as String? ?? '';
    final subcategory = mainEntry['__subcategory'] as String? ?? '';

    final List<String> variantEmojis = [];
    for (final it in group) {
      final emo = it['emoji'] as String;
      if (emo != mainEmoji) variantEmojis.add(emo);
    }

    return Emoji(
      emoji: mainEmoji,
      name: mainName,
      category: category,
      subcategory: subcategory,
      variantEmojis: variantEmojis,
    );
  }

  static Future<List<Emoji>> fetchChunk({
    required int offset,
    required int limit,
    String? query,
  }) async {
    await _ensureLoaded();
    final q = (query ?? '').trim().toLowerCase();

    final List<Emoji> result = [];
    int taken = 0;

    for (int i = 0; i < _orderedBaseCodes.length; i++) {
      final baseCode = _orderedBaseCodes[i];
      final group = _groupsByBase[baseCode]!;
      final temp = _buildEmojiFromGroup(group);
      final matchesQuery = q.isEmpty ||
          temp.name.toLowerCase().contains(q) ||
          temp.category.toLowerCase().contains(q) ||
          temp.subcategory.toLowerCase().contains(q);
      if (!matchesQuery) continue;

      if (offset > 0) {
        offset--;
        continue;
      }

      result.add(temp);
      taken++;
      if (taken >= limit) break;
    }

    return result;
  }

  static Future<int> countMatching(String? query) async {
    await _ensureLoaded();
    final q = (query ?? '').trim().toLowerCase();
    if (q.isEmpty) {
      return _orderedBaseCodes.length;
    } else {
      int total = 0;
      for (final baseCode in _orderedBaseCodes) {
        final group = _groupsByBase[baseCode]!;
        final temp = _buildEmojiFromGroup(group);
        if (temp.name.toLowerCase().contains(q) ||
            temp.category.toLowerCase().contains(q) ||
            temp.subcategory.toLowerCase().contains(q)) {
          total++;
        }
      }
      return total;
    }
  }

  static void clearCache() {
    _rawEmojis = null;
    _loaded = false;
    _groupsByBase = {};
    _orderedBaseCodes = [];
  }
}
