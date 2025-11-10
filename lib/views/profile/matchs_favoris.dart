import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/services/repository_provider.dart';

class MatchsFavoris extends StatefulWidget {
  final List<String>? matchsFavorisId;
  final bool isLoading; // true = on charge les IDs
  const MatchsFavoris(
      {super.key, required this.matchsFavorisId, this.isLoading = false});

  @override
  State<MatchsFavoris> createState() => _MatchsFavorisState();
}

class _MatchsFavorisState extends State<MatchsFavoris> {
  final matchesRepo = RepositoryProvider.matchRepository;

  final Map<String, Match?> _loaded = {};
  final Set<String> _fetching = {};

  @override
  void initState() {
    super.initState();
    _ensureFetch();
  }

  @override
  void didUpdateWidget(covariant MatchsFavoris oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureFetch();
  }

  void _ensureFetch() {
    final ids = widget.matchsFavorisId ?? [];
    for (final id in ids) {
      if (_loaded.containsKey(id) || _fetching.contains(id)) continue;
      _fetchMatch(id);
    }
    // retirer les IDs qui ne sont plus dans la liste
    _loaded.keys
        .where((k) => !ids.contains(k))
        .toList()
        .forEach(_loaded.remove);
  }

  Future<void> _fetchMatch(String id) async {
    _fetching.add(id);
    setState(() {
      _loaded.putIfAbsent(id, () => null);
    });

    try {
      final match = await matchesRepo.fetchMatchById(id);
      if (!mounted) return;
      setState(() {
        _loaded[id] = match;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loaded[id] = null; // erreur
      });
    } finally {
      _fetching.remove(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return _buildGlobalShimmer();

    final ids = widget.matchsFavorisId ?? [];
    if (ids.isEmpty) return const SizedBox.shrink();

    final display = ids.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Matchs favoris'),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: display.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final match = _loaded[display[i]];
              if (match == null) return const _MatchFavoriShimmer();
              return MatchFavoriCard(match: match);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGlobalShimmer() {
    return SizedBox(
      height: 110,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, __) => const _MatchFavoriShimmer(),
        ),
      ),
    );
  }
}

// Shimmer pour une carte de match favori
class _MatchFavoriShimmer extends StatelessWidget {
  const _MatchFavoriShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 12, color: Colors.white),
          const Spacer(),
          Container(height: 12, width: 80, color: Colors.white),
        ],
      ),
    );
  }
}

// Carte affichant un match favori réel
class MatchFavoriCard extends StatelessWidget {
  final Match match;
  const MatchFavoriCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${match.equipeDomicile.nom} - ${match.equipeExterieur.nom}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text('${match.date.toLocal()}'.split(' ')[0],
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
