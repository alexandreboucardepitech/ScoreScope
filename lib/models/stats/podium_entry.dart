import 'package:scorescope/models/util/podium_displayable.dart';

class PodiumEntry<T extends PodiumDisplayable> {
  final T item;
  final num value;
  final String? color;

  const PodiumEntry({
    required this.item,
    required this.value,
    this.color,
  });
}