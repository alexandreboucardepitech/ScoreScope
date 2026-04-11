import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/app_logos.dart';
import 'dart:ui';
import 'package:scorescope/utils/ui/color_palette.dart';

/// Onboarding Welcome Card
class WelcomeCard extends StatelessWidget {
  final VoidCallback onContinue;
  const WelcomeCard({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 36),
        AppLogos.logoAccent(context, size: 100),
        const SizedBox(height: 36),
        Text(
          "Bienvenue sur ScoreScope !",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ColorPalette.textAccent(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          """1: Répertorie les matchs que tu as regardé, donne leur une note, et vote pour le meilleur joueur.

2: Ajoute des amis et partage les matchs que tu as regardé.

3: Découvrez des dizaines de statistiques sur tes habitudes de visionnage.


Avec ScoreScope, garde un souvenir de chaque match, tel qu'il a été vécu !""",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: ColorPalette.textPrimary(context),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.accent(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Continuer",
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Onboarding Teams Card
class TeamsCard extends StatelessWidget {
  final Widget equipesPrefereesWidget;
  final VoidCallback onAddTeams;
  final VoidCallback onContinue;
  const TeamsCard({
    super.key,
    required this.equipesPrefereesWidget,
    required this.onAddTeams,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.shield,
          size: 72,
          color: ColorPalette.accent(context),
        ),
        const SizedBox(height: 16),
        Text(
          "Choisis tes équipes préférées",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorPalette.textAccent(context),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: equipesPrefereesWidget,
          ),
        ),
        TextButton(
          onPressed: onAddTeams,
          child: Text(
            "Ajouter des équipes",
            style: TextStyle(color: ColorPalette.accent(context)),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.accent(context),
            ),
            child: Text(
              "Continuer",
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Onboarding Competitions Card
class CompetitionsCard extends StatelessWidget {
  final Widget competitionsPrefereesWidget;
  final VoidCallback onAddCompetitions;
  final VoidCallback onContinue;
  const CompetitionsCard({
    super.key,
    required this.competitionsPrefereesWidget,
    required this.onAddCompetitions,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.emoji_events,
          size: 72,
          color: ColorPalette.accent(context),
        ),
        const SizedBox(height: 16),
        Text(
          "Choisis tes compétitions préférées",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorPalette.textAccent(context),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: competitionsPrefereesWidget,
          ),
        ),
        TextButton(
          onPressed: onAddCompetitions,
          child: Text(
            "Ajouter des compétitions",
            style: TextStyle(color: ColorPalette.accent(context)),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.accent(context),
            ),
            child: Text(
              "Continuer",
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Onboarding Start Card
class StartCard extends StatelessWidget {
  final VoidCallback onFinish;
  const StartCard({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.rocket_launch,
          size: 72,
          color: ColorPalette.accent(context),
        ),
        const SizedBox(height: 52),
        Text(
          "Commence l'aventure ScoreScope !",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorPalette.textAccent(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Personnalise ton profil pour entrer dans l'app.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: ColorPalette.textPrimary(context),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onFinish,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.accent(context),
            ),
            child: Text(
              "Terminer",
              style: TextStyle(
                color: ColorPalette.textPrimary(
                  context,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Onboarding Overlay
class OnboardingOverlay extends StatelessWidget {
  final Widget card;
  final VoidCallback onSkip;
  const OnboardingOverlay(
      {super.key, required this.card, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Blur background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width * 0.95,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: ColorPalette.surface(context),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: card,
                  ),
                  Positioned(
                    top: 0,
                    right: 8,
                    child: TextButton(
                      onPressed: onSkip,
                      child: Text(
                        "Passer",
                        style: TextStyle(
                          color: ColorPalette.textAccent(context),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
