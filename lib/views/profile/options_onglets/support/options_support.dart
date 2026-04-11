import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/app_logos.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/feedback/feedbacks_view.dart';
import 'package:scorescope/views/profile/options_onglets/support/info_page.dart';

class OptionsSupportView extends StatelessWidget {
  const OptionsSupportView({super.key});

  final String _cguText = """
Conditions d'utilisation

En utilisant ScoreScope, vous acceptez d'utiliser l'application de manière responsable.

Vous êtes responsable du contenu que vous publiez (notes, avis, MVP, etc.).

ScoreScope se réserve le droit de supprimer tout contenu inapproprié.

L'application est fournie telle quelle, sans garantie de disponibilité permanente.
""";

  final String _privacyText = """
Politique de confidentialité

ScoreScope collecte uniquement les données nécessaires au fonctionnement de l'application (compte, matchs, interactions sociales).

Vos données ne sont pas revendues à des tiers.

Vous pouvez demander la suppression de votre compte à tout moment.

Nous faisons de notre mieux pour protéger vos données.
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        backgroundColor: ColorPalette.surface(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Support & Informations',
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: ColorPalette.textPrimary(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _buildTile(context, "À propos", () {
            _showAboutDialog(context);
          }),
          _buildTile(context, "Signaler un bug", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FeedbacksView(),
              ),
            );
          }),
          _buildTile(context, "CGU", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InfoPage(
                  title: "Conditions d'utilisation",
                  content: _cguText,
                ),
              ),
            );
          }),
          _buildTile(context, "Politique de confidentialité", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InfoPage(
                  title: "Politique de confidentialité",
                  content: _privacyText,
                ),
              ),
            );
          }),
          _buildTile(context, "Version", () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(
                  "Version",
                  style: TextStyle(
                    color: ColorPalette.textPrimary(
                      context,
                    ),
                  ),
                ),
                content: Text(
                  "ScoreScope v1.0.0",
                  style: TextStyle(
                    color: ColorPalette.textPrimary(
                      context,
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: ColorPalette.textPrimary(
                          context,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: ColorPalette.surface(context),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLogos.logoPrimary(context),
              const SizedBox(height: 12),
              Text(
                "ScoreScope",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Ton carnet de matchs de foot ⚽",
                style: TextStyle(
                  color: ColorPalette.textSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Note les matchs que tu regardes, élis le MVP et partage ton expérience avec tes amis.",
                style: TextStyle(
                  color: ColorPalette.textPrimary(context),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                "Version 1.0.0",
                style: TextStyle(
                  color: ColorPalette.textSecondary(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Fermer",
                  style: TextStyle(
                    color: ColorPalette.textPrimary(
                      context,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String title) {
    switch (title) {
      case "À propos":
        return Icons.info_outline;
      case "Signaler un bug":
        return Icons.bug_report_outlined;
      case "CGU":
        return Icons.description_outlined;
      case "Politique de confidentialité":
        return Icons.lock_outline;
      case "Version":
        return Icons.numbers;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildTile(BuildContext context, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: ColorPalette.tileBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ColorPalette.border(context),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          _getIcon(title),
          color: ColorPalette.textSecondary(context),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: ColorPalette.textSecondary(context),
        ),
        onTap: onTap,
      ),
    );
  }
}
