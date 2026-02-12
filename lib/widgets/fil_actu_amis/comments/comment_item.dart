import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/post/commentaire.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/profile/profile.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItem extends StatelessWidget {
  final Commentaire comment;
  final AppUser? user;
  final VoidCallback onProfileUpdated;

  const CommentItem({
    required this.comment,
    required this.user,
    required this.onProfileUpdated,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            if (user == null) return;

            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfileView(
                  user: user!,
                  onBackPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ),
            );
            if (result == true) {
              onProfileUpdated();
            }
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorPalette.border(context),
              image: user?.photoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(user!.photoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: user?.photoUrl == null
                ? Text(
                    (user?.displayName.isNotEmpty == true
                        ? user!.displayName[0].toUpperCase()
                        : '?'),
                    style: TextStyle(
                        color: ColorPalette.textPrimary(context),
                        fontWeight: FontWeight.bold),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: () async {
                        if (user == null) return;

                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfileView(
                              user: user!,
                              onBackPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ),
                        );
                        if (result == true) {
                          onProfileUpdated();
                        }
                      },
                      child: Text(
                        user?.displayName ?? comment.authorId,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: ColorPalette.textPrimary(context),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeago.format(comment.createdAt, locale: 'fr'),
                    style: TextStyle(
                      color: ColorPalette.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.text,
                style: TextStyle(color: ColorPalette.textPrimary(context)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
