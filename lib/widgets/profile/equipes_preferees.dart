import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/couleur_from_hexa.dart';
import 'package:shimmer/shimmer.dart';

class EquipesPreferees extends StatefulWidget {
  final List<String>? teamsId;
  final AppUser user;
  final bool isLoading;
  const EquipesPreferees(
      {super.key,
      required this.teamsId,
      required this.user,
      this.isLoading = false});

  @override
  State<EquipesPreferees> createState() => _EquipesPrefereesState();
}

class _EquipesPrefereesState extends State<EquipesPreferees> {
  final equipesRepo = RepositoryProvider.equipeRepository;
  final userRepo = RepositoryProvider.userRepository;

  // cache séparé pour les équipes et pour le nombre de matchs
  final Map<String, Equipe?> _loadedEquipe = {};
  final Map<String, int?> _loadedNbMatchs = {};

  // sets pour éviter de lancer plusieurs fetchs simultanés
  final Set<String> _fetchingEquipe = {};
  final Set<String> _fetchingNb = {};

  @override
  void didUpdateWidget(covariant EquipesPreferees oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureFetch();
  }

  @override
  void initState() {
    super.initState();
    _ensureFetch();
  }

  void _ensureFetch() {
    final ids = widget.teamsId ?? [];

    // lancer fetch équipe si nécessaire
    for (final id in ids) {
      if (!_loadedEquipe.containsKey(id) && !_fetchingEquipe.contains(id)) {
        _fetchEquipe(id);
      }
      if (!_loadedNbMatchs.containsKey(id) && !_fetchingNb.contains(id)) {
        _fetchNbMatchsParEquipe(id);
      }
    }

    // cleanup : retirer les clés qui ne sont plus présentes
    _loadedEquipe.keys
        .where((k) => !ids.contains(k))
        .toList()
        .forEach(_loadedEquipe.remove);
    _loadedNbMatchs.keys
        .where((k) => !ids.contains(k))
        .toList()
        .forEach(_loadedNbMatchs.remove);
  }

  Future<void> _fetchEquipe(String id) async {
    _fetchingEquipe.add(id);
    setState(() {
      _loadedEquipe.putIfAbsent(id, () => null); // placeholder
    });
    try {
      final equipe = await equipesRepo.fetchEquipeById(id);
      if (!mounted) return;
      setState(() {
        _loadedEquipe[id] = equipe;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadedEquipe[id] =
            null; // erreur -> on garde null pour indiquer l'échec
      });
    } finally {
      _fetchingEquipe.remove(id);
    }
  }

  Future<void> _fetchNbMatchsParEquipe(String equipeId) async {
    _fetchingNb.add(equipeId);
    setState(() {
      _loadedNbMatchs.putIfAbsent(equipeId, () => null); // placeholder
    });
    try {
      final nb = await userRepo.getUserNbMatchsRegardesParEquipe(
          widget.user.uid, equipeId);
      if (!mounted) return;
      setState(() {
        _loadedNbMatchs[equipeId] = nb;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadedNbMatchs[equipeId] =
            0; // ou null selon ce que tu préfères afficher en erreur
      });
    } finally {
      _fetchingNb.remove(equipeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildGlobalShimmer();
    }

    final ids = widget.teamsId ?? [];
    if (ids.isEmpty) return const SizedBox.shrink();

    final display = ids.toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Équipes préférées'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: display.map((teamId) {
            final equipe = _loadedEquipe[teamId];
            final nbMatchs = _loadedNbMatchs[teamId];

            if (equipe == null) return const _EquipeCellShimmer();

            return SizedBox(
              width: (MediaQuery.of(context).size.width - 16 * 2 - 8) / 2,
              child: EquipePrefereeTile(
                equipe: equipe,
                user: widget.user,
                nbMatchsRegardes: nbMatchs,
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _buildGlobalShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 16, width: 160, color: Colors.white),
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
              itemBuilder: (_, __) => const _EquipeCellShimmer(),
            ),
          ],
        ),
      ),
    );
  }
}

// tuile shimmer inchangée
class _EquipeCellShimmer extends StatelessWidget {
  const _EquipeCellShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).cardColor,
      ),
      child: Row(
        children: [
          Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 12, color: Colors.white)),
        ],
      ),
    );
  }
}

// Tuile qui affiche l'équipe une fois chargée (nbMatchsRegardes peut être null si encore en cours)
class EquipePrefereeTile extends StatelessWidget {
  final Equipe equipe;
  final AppUser user;
  final int? nbMatchsRegardes;

  const EquipePrefereeTile({
    super.key,
    required this.equipe,
    required this.user,
    this.nbMatchsRegardes,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = equipe.couleurPrincipale != null
        ? fromHex(equipe.couleurPrincipale!)
        : Theme.of(context).cardColor;
    final Color secondary = equipe.couleurSecondaire != null
        ? fromHex(equipe.couleurSecondaire!)
        : Colors.grey;

    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: primary,
          border: Border.all(color: secondary, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (equipe.logoPath != null)
              SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(equipe.logoPath!, fit: BoxFit.contain))
            else
              const CircleAvatar(radius: 12, child: Icon(Icons.shield)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    equipe.nom,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: secondary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  // si nbMatchsRegardes == null -> petit shimmer local
                  if (nbMatchsRegardes == null)
                    SizedBox(
                      width: 80,
                      height: 12,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      ),
                    )
                  else
                    Text(
                      '$nbMatchsRegardes matchs regardés',
                      style: TextStyle(
                          fontSize: 12, color: secondary.withOpacity(0.9)),
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
