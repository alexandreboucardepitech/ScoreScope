int getPosFromString(String posString, bool getMainPos) {
  List<String> split = posString.split(':');
  if (split.length != 2) {
    return -1;
  }
  if (getMainPos) {
    return int.tryParse(split[0]) ?? -1;
  } else {
    return int.tryParse(split[1]) ?? -1;
  }
}
