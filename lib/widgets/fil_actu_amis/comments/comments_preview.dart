import 'package:flutter/material.dart';
import 'package:scorescope/models/post/commentaire.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:scorescope/views/profile/profile.dart';

class CommentsPreview extends StatelessWidget {
  final List<Commentaire> comments;
  final Map<String, AppUser?> userCache; // map d'AppUser (nullable)
  final VoidCallback onSeeAll;
  final Future<void> Function() onProfileUpdated;

  const CommentsPreview({
    required this.comments,
    required this.userCache,
    required this.onSeeAll,
    required this.onProfileUpdated,
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final preview = comments.take(3).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final c in preview)
            // Material + InkWell pour que la ligne entière soit cliquable
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap:
                      onSeeAll, // tap sur la ligne -> voir tous les commentaires
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // avatar (clicable pour ouvrir le profil)
                      GestureDetector(
                        onTap: () async {
                          AppUser? profile = userCache[c.authorId];
                          if (profile == null) {
                            try {
                              profile = await RepositoryProvider.userRepository
                                  .fetchUserById(c.authorId);
                              userCache[c.authorId] = profile;
                            } catch (_) {
                              profile = null;
                              userCache[c.authorId] = null;
                            }
                          }

                          if (profile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Utilisateur introuvable')),
                            );
                            return;
                          }

                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileView(
                                user: profile!,
                                onBackPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                              ),
                            ),
                          );
                          if (result == true) {
                            await onProfileUpdated();
                          }
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorPalette.border(context),
                            image: userCache[c.authorId]?.photoUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(
                                        userCache[c.authorId]!.photoUrl!),
                                    fit: BoxFit.cover)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: userCache[c.authorId]?.photoUrl == null
                              ? Text(
                                  (userCache[c.authorId]
                                              ?.displayName
                                              ?.isNotEmpty ==
                                          true
                                      ? userCache[c.authorId]!
                                          .displayName![0]
                                          .toUpperCase()
                                      : c.authorId.isNotEmpty
                                          ? c.authorId[0].toUpperCase()
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
                            // ligne avec nom + timestamp collé (pas à droite)
                            Row(
                              children: [
                                // Nom (clicable) — Flexible pour ellipsize sans pousser l'heure
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () async {
                                      AppUser? profile = userCache[c.authorId];
                                      if (profile == null) {
                                        try {
                                          profile = await RepositoryProvider
                                              .userRepository
                                              .fetchUserById(c.authorId);
                                          userCache[c.authorId] = profile;
                                        } catch (_) {
                                          profile = null;
                                          userCache[c.authorId] = null;
                                        }
                                      }

                                      if (profile == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Utilisateur introuvable')),
                                        );
                                        return;
                                      }

                                      final result =
                                          await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ProfileView(
                                            user: profile!,
                                            onBackPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        await onProfileUpdated();
                                      }
                                    },
                                    child: Text(
                                      userCache[c.authorId]?.displayName ??
                                          c.authorId,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color:
                                              ColorPalette.textPrimary(context),
                                          fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // timestamp collé au nom
                                Text(
                                  timeago.format(c.createdAt, locale: 'fr'),
                                  style: TextStyle(
                                      color:
                                          ColorPalette.textSecondary(context),
                                      fontSize: 11),
                                ),
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
              ),
            ),

          // petit texte léger cliquable pour voir tous les commentaires
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              onPressed: onSeeAll,
              child: Text(
                comments.length > 3
                    ? 'Voir tous les ${comments.length} commentaires'
                    : 'Voir tous les commentaires',
                style: TextStyle(
                  color: ColorPalette.textSecondary(context),
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
