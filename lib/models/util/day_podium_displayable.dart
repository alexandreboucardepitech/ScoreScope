import 'package:intl/intl.dart';
import 'package:scorescope/models/util/podium_displayable.dart';

class DayPodiumDisplayable implements PodiumDisplayable {
  final DateTime day;

  DayPodiumDisplayable(this.day);

  @override
  String? get displayImage => null;

  @override
  String get displayLabel => DateFormat.yMd().format(day);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayPodiumDisplayable &&
          day.year == other.day.year &&
          day.month == other.day.month &&
          day.day == other.day.day;

  @override
  int get hashCode => Object.hash(day.year, day.month, day.day);
}
