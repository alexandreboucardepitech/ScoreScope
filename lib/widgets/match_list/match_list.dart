import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/widgets/match_list/match_tile.dart';

class MatchList extends StatefulWidget {
  final List<Match>? matches;
  final List<String>? ids;
  final Widget? header;

  const MatchList({
    super.key,
    this.matches,
    this.ids,
    this.header,
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
        if (m.id != null) _globalCache[m.id!] = m;
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
    final items = widget.matches ?? _loaded;

    Widget content;

    if (_loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(child: Text('Erreur: $_error'));
    } else if (items == null || items.isEmpty) {
      content = const Center(child: Text('Aucun match enregistré'));
    } else {
      final totalCount = items.length + (hasHeader ? 1 : 0);
      content = MediaQuery.removePadding(
        context: context,
        removeTop:
            true, // retire tout padding supérieur hérité (SafeArea / scaffold etc.)
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalCount,
          separatorBuilder: (_, __) =>
              const Divider(color: Colors.black12, height: 1),
          itemBuilder: (ctx, idx) {
            if (hasHeader && idx == 0) {
              return _buildHeaderTile(context, child: widget.header);
            }
            final match = items[hasHeader ? idx - 1 : idx];
            return MatchTile(match: match);
          },
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).secondaryHeaderColor,
      ),
      child: content,
    );
  }

  Widget _buildHeaderTile(BuildContext context, {Widget? child}) {
    final bg = Theme.of(context).secondaryHeaderColor;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(child: child ?? const SizedBox.shrink()),
        ],
      ),
    );
  }
}
