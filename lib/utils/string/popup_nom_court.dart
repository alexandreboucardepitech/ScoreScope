import 'package:flutter/material.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

Future<String?> popupNomCourt(BuildContext context, String teamName) async {
  final controller = TextEditingController(text: teamName.split(' ')[0]);

  final result = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(
          teamName,
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Nom court",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, null);
            },
            child: Text(
              "Annuler",
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                controller.text.isEmpty ? null : controller.text,
              );
            },
            child: Text(
              "Valider",
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
            ),
          ),
        ],
      );
    },
  );

  return result ?? "";
}
