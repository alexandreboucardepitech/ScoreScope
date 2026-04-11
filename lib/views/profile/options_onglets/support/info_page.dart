import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/app_logos.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class InfoPage extends StatelessWidget {
  final String title;
  final String content;

  const InfoPage({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        title: Row(
          children: [
            AppLogos.logoTransparent(context, size: 32),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: ColorPalette.surface(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            content,
            style: TextStyle(
              color: ColorPalette.textPrimary(context),
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
