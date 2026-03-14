Map<String, String> getFirstAndLastName(
  String? prenom,
  String? nom,
  String? fullName,
) {
  if (prenom != null && nom != null) {
    return {"prenom": prenom, "nom": nom};
  }
  if (prenom != null && nom == null) {
    return {"prenom": prenom, "nom": ''};
  }
  if (prenom == null && nom != null) {
    return {"prenom": '', "nom": nom};
  }
  if (fullName == null) {
    return {"prenom": '', "nom": ''};
  }
  List<String> splitName = fullName.split(' ');
  if (fullName.length > 1) {
    return {"prenom": splitName[0], "nom": splitName.skip(1).join(' ')};
  }
  return {"prenom": fullName[0], "nom": ''};
}
