import 'package:flutter/material.dart';
import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/post/match_regarde_ami.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/widgets/fil_actu_amis/match_regarde_amis_list.dart';

/// Onglet "Mes amis" dans MatchDetailsPage
/// Requete le repository pour récupérer la liste des MatchRegardeAmi pour ce matchId,
/// puis affiche MatchRegardeAmiListView(entries: ...).
class MesAmisTab extends StatefulWidget {
  final String matchId;

  const MesAmisTab({super.key, required this.matchId});

  @override
  State<MesAmisTab> createState() => _MesAmisTabState();
}

class _MesAmisTabState extends State<MesAmisTab> {
  bool _isLoading = true;
  bool _isError = false;
  List<MatchRegardeAmi> _entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _isError = false;
      _entries = [];
    });

    try {
      final user = await RepositoryProvider.userRepository.getCurrentUser();
      if (!mounted) return;
      if (user == null) {
        setState(() {
          _entries = [];
          _isLoading = false;
        });
        return;
      }

      final List<UserMatchEntry> repoEntries = await RepositoryProvider
          .postRepository
          .fetchFriendsMatchUserDataForMatch(widget.matchId, user.uid);

      if (!mounted) return;

      final mvpIds = repoEntries
          .map((e) => e.matchData.mvpVoteId)
          .whereType<String>()
          .toSet()
          .toList();

      final Map<String, String> mvpNameById = {};
      if (mvpIds.isNotEmpty) {
        final joueurRepo = RepositoryProvider.joueurRepository;
        final mvpFutures = mvpIds.map((id) => joueurRepo.fetchJoueurById(id));
        final joueurs = await Future.wait(mvpFutures);
        for (var i = 0; i < mvpIds.length; i++) {
          final joueur = joueurs[i];
          if (joueur != null) {
            mvpNameById[mvpIds[i]] = joueur.fullName;
          }
        }
      }

      final enriched = repoEntries.map((r) {
        final mvpName = r.matchData.mvpVoteId != null
            ? mvpNameById[r.matchData.mvpVoteId!]
            : null;
        return MatchRegardeAmi(
          friend: r.user,
          matchData: r.matchData,
          mvpName: mvpName,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _entries = enriched;
        _isLoading = false;
      });
    } catch (e, st) {
      debugPrint('Erreur MesAmisTab._load: $e\n$st');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: ColorPalette.pictureBackground(context)),
            const SizedBox(height: 12),
            Text(
              "Impossible de charger la liste des amis.",
              style: TextStyle(color: ColorPalette.textSecondary(context)),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
          ],
        ),
      );
    }

    return MatchRegardeAmiListView(
      entries: _entries,
      shrinkWrap: false,
      onRefresh: _onRefresh,
      matchDetails: false,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
}
