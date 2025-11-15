String normalize(String s) {
  final map = <String, String>{
    'à': 'a', 'á': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a',
    'ç': 'c',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ÿ': 'y', 'ñ': 'n'
  };
  var out = s.toLowerCase().trim();
  map.forEach((k, v) => out = out.replaceAll(k, v));
  return out;
}