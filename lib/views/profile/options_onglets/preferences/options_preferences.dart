import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/enum/language_options.dart';
import 'package:scorescope/models/enum/theme_options.dart';
import 'package:scorescope/models/enum/visionnage_match.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/app_theme.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/utils/ui/segmented_options.dart';

class OptionsPreferencesView extends StatefulWidget {
  final AppUser currentUser;

  const OptionsPreferencesView({
    super.key,
    required this.currentUser,
  });

  @override
  State<OptionsPreferencesView> createState() => _OptionsPreferencesViewState();
}

class _OptionsPreferencesViewState extends State<OptionsPreferencesView> {
  late ThemeOptions theme;
  late LanguageOptions language;
  late VisionnageMatch visionnage;
  late bool utiliserCache;

  @override
  void initState() {
    super.initState();
    final options = widget.currentUser.options;

    theme = options.theme;
    language = options.language;
    visionnage = options.defaultVisionnageMatch;
    utiliserCache = options.utiliserCache;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        backgroundColor: ColorPalette.surface(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Préférences',
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
          _buildSectionHeader(context, "Thème"),
          SegmentedOptionRow<ThemeOptions>(
            values: ThemeOptions.values,
            selectedValue: theme,
            onChanged: (value) async {
              await RepositoryProvider.userRepository.updateOptions(
                userId: widget.currentUser.uid,
                theme: value,
              );

              context.read<ThemeController>().setTheme(value);

              setState(() => theme = value);
            },
            itemBuilder: (value, selected) {
              final label = switch (value) {
                ThemeOptions.light => "☀️",
                ThemeOptions.dark => "🌑",
                ThemeOptions.system => "⚙️",
              };

              return Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  color: selected
                      ? Colors.white
                      : ColorPalette.textPrimary(context),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, "Langue"),
          SegmentedOptionRow<LanguageOptions>(
            values: LanguageOptions.values,
            selectedValue: language,
            onChanged: (value) async {
              await RepositoryProvider.userRepository.updateOptions(
                userId: widget.currentUser.uid,
                language: value,
              );

              setState(() => language = value);
            },
            itemBuilder: (value, selected) {
              final label = switch (value) {
                LanguageOptions.french => "FR",
                LanguageOptions.english => "EN",
              };

              return Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : ColorPalette.textPrimary(context),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, "Mode de visionnage par défaut"),
          SegmentedOptionRow<VisionnageMatch>(
            values: VisionnageMatch.values,
            selectedValue: visionnage,
            onChanged: (value) async {
              await RepositoryProvider.userRepository.updateOptions(
                userId: widget.currentUser.uid,
                defaultVisionnageMatch: value,
              );

              setState(() => visionnage = value);
            },
            itemBuilder: (value, selected) {
              return Text(
                value.emoji,
                style: TextStyle(
                  fontSize: 18,
                  color: selected
                      ? Colors.white
                      : ColorPalette.textPrimary(context),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: ColorPalette.tileBackground(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ColorPalette.border(context),
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
              ),
              child: SwitchTheme(
                data: SwitchTheme.of(context).copyWith(
                  trackOutlineColor:
                      MaterialStateProperty.all(Colors.transparent),
                  trackOutlineWidth: MaterialStateProperty.all(0),
                ),
                child: SwitchListTile(
                  hoverColor: Colors.transparent,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  activeColor: ColorPalette.accent(context),
                  inactiveThumbColor: ColorPalette.buttonDisabled(context),
                  inactiveTrackColor:
                      ColorPalette.buttonDisabled(context).withOpacity(0.4),
                  value: utiliserCache,
                  onChanged: (value) {
                    RepositoryProvider.userRepository.updateOptions(
                      userId: widget.currentUser.uid,
                      utiliserCache: value,
                    );
                    setState(() => utiliserCache = value);
                  },
                  title: Text(
                    "Utiliser le cache",
                    style: TextStyle(
                      color: ColorPalette.textAccent(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: ColorPalette.textAccent(context),
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
