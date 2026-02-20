import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class SegmentedOptionRow<T> extends StatelessWidget {
  final List<T> values;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final Widget Function(T value, bool selected) itemBuilder;

  const SegmentedOptionRow({
    super.key,
    required this.values,
    required this.selectedValue,
    required this.onChanged,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorPalette.highlight(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ColorPalette.border(context),
        ),
      ),
      child: Row(
        children: values.map((value) {
          final selected = value == selectedValue;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? ColorPalette.accent(context)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: itemBuilder(value, selected),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
