import 'package:flutter/material.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/utils/images/build_team_logo.dart';
import 'package:scorescope/utils/string/string_helper.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

/// Résultat retourné par le bottom sheet quand l'utilisateur valide.
class HistoryFilters {
  final String? competitionId;
  final String? equipeId;
  final bool favorisOnly;

  const HistoryFilters({
    this.competitionId,
    this.equipeId,
    this.favorisOnly = false,
  });
}

class HistoryFiltersSheet extends StatefulWidget {
  final List<Competition> availableCompetitions;
  final List<Equipe> availableEquipes;
  final String? initialCompetitionId;
  final String? initialEquipeId;
  final bool initialFavorisOnly;

  const HistoryFiltersSheet({
    super.key,
    required this.availableCompetitions,
    required this.availableEquipes,
    this.initialCompetitionId,
    this.initialEquipeId,
    this.initialFavorisOnly = false,
  });

  @override
  State<HistoryFiltersSheet> createState() => _HistoryFiltersSheetState();
}

class _HistoryFiltersSheetState extends State<HistoryFiltersSheet> {
  Competition? _selectedCompetition;
  Equipe? _selectedEquipe;
  bool _favorisOnly = false;

  @override
  void initState() {
    super.initState();
    _favorisOnly = widget.initialFavorisOnly;
    if (widget.initialCompetitionId != null) {
      final matches = widget.availableCompetitions
          .where((c) => c.id == widget.initialCompetitionId);
      _selectedCompetition = matches.isEmpty ? null : matches.first;
    }
    if (widget.initialEquipeId != null) {
      final matches =
          widget.availableEquipes.where((e) => e.id == widget.initialEquipeId);
      _selectedEquipe = matches.isEmpty ? null : matches.first;
    }
  }

