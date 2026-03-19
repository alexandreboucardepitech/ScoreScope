Map<String, String> parseStringMap(dynamic value) {
  if (value == null) return {};

  if (value is Map) {
    return Map<String, String>.from(value);
  }

  if (value is List) {
    if (value.isEmpty) {
      return {}; // cas Firebase qui renvoie []
    } else {
      return parseStringMap(value[0]);
    }
  }

  throw Exception(
      "Type invalide pour Map<String,String>: ${value.runtimeType}");
}

Map<String, int> parseIntMap(dynamic value) {
  if (value == null) return {};

  if (value is Map) {
    return Map<String, int>.from(value);
  }

  if (value is List) {
    if (value.isEmpty) {
      return {};
    } else {
      return parseIntMap(value[0]);
    }
  }

  throw Exception("Type invalide pour Map<String,int>: ${value.runtimeType}");
}
