import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/match.dart' as model_match;
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/widgets/match_list/match_list.dart';

class MatchsRegardes extends StatefulWidget {
  final List<String>? matchesId;
  final bool isLoading; // true = on charge les IDs
  final AppUser? user;
  final VoidCallback? onVoirPlus;

  const MatchsRegardes({
    super.key,
    required this.matchesId,
    this.isLoading = false,
    this.user,
    this.onVoirPlus,
  });

  @override
  State<MatchsRegardes> createState() => _MatchsRegardesState();
}

class _MatchsRegardesState extends State<MatchsRegardes> {
  final matchesRepo = RepositoryProvider.matchRepository;

  final Map<String, model_match.Match?> _loaded = {};
  final Set<String> _fetching = {};

  @override
  void initState() {
    super.initState();
    _ensureFetch();
  }

  @override
  void didUpdateWidget(covariant MatchsRegardes oldWidget) {
    super.didUpdateWidget(oldWidget);
    // si la liste d'IDs a changé, on s'assure de fetcher les nouveaux
    if (oldWidget.matchesId != widget.matchesId) {
      _ensureFetch();
    }
  }

  void _ensureFetch() {
    final ids = widget.matchesId ?? [];
    for (final id in ids) {
      if (_loaded.containsKey(id) || _fetching.contains(id)) continue;
      _fetchMatch(id);
    }
    // retirer les IDs qui ne sont plus dans la liste
    final toRemove = _loaded.keys.where((k) => !ids.contains(k)).toList();
    for (final r in toRemove) {
      _loaded.remove(r);
    }
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
        _loaded[id] = null; // erreur : placeholder
      });
    } finally {
      _fetching.remove(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ids = widget.matchesId ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 8),
        if (widget.isLoading)
          _buildGlobalShimmer(context)
        else if (ids.isEmpty)
          _buildEmptyMessage(context, "Aucun match regardé")
        else
          MatchList(
            ids: ids.take(5).toList(),
            user: widget.user,
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Derniers matchs ajoutés',
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: widget.onVoirPlus,
          child: Text(
            'Voir plus',
            style: TextStyle(
              color: ColorPalette.textSecondary(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMessage(BuildContext context, String msg) {
    return SizedBox(
      height: 140,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_soccer_outlined,
                size: 32, color: ColorPalette.textSecondary(context)),
            const SizedBox(height: 8),
            Text(
              msg,
              style: TextStyle(
                color: ColorPalette.textSecondary(context),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalShimmer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // header shimmer
        Shimmer.fromColors(
          baseColor: ColorPalette.shimmerPrimary(context),
          highlightColor: ColorPalette.shimmerSecondary(context),
          child: Container(
            height: 18,
            width: 180,
            margin: const EdgeInsets.only(bottom: 8),
            color: ColorPalette.surface(context),
          ),
        ),
        // 5 tuiles shimmer
        Shimmer.fromColors(
          baseColor: ColorPalette.shimmerPrimary(context),
          highlightColor: ColorPalette.shimmerSecondary(context),
          child: Column(
            children: List.generate(
              5,
              (i) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
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
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ColorPalette.surface(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
              width: 48, height: 48, color: ColorPalette.surface(context)),
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
                  width: 100,
                  color: ColorPalette.surface(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
