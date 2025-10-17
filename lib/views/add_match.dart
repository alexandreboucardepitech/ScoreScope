import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/equipe.dart';

class AddMatchView extends StatefulWidget {
  const AddMatchView({super.key});

  @override
  State<AddMatchView> createState() => _AddMatchViewState();
}

class _AddMatchViewState extends State<AddMatchView> {
  final _formKey = GlobalKey<FormState>();
  final _domicileController = TextEditingController();
  final _exterieurController = TextEditingController();
  final _scoreDomController = TextEditingController();
  final _scoreExtController = TextEditingController();
  final _competitionController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime _matchDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_matchDate);
  }

  @override
  void dispose() {
    _domicileController.dispose();
    _exterieurController.dispose();
    _scoreDomController.dispose();
    _scoreExtController.dispose();
    _competitionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouveau match"),
        backgroundColor: theme.primaryColor,
      ),
      backgroundColor: theme.primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Équipe domicile
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Équipe domicile
                  Expanded(
                    child: TextFormField(
                      controller: _domicileController,
                      decoration: InputDecoration(
                        labelText: "Domicile",
                        filled: true,
                        fillColor: theme.secondaryHeaderColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Entrez une équipe'
                          : null,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Score domicile
                  SizedBox(
                    width: 45,
                    child: TextFormField(
                      controller: _scoreDomController,
                      decoration: InputDecoration(
                        hintText: "0",
                        filled: true,
                        fillColor: theme.secondaryHeaderColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      "-",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  // Score extérieur
                  SizedBox(
                    width: 45,
                    child: TextFormField(
                      controller: _scoreExtController,
                      decoration: InputDecoration(
                        hintText: "0",
                        filled: true,
                        fillColor: theme.secondaryHeaderColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Équipe extérieure
                  Expanded(
                    child: TextFormField(
                      controller: _exterieurController,
                      decoration: InputDecoration(
                        labelText: "Extérieur",
                        filled: true,
                        fillColor: theme.secondaryHeaderColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Entrez une équipe'
                          : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              // Row : Competition (large) + Date (petit, readOnly)
              Row(
                children: [
                  // Champ Compétition (prend le reste de la largeur)
                  Expanded(
                    child: TextFormField(
                      controller: _competitionController,
                      decoration: InputDecoration(
                        labelText: 'Compétition',
                        filled: true,
                        fillColor: theme.secondaryHeaderColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Entrez une compétition'
                          : null,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Petit champ Date (lecture seule) : ouvre le DatePicker au tap
                  SizedBox(
                    width: 120, // petite largeur pour afficher "17/10/2025"
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        filled: true,
                        fillColor: theme.secondaryHeaderColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _matchDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          // optional: helpText, locale, etc.
                        );
                        if (picked != null) {
                          setState(() {
                            _matchDate = picked;
                            _dateController.text = _formatDate(_matchDate);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Bouton valider
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.secondaryHeaderColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newMatch = Match(
                      id: '', // à remplir côté repo
                      equipeDomicile: Equipe(
                        nom: _domicileController.text,
                        id: '',
                      ),
                      equipeExterieur: Equipe(
                        nom: _exterieurController.text,
                        id: '',
                      ),
                      scoreEquipeDomicile:
                          int.tryParse(_scoreDomController.text) ?? 0,
                      scoreEquipeExterieur:
                          int.tryParse(_scoreExtController.text) ?? 0,
                      competition: _competitionController.text,
                      date: DateTime.now(),
                    );
                    Navigator.pop(context, newMatch);
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Ajouter le match",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
