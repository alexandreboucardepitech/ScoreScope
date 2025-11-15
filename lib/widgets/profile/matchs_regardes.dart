import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/widgets/match_list/match_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/services/repository_provider.dart';

class MatchsRegardes extends StatefulWidget {
  final List<String>? matchesId;
  final bool isLoading; // true = on charge les IDs
  const MatchsRegardes(
      {super.key, required this.matchesId, this.isLoading = false});

  @override
  State<MatchsRegardes> createState() => _MatchsRegardesState();
}

class _MatchsRegardesState extends State<MatchsRegardes> {
  final matchesRepo = RepositoryProvider.matchRepository;

  final Map<String, Match?> _loaded = {};
  final Set<String> _fetching = {};

  @override
  void initState() {
    super.initState();
    _ensureFetch();
  }

  @override
  void didUpdateWidget(covariant MatchsRegardes oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureFetch();
  }

  void _ensureFetch() {
    final ids = widget.matchesId ?? [];
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
        _loaded[id] = null; // erreur : on peut afficher un placeholder d'erreur
      });
    } finally {
      _fetching.remove(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return _buildGlobalShimmer();

    final ids = widget.matchesId ?? [];
    if (ids.isEmpty) return const SizedBox.shrink();

    final display = ids.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Derniers matchs ajoutés',
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Voir plus',
                style: TextStyle(
                  color: ColorPalette.textSecondary(context),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        MatchList(ids: display),
      ],
    );
  }

  Widget _buildGlobalShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: ColorPalette.shimmerPrimary(context),
          highlightColor: ColorPalette.shimmerSecondary(context),
          child: Column(
            children: List.generate(
              5,
              (i) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: _MatchShimmerTile(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchShimmerTile extends StatelessWidget {
  const _MatchShimmerTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ColorPalette.surface(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
              width: 40, height: 40, color: ColorPalette.surface(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12, color: ColorPalette.surface(context)),
                const SizedBox(height: 6),
                Container(
                    height: 12,
                    width: 80,
                    color: ColorPalette.surface(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
