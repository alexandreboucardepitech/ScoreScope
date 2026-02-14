import 'package:flutter/material.dart';
import 'package:scorescope/models/equipe.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class TeamsBottomSheet extends StatefulWidget {
  final List<String> equipesPreferees;
  const TeamsBottomSheet({super.key, required this.equipesPreferees});

  @override
  State<TeamsBottomSheet> createState() => _TeamsBottomSheetState();
}

class _TeamsBottomSheetState extends State<TeamsBottomSheet> {
  List<String> _selectedIds = [];
  final TextEditingController _searchController = TextEditingController();

  List<Equipe> _allTeams = [];
  List<Equipe> _filteredTeams = [];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadInitialData() async {
    final teams = await RepositoryProvider.equipeRepository.fetchAllEquipes();

    if (!mounted) return;

    setState(() {
      _allTeams = teams;
      _selectedIds = List.from(widget.equipesPreferees);
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredTeams = [];
      });
      return;
    }

    final startsWith =
        _allTeams.where((t) => t.nom.toLowerCase().startsWith(query)).toList();

    final contains = _allTeams
        .where((t) =>
            t.nom.toLowerCase().contains(query) && !startsWith.contains(t))
        .toList();

    setState(() {
      _filteredTeams = [...startsWith, ...contains];
    });
  }

  Future<void> _handleValidation() async {
    setState(() => _isSaving = true);

    if (mounted) {
      Navigator.pop(context, _selectedIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75, // harmonisé
      ),
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          _buildHandle(),
          _buildTitle(),
          _buildSearchField(),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
          ),
          _buildValidationBar(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: ColorPalette.divider(context),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      "Sélection des équipes",
      style: TextStyle(
        color: ColorPalette.textPrimary(context),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: ColorPalette.textPrimary(context)),
        decoration: InputDecoration(
          hintText: "Rechercher une équipe...",
          hintStyle: TextStyle(color: ColorPalette.textSecondary(context)),
          prefixIcon:
              Icon(Icons.search, color: ColorPalette.textSecondary(context)),
          filled: true,
          fillColor: ColorPalette.surfaceSecondary(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      final favorites =
          _allTeams.where((t) => _selectedIds.contains(t.id)).toList();

      if (favorites.isEmpty) {
        return Center(
          child: Text(
            "🔍 Recherche ton équipe préférée",
            style: TextStyle(
              color: ColorPalette.textSecondary(context),
            ),
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildSectionHeader("Mes équipes favorites"),
          ...favorites.map(_buildTeamTile),
          const SizedBox(height: 100),
        ],
      );
    }

    if (_filteredTeams.isEmpty) {
      return Center(
        child: Text(
          "Aucune équipe trouvée",
          style: TextStyle(color: ColorPalette.textSecondary(context)),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildSectionHeader("Résultats"),
        ..._filteredTeams.map(_buildTeamTile),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: ColorPalette.accent(context),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildTeamTile(Equipe team) {
    final isSelected = _selectedIds.contains(team.id);

    return CheckboxListTile(
      key: ValueKey("tile_${team.id}"),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      title: Text(
        team.nom,
        style: TextStyle(
          color: ColorPalette.textPrimary(context),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ColorPalette.background(context), // harmonisé
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(6),
        child: team.logoPath != null
            ? Image.asset(team.logoPath!, fit: BoxFit.contain)
            : Icon(
                Icons.shield,
                color: ColorPalette.textSecondary(context),
              ),
      ),
      activeColor: ColorPalette.accent(context),
      checkColor: ColorPalette.textAccent(context),
      value: isSelected,
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            if (_selectedIds.length >= 10) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Tu peux sélectionner jusqu'à 10 équipes."),
                ),
              );
              return;
            }
            _selectedIds.add(team.id);
          } else {
            _selectedIds.remove(team.id);
          }
        });
      },
    );
  }

  Widget _buildValidationBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorPalette.surface(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _handleValidation,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.accent(context),
              foregroundColor: ColorPalette.textAccent(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColorPalette.textPrimary(context),
                    ),
                  )
                : Text(
                    "Valider la sélection",
                    style: TextStyle(
                      color: ColorPalette.textPrimary(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
