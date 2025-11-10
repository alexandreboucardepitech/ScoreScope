import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/services/repository_provider.dart';

class EquipesPreferees extends StatefulWidget {
  final List<String>? teamsId;
  final bool isLoading; // true => on charge les ids
  const EquipesPreferees(
      {super.key, required this.teamsId, this.isLoading = false});

  @override
  State<EquipesPreferees> createState() => _EquipesPrefereesState();
}

class _EquipesPrefereesState extends State<EquipesPreferees> {
  final equipesRepo = RepositoryProvider.equipeRepository;

  final Map<String, Equipe?> _loaded = {};

  final Set<String> _fetching = {};

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
    for (final id in ids) {
      if (_loaded.containsKey(id) || _fetching.contains(id)) continue;
      _fetchEquipe(id);
    }
    _loaded.keys
        .where((k) => !ids.contains(k))
        .toList()
        .forEach(_loaded.remove);
  }

  Future<void> _fetchEquipe(String id) async {
    _fetching.add(id);
    setState(() {
      _loaded.putIfAbsent(id, () => null);
    });
    try {
      final equipe = await equipesRepo.fetchEquipeById(id);
      if (!mounted) return;
      setState(() {
        _loaded[id] = equipe;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loaded[id] = null;
      });
    } finally {
      _fetching.remove(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildGlobalShimmer();
    }

    final ids = widget.teamsId ?? [];
    if (ids.isEmpty) {
      return const SizedBox.shrink();
    }

    final display = ids.take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Équipes préférées'),
            if (ids.length > 6)
              TextButton(onPressed: () {}, child: const Text('Voir tout'))
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          itemCount: display.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 5,
          ),
          itemBuilder: (ctx, i) {
            final teamId = display[i];
            final equipe = _loaded[teamId];

            // Si equipe == null et _fetching contient teamId => en cours : afficher cellule shimmer
            // Si equipe == null et !fetching => échec ou pas encore lancé : aussi shimmer ou message d'erreur
            if (equipe == null) {
              return _EquipeCellShimmer();
            }

            return EquipePrefereeTile(equipe: equipe);
          },
        ),
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
                childAspectRatio: 5,
              ),
              itemBuilder: (_, __) => _EquipeCellShimmer(),
            ),
          ],
        ),
      ),
    );
  }
}

// Petite tuile shimmer pour une cellule
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

// Tuile qui affiche l'équipe une fois chargée
class EquipePrefereeTile extends StatelessWidget {
  final Equipe equipe;
  const EquipePrefereeTile({super.key, required this.equipe});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {}, // ouvrir page équipe, etc.
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).cardColor,
        ),
        child: Row(
          children: [
            if (equipe.logoPath != null)
              SizedBox(
                width: 24,
                height: 24,
                child: Image.asset(
                  equipe.logoPath!,
                  fit: BoxFit.contain,
                ),
              )
            else
              const CircleAvatar(radius: 12, child: Icon(Icons.shield)),
            const SizedBox(width: 8),
            Expanded(child: Text(equipe.nom, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
