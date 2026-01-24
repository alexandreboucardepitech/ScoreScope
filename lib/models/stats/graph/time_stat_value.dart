class TimeStatValue {
  final DateTime period;
  final num value;
  final int? delta;

  const TimeStatValue({
    required this.period,
    required this.value,
    this.delta,
  });
}
