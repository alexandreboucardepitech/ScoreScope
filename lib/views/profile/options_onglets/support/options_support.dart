import 'package:flutter/material.dart';
import 'package:scorescope/utils/translate/language_controller.dart';
import 'package:scorescope/utils/ui/app_logos.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/feedback/feedbacks_view.dart';
import 'package:scorescope/views/profile/options_onglets/support/info_page.dart';

class OptionsSupportView extends StatelessWidget {
  OptionsSupportView({super.key});

  final String _cguText = translate.conditionsDUtilisation;

  final String _privacyText = translate.politiqueDeConfidentialite;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        backgroundColor: ColorPalette.surface(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          translate.supportInformations,
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
          _buildTile(context, translate.aPropos, () {
            _showAboutDialog(context);
          }),
          _buildTile(context, translate.signalerUnBug, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FeedbacksView(),
              ),
            );
          }),
          _buildTile(context, translate.cgu, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InfoPage(
                  title: translate.conditionsDUtilisation,
                  content: _cguText,
                ),
              ),
            );
          }),
          _buildTile(context, translate.politiqueDeConfidentialite, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InfoPage(
                  title: translate.politiqueDeConfidentialite,
                  content: _privacyText,
                ),
              ),
            );
          }),
          _buildTile(context, translate.version, () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(
                  translate.version,
                  style: TextStyle(
                    color: ColorPalette.textPrimary(
                      context,
                    ),
                  ),
                ),
                content: Text(
                  "ScoreScope v1.0.3",
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
                      translate.ok,
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
                translate.tonCarnetDeMatchsDeFoot,
                style: TextStyle(
                  color: ColorPalette.textSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                translate
                    .noteLesMatchsQueTuRegardesElisLeMvpEtPartageTonExperienceAvecTesAmis,
                style: TextStyle(
                  color: ColorPalette.textPrimary(context),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                "Version 1.0.3",
                style: TextStyle(
                  color: ColorPalette.textSecondary(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  translate.fermer,
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
    if (title == translate.aPropos) {
      return Icons.info_outline;
    } else if (title == translate.signalerUnBug) {
      return Icons.bug_report_outlined;
    } else if (title == translate.cgu) {
      return Icons.description_outlined;
    } else if (title == translate.politiqueDeConfidentialite) {
      return Icons.lock_outline;
    } else if (title == translate.version) {
      return Icons.numbers;
    }
    return Icons.info_outline;
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
