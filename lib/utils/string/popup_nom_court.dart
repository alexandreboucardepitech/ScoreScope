import 'package:flutter/material.dart';

Future<String?> popupNomCourt(BuildContext context, String teamName) async {
  final controller = TextEditingController(text: teamName.split(' ')[0]);

  final result = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(teamName),
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
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                controller.text.isEmpty ? null : controller.text,
              );
            },
            child: const Text("Valider"),
          ),
        ],
      );
    },
  );

  return result ?? "";
}
