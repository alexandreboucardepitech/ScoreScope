import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:shimmer/shimmer.dart';

class CompetitionsPreferees extends StatefulWidget {
  final List<String>? competitionsId;
  final AppUser user;
  final bool isLoading;
  final bool isMe;
  final bool displayTitle;
  final void Function(String competitionId, String competitionName)?
      onCompetitionTap;

  const CompetitionsPreferees({
    super.key,
    required this.competitionsId,
    required this.user,
    required this.isMe,
    this.isLoading = false,
    this.displayTitle = true,
    this.onCompetitionTap,
  });

  @override
  State<CompetitionsPreferees> createState() => _CompetitionsPrefereesState();
}

class _CompetitionsPrefereesState extends State<CompetitionsPreferees> {
  final competitionsRepo = RepositoryProvider.competitionRepository;
  final userRepo = RepositoryProvider.userRepository;

  // cache séparé pour les compétitions et pour le nombre de matchs
  final Map<String, Competition?> _loadedCompetition = {};
  final Map<String, int?> _loadedNbMatchs = {};

  // sets pour éviter de lancer plusieurs fetchs simultanés
  final Set<String> _fetchingCompetition = {};
  final Set<String> _fetchingNb = {};

  @override
  void didUpdateWidget(covariant CompetitionsPreferees oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureFetch();
  }

  @override
  void initState() {
    super.initState();
    _ensureFetch();
  }

  void _ensureFetch() {
    final ids = widget.competitionsId ?? [];

    // lancer fetch compétition si nécessaire
    for (final id in ids) {
      if (!_loadedCompetition.containsKey(id) &&
          !_fetchingCompetition.contains(id)) {
        _fetchCompetition(id);
      }
      if (!_loadedNbMatchs.containsKey(id) && !_fetchingNb.contains(id)) {
        _fetchNbMatchsParCompetition(id);
      }
    }

    // cleanup : retirer les clés qui ne sont plus présentes
    _loadedCompetition.keys
        .where((k) => !ids.contains(k))
        .toList()
        .forEach(_loadedCompetition.remove);
    _loadedNbMatchs.keys
        .where((k) => !ids.contains(k))
        .toList()
        .forEach(_loadedNbMatchs.remove);
  }

  Future<void> _fetchCompetition(String id) async {
    _fetchingCompetition.add(id);
    setState(() {
      _loadedCompetition.putIfAbsent(id, () => null); // placeholder
    });
    try {
      final competition = await competitionsRepo.fetchCompetitionById(id);
      if (!mounted) return;
      setState(() {
        _loadedCompetition[id] = competition;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadedCompetition[id] =
            null; // erreur -> on garde null pour indiquer l'échec
      });
    } finally {
      _fetchingCompetition.remove(id);
    }
  }

  Future<void> _fetchNbMatchsParCompetition(String competitionId) async {
    _fetchingNb.add(competitionId);
    setState(() {
      _loadedNbMatchs.putIfAbsent(competitionId, () => null); // placeholder
    });
    try {
      final nb = await userRepo.getUserNbMatchsRegardesParCompetition(
        widget.user.uid,
        competitionId,
        widget.isMe ? false : true,
      );
      if (!mounted) return;
      setState(() {
        _loadedNbMatchs[competitionId] = nb;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadedNbMatchs[competitionId] =
            0; // ou null selon ce que tu préfères afficher en erreur
      });
    } finally {
      _fetchingNb.remove(competitionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildGlobalShimmer();
    }

    final ids = widget.competitionsId ?? [];

    final display = ids.toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.displayTitle) ...[
          Text(
            'Compétitions préférées',
            style: TextStyle(
              color: ColorPalette.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (display.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: display.map((teamId) {
              final competition = _loadedCompetition[teamId];
              final nbMatchs = _loadedNbMatchs[teamId];

              if (competition == null) return const _CompetitionCellShimmer();

              return SizedBox(
                width: (MediaQuery.of(context).size.width - 16 * 2 - 8) / 2,
                height: 80,
                child: CompetitionPrefereeTile(
                  competition: competition,
                  user: widget.user,
                  nbMatchsRegardes: nbMatchs,
                  onTap: widget.onCompetitionTap,
                ),
              );
            }).toList(),
          )
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                "Aucune compétition préférée",
                style: TextStyle(
                  color: ColorPalette.textSecondary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildGlobalShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Shimmer.fromColors(
        baseColor: ColorPalette.shimmerPrimary(context),
        highlightColor: ColorPalette.shimmerSecondary(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 16,
              width: 160,
              color: ColorPalette.surface(context),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              itemCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (_, __) => const _CompetitionCellShimmer(),
            ),
          ],
        ),
      ),
    );
  }
}

// tuile shimmer inchangée
class _CompetitionCellShimmer extends StatelessWidget {
  const _CompetitionCellShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ColorPalette.surface(context),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorPalette.pictureBackground(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 12,
              color: ColorPalette.pictureBackground(context),
            ),
          ),
        ],
      ),
    );
  }
}

class CompetitionPrefereeTile extends StatelessWidget {
  final Competition competition;
  final AppUser user;
  final int? nbMatchsRegardes;
  final void Function(String teamId, String teamName)? onTap;

  const CompetitionPrefereeTile({
    super.key,
    required this.competition,
    required this.user,
    this.nbMatchsRegardes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!(competition.id, competition.nom);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: ColorPalette.tileSelected(context),
          border:
              Border.all(color: ColorPalette.accentVariant(context), width: 3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (competition.logoUrl != null)
              SizedBox(
                  width: 32,
                  height: 32,
                  child: Image.asset(competition.logoUrl!, fit: BoxFit.contain))
            else
              CircleAvatar(radius: 14, child: Icon(Icons.shield, size: 16)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      competition.nom,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ColorPalette.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (nbMatchsRegardes == null)
                    SizedBox(
                      width: 80,
                      height: 14,
                      child: Shimmer.fromColors(
                        baseColor: ColorPalette.shimmerPrimary(context),
                        highlightColor: ColorPalette.shimmerSecondary(context),
                        child: Container(
                          color: ColorPalette.surface(context),
                        ),
                      ),
                    )
                  else
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$nbMatchsRegardes matchs regardés',
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorPalette.textSecondary(context),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
