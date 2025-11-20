import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/widgets/match_list/match_tile.dart';

class MatchList extends StatefulWidget {
  final List<Match>? matches;
  final List<String>? ids;
  final Widget? header;
  final AppUser? user;

  const MatchList({
    super.key,
    this.matches,
    this.ids,
    this.header,
    this.user,
  }) : assert(matches != null || ids != null, 'Provide either matches or ids');

  @override
  State<MatchList> createState() => _MatchListState();
}

class _MatchListState extends State<MatchList> {
  final _repo = RepositoryProvider.matchRepository;
  static final Map<String, Match> _globalCache = {};
  List<Match>? _loaded;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.matches != null) {
      _loaded = widget.matches;
    } else {
      _fetchMatches();
    }
  }

  @override
  void didUpdateWidget(covariant MatchList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.matches != null && widget.matches != oldWidget.matches) {
      setState(() => _loaded = widget.matches);
    } else if (widget.ids != null && widget.ids != oldWidget.ids) {
      _fetchMatches();
    }
  }

  Future<void> _fetchMatches() async {
    final ids = widget.ids ?? [];
    if (ids.isEmpty) {
      setState(() {
        _loaded = [];
        _loading = false;
      });
      return;
    }

    final missingIds = <String>[];
    final results = <Match>[];
    for (final id in ids) {
      if (_globalCache.containsKey(id)) {
        results.add(_globalCache[id]!);
      } else {
        missingIds.add(id);
      }
    }

    if (missingIds.isEmpty) {
      setState(() {
        _loaded = results;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final idsQueue = Queue<String>.from(missingIds);
      final fetchedList = <Match>[];
      const concurrency = 6;

      Future<void> worker() async {
        while (idsQueue.isNotEmpty) {
          final id = idsQueue.removeFirst();
          try {
            final m = await _repo.fetchMatchById(id);
            if (m != null) fetchedList.add(m);
          } catch (_) {}
        }
      }

      await Future.wait(List.generate(concurrency, (_) => worker()));

      for (final m in fetchedList) {
        _globalCache[m.id] = m;
      }

      final merged = <Match>[];
      for (final id in ids) {
        if (_globalCache.containsKey(id)) merged.add(_globalCache[id]!);
      }

      if (!mounted) return;
      setState(() {
        _loaded = merged;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasHeader = widget.header != null;
    final List<Match>? items = widget.matches ?? _loaded;

    Widget content;

    if (_loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(child: Text('Erreur: $_error'));
    } else if (items == null || items.isEmpty) {
      content = Center(
        child: Text(
          'Aucun match enregistré',
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
          ),
        ),
      );
    } else {
      content = Padding(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasHeader)
              _buildHeaderTile(context, child: widget.header),
            for (int i = 0; i < items.length; i++) ...[
              MatchTile(
                match: items[i],
                userData: widget.user?.getMatchUserDataByMatch(match: items[i]),
              ),
              if (i != items.length - 1)
                Divider(color: ColorPalette.border(context), height: 1),
            ],
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: ColorPalette.border(context)),
        borderRadius: BorderRadius.circular(8),
        color: ColorPalette.listHeader(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ColoredBox(
          color: ColorPalette.surface(context),
          child: content,
        ),
      ),
    );
  }

  Widget _buildHeaderTile(BuildContext context, {Widget? child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: ColorPalette.listHeader(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: child ?? const SizedBox.shrink()),
        ],
      ),
    );
  }
}