  void _reset() {
    setState(() {
      _selectedCompetition = null;
      _selectedEquipe = null;
      _favorisOnly = false;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      HistoryFilters(
        competitionId: _selectedCompetition?.id,
        equipeId: _selectedEquipe?.id,
        favorisOnly: _favorisOnly,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        _selectedCompetition != null || _selectedEquipe != null || _favorisOnly;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: ColorPalette.surface(context),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: ColorPalette.border(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        translate.filtres,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ColorPalette.textPrimary(context),
                        ),
                      ),
                      if (hasActiveFilters)
                        TextButton.icon(
                          onPressed: _reset,
                          icon: Icon(Icons.refresh,
                              size: 15, color: ColorPalette.accent(context)),
                          label: Text(
                            translate.reinitialiser,
                            style: TextStyle(
                              fontSize: 13,
                              color: ColorPalette.accent(context),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _FilterSectionLabel(translate.competition),
                  const SizedBox(height: 8),
                  _AutocompleteFilterField<Competition>(
                    hint: translate.rechercherUneCompetition,
                    items: widget.availableCompetitions,
                    selected: _selectedCompetition,
                    labelBuilder: (c) => c.nom,
                    leadingBuilder: (c) => c.logoUrl != null
                        ? Container(
                            width: 28,
                            height: 28,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: ColorPalette.logoBackground(context),
                              shape: BoxShape.circle,
                            ),
                            child: CachedNetworkImage(
                              imageUrl: c.logoUrl!,
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Icon(Icons.emoji_events_outlined,
                            size: 18,
                            color: ColorPalette.textSecondary(context)),
                    onSelected: (c) => setState(() => _selectedCompetition = c),
                    onCleared: () =>
                        setState(() => _selectedCompetition = null),
                  ),
                  const SizedBox(height: 20),
                  _FilterSectionLabel(translate.equipe),
                  const SizedBox(height: 8),
                  _AutocompleteFilterField<Equipe>(
                    hint: translate.rechercherUneEquipe,
                    items: widget.availableEquipes,
                    selected: _selectedEquipe,
                    labelBuilder: (e) => e.nom,
                    leadingBuilder: (e) => buildTeamLogo(
                      context,
                      e.logoPath,
                      equipeId: e.id,
                      size: 22,
                      clickable: false,
                    ),
                    onSelected: (e) => setState(() => _selectedEquipe = e),
                    onCleared: () => setState(() => _selectedEquipe = null),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorPalette.tileBackground(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        translate.favorisUniquement,
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorPalette.textPrimary(context),
                        ),
                      ),
                      secondary: Icon(
                        Icons.star_outline,
                        size: 20,
                        color: ColorPalette.textSecondary(context),
                      ),
                      value: _favorisOnly,
                      activeColor: ColorPalette.accent(context),
                      onChanged: (v) => setState(() => _favorisOnly = v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.accent(context),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        translate.appliquer,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterSectionLabel extends StatelessWidget {
  final String text;
  const _FilterSectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: ColorPalette.textSecondary(context),
      ),
    );
  }
}

/// Champ de recherche générique avec suggestions en autocomplete,
/// réutilisable pour compétitions et équipes. Reprend le même principe
/// que la barre de recherche principale (filtrage startsWith/contains
/// normalisé), mais scopé aux items déjà chargés pour cette page.
class _AutocompleteFilterField<T> extends StatefulWidget {
  final String hint;
  final List<T> items;
  final T? selected;
  final String Function(T) labelBuilder;
  final Widget Function(T) leadingBuilder;
  final ValueChanged<T> onSelected;
  final VoidCallback onCleared;

  const _AutocompleteFilterField({
    super.key,
    required this.hint,
    required this.items,
    required this.selected,
    required this.labelBuilder,
    required this.leadingBuilder,
    required this.onSelected,
    required this.onCleared,
  });

  @override
  State<_AutocompleteFilterField<T>> createState() =>
      _AutocompleteFilterFieldState<T>();
}

class _AutocompleteFilterFieldState<T>
    extends State<_AutocompleteFilterField<T>> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<T> _suggestions = [];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    final q = normalize(query.trim().toLowerCase());
    if (q.length < 1) {
      setState(() => _suggestions = []);
      return;
    }

    final startsWith = <T>[];
    final contains = <T>[];
    for (final item in widget.items) {
      final label = normalize(widget.labelBuilder(item).toLowerCase());
      if (label.startsWith(q)) {
        startsWith.add(item);
      } else if (label.contains(q)) {
        contains.add(item);
      }
    }

    setState(
        () => _suggestions = [...startsWith, ...contains].take(6).toList());
  }

  void _select(T item) {
    widget.onSelected(item);
    _controller.clear();
    _focusNode.unfocus();
    setState(() => _suggestions = []);
  }

  @override
  Widget build(BuildContext context) {
    final accent = ColorPalette.accent(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.selected != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              border: Border.all(color: accent.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                widget.leadingBuilder(widget.selected as T),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.labelBuilder(widget.selected as T),
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: widget.onCleared,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 16, color: accent),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: _onChanged,
                style: TextStyle(
                  fontSize: 14,
                  color: ColorPalette.textPrimary(context),
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle:
                      TextStyle(color: ColorPalette.textSecondary(context)),
                  prefixIcon: Icon(Icons.search,
                      size: 18, color: ColorPalette.textSecondary(context)),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  filled: true,
                  fillColor: ColorPalette.tileBackground(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (_suggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  constraints: const BoxConstraints(maxHeight: 190),
                  decoration: BoxDecoration(
                    color: ColorPalette.surface(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorPalette.border(context)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 44,
                      color: ColorPalette.border(context),
                    ),
                    itemBuilder: (context, index) {
                      final item = _suggestions[index];
                      return InkWell(
                        onTap: () => _select(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 9),
                          child: Row(
                            children: [
                              widget.leadingBuilder(item),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  widget.labelBuilder(item),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ColorPalette.textPrimary(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
