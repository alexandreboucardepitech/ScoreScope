import 'package:flutter/material.dart';
import 'package:scorescope/views/amis/ajout_amis.dart';

class FilActuAmisView extends StatelessWidget {
  const FilActuAmisView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fil d'actu des amis"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Ajouter des amis',
            onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AjoutAmisView()),
          )
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Ici sera le fil d'actu des amis (vide pour l'instant).",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
