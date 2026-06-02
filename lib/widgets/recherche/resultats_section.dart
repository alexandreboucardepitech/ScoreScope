import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/utils/translate/language_controller.dart';

class ResultatsSection<T> extends StatelessWidget {
  const ResultatsSection({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.onLoadMore,
  });

  final String title;
  final List<T> items;
  final Widget Function(T item) itemBuilder;

  final bool hasMore;

  final bool isLoadingMore;

  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 6),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorPalette.accent(context),
              letterSpacing: 0.2,
            ),
          ),
        ),
        ...items.map(itemBuilder),
        if (hasMore || isLoadingMore)
          _LoadMoreFooter(
            isLoading: isLoadingMore,
            onTap: isLoadingMore ? null : onLoadMore,
          ),
      ],
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({
    required this.isLoading,
    this.onTap,
  });

  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: ColorPalette.border(context),
                width: 0.5,
              ),
            ),
          ),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColorPalette.accent(context),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      translate.voirPlus,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ColorPalette.accent(context),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: ColorPalette.accent(context),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
