import 'package:flutter/material.dart';
import 'package:scorescope/models/post/commentaire.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsPreview extends StatelessWidget {
  final List<Commentaire> comments;
  final Map<String, String> userNamesCache;
  final VoidCallback onSeeAll;

  const CommentsPreview({
    required this.comments,
    required this.userNamesCache,
    required this.onSeeAll,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text('Soyez le premier à commenter',
            style: TextStyle(color: ColorPalette.textSecondary(context))),
      );
    }

    final preview = comments.take(2).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          for (final c in preview)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorPalette.border(context)),
                    alignment: Alignment.center,
                    child: Text(
                      (userNamesCache[c.authorId]?.isNotEmpty == true
                          ? userNamesCache[c.authorId]![0].toUpperCase()
                          : c.authorId.isNotEmpty
                              ? c.authorId[0].toUpperCase()
                              : '?'),
                      style: TextStyle(
                          color: ColorPalette.textPrimary(context),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                  userNamesCache[c.authorId] ?? c.authorId,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: ColorPalette.textPrimary(context),
                                      fontSize: 13)),
                            ),
                            const SizedBox(width: 8),
                            Text(timeago.format(c.createdAt, locale: 'fr'),
                                style: TextStyle(
                                    color: ColorPalette.textSecondary(context),
                                    fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(c.text,
                            style: TextStyle(
                                color: ColorPalette.textPrimary(context))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (comments.length > 2)
            GestureDetector(
              onTap: onSeeAll,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Voir les ${comments.length} commentaires',
                      style: TextStyle(color: ColorPalette.accent(context))),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
