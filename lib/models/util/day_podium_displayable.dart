import 'package:intl/intl.dart';
import 'package:scorescope/models/util/basic_podium_displayable.dart';

class DayPodiumDisplayable extends BasicPodiumDisplayable {
  final DateTime day;

  DayPodiumDisplayable(this.day);

  @override
  String? get displayImage => null;

  @override
  String get displayLabel => DateFormat.yMd().format(day);

  @override
  Future<String?> getColor() async {
    return null;
  }

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
