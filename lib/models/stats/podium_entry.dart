import 'package:scorescope/models/util/podium_displayable.dart';

class PodiumEntry<T extends PodiumDisplayable> {
  final T item;
  final num value;

  const PodiumEntry({
    required this.item,
    required this.value,
  });
}