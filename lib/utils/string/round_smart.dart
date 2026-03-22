String roundSmart(double value) {
  // Si c'est un entier exact, on renvoie tel quel
  if (value % 1 == 0) {
    return value.toStringAsFixed(0);
  }
  // Sinon on arrondit à 2 décimales
  return value.toStringAsFixed(2);
}
