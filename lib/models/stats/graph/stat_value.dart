class StatValue {
  final String label;
  final num value;
  final String? color;
  final String? image;

  const StatValue({
    required this.label,
    required this.value,
    this.color,
    this.image,
  });
}
