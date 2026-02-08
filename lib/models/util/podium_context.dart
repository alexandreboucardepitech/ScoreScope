
class PodiumContext {
  final int rank;
  final num value;
  final String? color;

  const PodiumContext({
    required this.rank,
    required this.value,
    this.color,
  });

  bool get isFirst => rank == 1;
}
