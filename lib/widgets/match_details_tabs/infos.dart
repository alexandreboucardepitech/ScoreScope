import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/widgets/match_details_tabs/mvp_vote_bottom_sheet.dart';
import 'package:scorescope/widgets/match_details_tabs/mvp_card.dart';
import 'package:scorescope/widgets/match_details_tabs/match_rating_card.dart';
import '../../../models/match.dart';

class InfosTab extends StatefulWidget {
  final Match match;
  const InfosTab({super.key, required this.match});

  @override
  State<InfosTab> createState() => _InfosTabState();
}

class _InfosTabState extends State<InfosTab> {
  Joueur? currentMvp;
  bool _loadingMvp = false;

  @override
  void initState() {
    super.initState();
    _loadMvp(); // lance l'opération asynchrone sans rendre initState async
  }

  Future<void> _loadMvp() async {
    setState(() => _loadingMvp = true);
    try {
      final mvp = await widget.match.getMvp();
      if (!mounted) return;
      setState(() {
        currentMvp = mvp;
      });
    } catch (e) {
      // optionnel : logger l'erreur
      debugPrint('Erreur lors du chargement du MVP: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loadingMvp = false);
    }
  }

  Future<void> _onPlusPressed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // utilisateur non connecté — si besoin afficher message
      return;
    }
    final userId = user.uid;

    // ouvre la bottom sheet et attend la sélection
    final Joueur? newJoueurSelected = await showVoteBottomSheet(
      context: context,
      match: widget.match,
      initialUserVote: currentMvp,
    );

    if (newJoueurSelected != null) {
      widget.match.voterPourMVP(userId: userId, joueurId: newJoueurSelected.id);
    } else {
      widget.match.enleverVote(userId: userId);
    }

    // recharger le MVP (ou recalculer localement si tu as l'info)
    await _loadMvp();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          MatchRatingCard(
            noteMoyenne: widget.match.getNoteMoyenne(),
            onChanged: (nouvelleValeur) {},
            onConfirm: (valeurConfirmee) async {
              final uid = FirebaseAuth.instance.currentUser!.uid;
              widget.match.noterMatch(userId: uid, note: valeurConfirmee);
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          // Si tu veux afficher un loader pour le MVP, utilise _loadingMvp
          _loadingMvp
              ? const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                )
              : MvpCard(
                  mvp: currentMvp,
                  userVote: currentMvp,
                  onVotePressed: _onPlusPressed,
                ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
