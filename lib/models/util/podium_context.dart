import 'package:flutter/material.dart';

class PodiumContext {
  final int rank;
  final num value;
  final Color? accent;

  const PodiumContext({
    required this.rank,
    required this.value,
    this.accent,
  });

  bool get isFirst => rank == 1;
}
