import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/models/match_user_data.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
import 'package:scorescope/widgets/match_list/match_tile.dart';

class MatchList extends StatefulWidget {
  final List<MatchModel>? matches;
  final List<String>? ids;
  final Widget? header;
  final Widget? footer;

  final AppUser? user;
  final bool displayUserData;
  final bool hidePostponedMatches;
  final VoidCallback? onRefresh;
  final void Function(MatchModel match)? onMatchTap;
  final Map<String, MatchUserData>? userDataByMatchId;
  final bool lazy;

  const MatchList({
    super.key,
    this.matches,
    this.ids,
    this.header,
    this.footer,
    this.user,
    this.displayUserData = false,
    this.hidePostponedMatches = true,
    this.onRefresh,
    this.onMatchTap,
    this.userDataByMatchId,
    this.lazy = false,
  }) : assert(matches != null || ids != null, 'Provide either matches or ids');

  @override
  State<MatchList> createState() => _MatchListState();
}

class _MatchListState extends State<MatchList> {
  final _repo = RepositoryProvider.matchRepository;
  static final Map<String, MatchModel> _globalCache = {};
  List<MatchModel>? _loaded;
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
    final results = <MatchModel>[];
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
      final fetchedList = <MatchModel>[];
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

      final merged = <MatchModel>[];
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

  Widget _buildTile(BuildContext context, MatchModel match, {required bool isLast}) {
    return Column(
      key: ValueKey(match.id),
      children: [
        MatchTile(
          match: match,
          userData: widget.userDataByMatchId?[match.id] ??
              widget.user?.getMatchUserDataByMatch(match: match),
          user: widget.user,
          displayUserData: widget.displayUserData,
          onRefresh: widget.onRefresh,
          onTap: widget.onMatchTap != null
              ? () => widget.onMatchTap!(match)
              : null,
        ),
        if (!isLast) Divider(color: ColorPalette.border(context), height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasHeader = widget.header != null;
    final hasFooter = widget.footer != null;
    List<MatchModel>? items = widget.matches ?? _loaded;

    if (widget.hidePostponedMatches && items != null) {
      items = items
          .where((MatchModel match) => match.status != MatchStatus.postponed)
          .toList();
    }

    Widget content;

    if (_loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(
        child: Text(
          '${translate.erreur}: $_error',
          style: TextStyle(
            color: ColorPalette.textPrimary(
              context,
            ),
          ),
        ),
      );
    } else if (items == null || items.isEmpty) {
      content = Center(
        child: Text(
          translate.aucunMatchEnregistre,
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
          ),
        ),
      );
    } else {
      final resolvedItems = items;
      final itemCount =
          resolvedItems.length + (hasHeader ? 1 : 0) + (hasFooter ? 1 : 0);

      content = ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: !widget.lazy,
        physics: widget.lazy
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (hasHeader && index == 0) {
            return _buildHeaderTile(context, child: widget.header);
          }
          final adjustedIndex = index - (hasHeader ? 1 : 0);

          if (hasFooter && adjustedIndex == resolvedItems.length) {
            return widget.footer!;
          }

          final match = resolvedItems[adjustedIndex];
          return _buildTile(
            context,
            match,
            isLast: adjustedIndex == resolvedItems.length - 1,
          );
        },
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
