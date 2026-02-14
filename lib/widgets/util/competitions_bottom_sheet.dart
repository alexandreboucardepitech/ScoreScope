import 'package:flutter/material.dart';
import 'package:scorescope/models/competition.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class CompetitionsBottomSheet extends StatefulWidget {
  const CompetitionsBottomSheet({super.key});

  @override
  State<CompetitionsBottomSheet> createState() =>
      _CompetitionsBottomSheetState();
}

class _CompetitionsBottomSheetState extends State<CompetitionsBottomSheet> {
  late Future<List<Competition>> _futureCompetitions;
  final Set<String> _selectedIds = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _futureCompetitions =
        RepositoryProvider.competitionRepository.fetchAllCompetitions();
    _loadCurrentPreferences();
  }

  void _loadCurrentPreferences() async {
    final user = await RepositoryProvider.userRepository.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _selectedIds.addAll(user.competitionsPrefereesId);
      });
    }
  }

  Future<void> _handleValidation() async {
    setState(() => _isSaving = true);

    final user = await RepositoryProvider.userRepository.getCurrentUser();
    if (user == null) return;

    RepositoryProvider.competitionRepository.updateFavoriteCompetitions(
      userId: user.uid,
      competitionIds: _selectedIds.toList(),
    );
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: ColorPalette.divider(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            "Sélection des compétitions",
            style: TextStyle(
              color: ColorPalette.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<Competition>>(
              future: _futureCompetitions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allComps = snapshot.data ?? [];
                allComps.sort((a, b) => b.popularite.compareTo(a.popularite));

                final favoriteComps =
                    allComps.where((c) => _selectedIds.contains(c.id)).toList();
                final otherComps = allComps
                    .where((c) => !_selectedIds.contains(c.id))
                    .toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (favoriteComps.isNotEmpty) ...[
                      _buildSectionHeader("Mes compétitions favorites"),
                      ...favoriteComps.map((comp) => _buildAnimatedTile(comp)),
                      const SizedBox(height: 24),
                    ],
                    _buildSectionHeader("Toutes les compétitions"),
                    ...otherComps.map((comp) => _buildAnimatedTile(comp)),
                    const SizedBox(height: 100),
                  ],
                );
              },
            ),
          ),
          _buildValidationBar(),
        ],
      ),
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
                  borderRadius: BorderRadius.circular(12)),
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
                        fontSize: 16),
                  ),
          ),
        ),
      ),
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

  Widget _buildAnimatedTile(Competition comp) {
    return AnimatedSize(
      key: ValueKey(comp.id),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _buildCompetitionTile(comp),
    );
  }

  Widget _buildCompetitionTile(Competition comp) {
    final isSelected = _selectedIds.contains(comp.id);

    return CheckboxListTile(
      key: ValueKey("tile_${comp.id}"),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      title: Text(
        comp.nom,
        style: TextStyle(
          color: ColorPalette.textPrimary(context),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ColorPalette.background(context),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(6),
        child: comp.logoUrl != null
            ? Image.asset(comp.logoUrl!, fit: BoxFit.contain)
            : Icon(Icons.emoji_events,
                color: ColorPalette.textSecondary(context)),
      ),
      activeColor: ColorPalette.accent(context),
      checkColor: ColorPalette.textAccent(context),
      value: isSelected,
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            _selectedIds.add(comp.id);
          } else {
            _selectedIds.remove(comp.id);
          }
        });
      },
    );
  }
}
