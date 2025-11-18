// lib/widgets/mvp_card.dart
import 'package:flutter/material.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import '../../models/joueur.dart';

class MvpCard extends StatefulWidget {
  final Joueur? mvp;
  final Joueur? userVote;
  final VoidCallback? onVotePressed;

  const MvpCard({
    super.key,
    this.mvp,
    this.userVote,
    this.onVotePressed,
  });

  @override
  State<MvpCard> createState() => _MvpCardState();
}

class _MvpCardState extends State<MvpCard> {
  Equipe? mvpEquipe;
  bool _loadingEquipe = false;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadEquipeIfNeeded();
  }

  @override
  void didUpdateWidget(covariant MvpCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si le MVP a changé, recharger l'équipe
    if (widget.mvp?.equipeId != oldWidget.mvp?.equipeId) {
      _loadEquipeIfNeeded();
    }
  }

  Future<void> _loadEquipeIfNeeded() async {
    // Reset state if no mvp
    if (widget.mvp == null) {
      if (mounted) {
        setState(() {
          mvpEquipe = null;
          _loadingEquipe = false;
          _loadError = null;
        });
      }
      return;
    }

    final id = widget.mvp!.equipeId;
    // Si on a déjà l'équipe et que c'est la même, pas besoin de recharger
    if (mvpEquipe != null && mvpEquipe!.id == id) return;

    setState(() {
      _loadingEquipe = true;
      _loadError = null;
    });

    try {
      final e = await RepositoryProvider.equipeRepository.fetchEquipeById(id);
      if (!mounted) return;
      setState(() {
        mvpEquipe = e;
        _loadingEquipe = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _loadingEquipe = false;
        _loadError = err;
      });
    }
  }

  String _initiales(Joueur j) {
    final p = j.prenom.trim();
    final n = j.nom.trim();
    final ip = p.isNotEmpty ? p[0].toUpperCase() : '';
    final iname = n.isNotEmpty ? n[0].toUpperCase() : '';
    final res = (ip + iname);
    return res.isEmpty ? '?' : res;
  }

  Widget _buildAvatar({Joueur? player, double radius = 28}) {
    final picture = player?.picture;
    if (picture != null && picture.isNotEmpty) {
      final provider = picture.startsWith('http')
          ? NetworkImage(picture)
          : AssetImage(picture) as ImageProvider;
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: ClipOval(
            child: Image(
              image: provider,
              fit: BoxFit.cover,
              width: radius * 2,
              height: radius * 2,
            ),
          ),
        ),
      );
    } else if (player != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: ColorPalette.pictureBackground(context),
        child: Text(
          _initiales(player),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorPalette.textPrimary(context),
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: ColorPalette.pictureBackground(context),
        child: Icon(Icons.person, color: ColorPalette.accent(context)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mvp = widget.mvp;
    final hasUserVoted = widget.userVote != null;
    final buttonLabel = hasUserVoted ? 'Changer' : 'Voter';

    return Card(
      color: ColorPalette.tileBackground(context),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MVP du match',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.textPrimary(context),
                  ),
            ),

            const SizedBox(height: 10),

            // LIGNE PRINCIPALE : avatar + infos + bouton
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar du MVP (ou placeholder)
                _buildAvatar(player: mvp, radius: 28),

                const SizedBox(width: 12),

                // Texte (nom / équipe) + info "Votre vote"
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (mvp != null) ...[
                        Text(
                          mvp.fullName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ColorPalette.textAccent(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (_loadingEquipe)
                          Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Chargement équipe...',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: ColorPalette.textSecondary(context),
                                ),
                              ),
                            ],
                          )
                        else if (_loadError != null)
                          Text(
                            'Équipe indisponible',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red,
                            ),
                          )
                        else if (mvpEquipe != null)
                          Text(
                            mvpEquipe!.nom,
                            style: TextStyle(
                              fontSize: 13,
                              color: ColorPalette.textPrimary(context),
                            ),
                          )
                        else
                          Text(
                            'Sois le premier à voter !',
                            style: TextStyle(
                              fontSize: 13,
                              color: ColorPalette.textAccent(context),
                            ),
                          ),
                      ] else ...[
                        Text(
                          'Aucun MVP élu',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ColorPalette.textSecondary(context)),
                        ),
                        Text(
                          'Sois le premier à voter !',
                          style: TextStyle(
                              fontSize: 13,
                              color: ColorPalette.textSecondary(context)),
                        ),
                      ],

                      const SizedBox(height: 6),

                      // Affichage du vote de l'utilisateur (si présent)
                      if (hasUserVoted)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Votre vote : ${widget.userVote!.fullName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: ColorPalette.textSecondary(context),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Bouton Voter / Changer mon vote
                ElevatedButton.icon(
                  onPressed: widget.onVotePressed ?? () {},
                  icon: Icon(hasUserVoted ? Icons.refresh : Icons.how_to_vote,
                      size: 18),
                  label: Text(
                    buttonLabel,
                    style: TextStyle(
                      color: ColorPalette.textPrimary(context),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
