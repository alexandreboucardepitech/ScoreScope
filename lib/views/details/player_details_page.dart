import 'package:flutter/material.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class PlayerDetailsPage extends StatefulWidget {
  final String playerId;

  const PlayerDetailsPage({
    super.key,
    required this.playerId,
  });

  @override
  State<PlayerDetailsPage> createState() => _PlayerDetailsPageState();
}

class _PlayerDetailsPageState extends State<PlayerDetailsPage> {
  Joueur? _joueur;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayer();
  }

  Future<void> _loadPlayer() async {
    try {
      final joueur = await RepositoryProvider.joueurRepository
          .fetchJoueurById(widget.playerId);

      setState(() {
        _joueur = joueur;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _joueur == null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Text(
        "Joueur introuvable",
        style: TextStyle(
          color: ColorPalette.textPrimary(context),
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        _buildHeader(),
        SliverToBoxAdapter(
          child: _buildStatsPlaceholder(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        color: ColorPalette.surface(context),
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Photo joueur
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: ColorPalette.pictureBackground(context),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  _joueur!.picture,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Infos joueur
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _joueur!.fullName,
                    style: TextStyle(
                      color: ColorPalette.textPrimary(context),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FutureBuilder(
                    future: RepositoryProvider.equipeRepository
                        .fetchEquipeById(_joueur!.equipeId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text(
                          "Chargement...",
                          style: TextStyle(
                            color: ColorPalette.textSecondary(context),
                            fontSize: 14,
                          ),
                        );
                      }

                      final equipe = snapshot.data!;

                      return Text(
                        equipe.nom,
                        style: TextStyle(
                          color: ColorPalette.textSecondary(context),
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorPalette.surfaceSecondary(context),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Statistiques",
            style: TextStyle(
              color: ColorPalette.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorPalette.tileBackground(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              "Les statistiques du joueur arriveront bientôt 👀",
              style: TextStyle(
                color: ColorPalette.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
