import 'package:scorescope/models/stats/graph/stat_value.dart';

List<StatValue> aggregateSmallValues(List<StatValue> values) {
  if (values.isEmpty) return [];

  final sortedValues = [...values]..sort((a, b) => b.value.compareTo(a.value));

  if (sortedValues.first.value == sortedValues.last.value) return sortedValues;

  final minValue = sortedValues.last.value;

  final topValues = sortedValues.where((v) => v.value > minValue).toList();

  final otherSum = sortedValues
      .where((v) => v.value == minValue)
      .fold<num>(0, (sum, v) => sum + v.value);

  if (otherSum > 0) {
    topValues.add(StatValue(
      label: 'Autres',
      value: minValue,
    ));
  }

  if (otherSum / minValue > 5) {
    return topValues;
  } else {
    return sortedValues;
  }
}
