import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scorescope/models/but.dart';
import 'package:scorescope/services/repositories/equipe/i_equipe_repository.dart';
import 'package:scorescope/services/repositories/equipe/mock_equipe_repository.dart';
import 'package:scorescope/utils/joueur_name_parser.dart';
import '../models/match.dart';
import '../models/equipe.dart';

import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddMatchView extends StatefulWidget {
  ///////// REPOSITORY /////////
  final IEquipeRepository equipeRepository = MockEquipeRepository();

  AddMatchView({super.key});

  @override
  State<AddMatchView> createState() => _AddMatchViewState();
}

class _AddMatchViewState extends State<AddMatchView> {
  ///////// FORM CONTROLLERS /////////
  final _formKey = GlobalKey<FormState>();
  final _equipeDomicileController = TextEditingController();
  final _equipeExterieurController = TextEditingController();
  final _scoreDomController = TextEditingController();
  final _scoreExtController = TextEditingController();
  final _competitionController = TextEditingController();
  final _dateController = TextEditingController();
  final List<TextEditingController> _buteursDom = [];
  final List<TextEditingController> _buteursExt = [];

  //////// VALEURS STOCKÉES /////////
  final List<String> _buteursDomString = [];
  final List<String> _buteursExtString = [];
  DateTime _matchDate = DateTime.now();
  Equipe? _selectedEquipeDomicile;
  Equipe? _selectedEquipeExterieur;

  //////// VALUE NOTIFIERS /////////
  final ValueNotifier<bool> _equipeDomicileHasFocus = ValueNotifier(false);
  final ValueNotifier<bool> _equipeExterieurHasFocus = ValueNotifier(false);
  final Map<FocusNode, VoidCallback> _focusListeners = {};

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_matchDate);
  }

  @override
  void dispose() {
    _equipeDomicileController.dispose();
    _equipeExterieurController.dispose();
    _scoreDomController.dispose();
    _scoreExtController.dispose();
    _competitionController.dispose();
    _dateController.dispose();

    for (final entry in _focusListeners.entries) {
      entry.key.removeListener(entry.value);
    }
    _focusListeners.clear();

    _equipeDomicileHasFocus.dispose();
    _equipeExterieurHasFocus.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year}';
  }

  TextEditingController _createControllerWithSync(
    List<String> storageList,
    int index,
  ) {
    final initialText = index < storageList.length ? storageList[index] : '';
    final controller = TextEditingController(text: initialText);

    if (index >= storageList.length) {
      storageList.add(initialText);
    }

    controller.addListener(() {
      if (index < storageList.length) {
        storageList[index] = controller.text;
      } else {
        storageList.add(controller.text);
      }
    });

    return controller;
  }

  void _updateButeurs() {
    final scoreDom = int.tryParse(_scoreDomController.text) ?? 0;
    final scoreExt = int.tryParse(_scoreExtController.text) ?? 0;

    while (_buteursDom.length < scoreDom) {
      final idx = _buteursDom.length;
      final ctrl = _createControllerWithSync(_buteursDomString, idx);
      _buteursDom.add(ctrl);
    }

    while (_buteursDom.length > scoreDom) {
      final removed = _buteursDom.removeLast();
      removed.dispose();
    }

    while (_buteursExt.length < scoreExt) {
      final idx = _buteursExt.length;
      final ctrl = _createControllerWithSync(_buteursExtString, idx);
      _buteursExt.add(ctrl);
    }
    while (_buteursExt.length > scoreExt) {
      final removed = _buteursExt.removeLast();
      removed.dispose();
    }

    setState(() {});
  }

  Widget buildEquipeTypeAhead(
      {required TextEditingController controller,
      required void Function(Equipe) onSuggestionSelected,
      required ThemeData theme,
      required ValueNotifier<bool> focusNotifier}) {
    return TypeAheadField<Equipe>(
      builder: (context, taController, focusNode) {
        if (!_focusListeners.containsKey(focusNode)) {
          void listener() {
            focusNotifier.value = focusNode.hasFocus;
          }

          focusNode.addListener(listener);
          _focusListeners[focusNode] = listener;

          focusNotifier.value = focusNode.hasFocus;
        }
        return ValueListenableBuilder<bool>(
          valueListenable: focusNotifier,
          builder: (context, hasFocus, _) {
            return TextField(
              controller: taController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Équipe',
                filled: true,
                fillColor: theme.secondaryHeaderColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: hasFocus ? Radius.zero : Radius.circular(10),
                    bottomRight: hasFocus ? Radius.zero : Radius.circular(10),
                  ),
                ),
              ),
            );
          },
        );
      },
      suggestionsCallback: (pattern) async {
        if (pattern.length < 3) {
          return [];
        }
        return await widget.equipeRepository.searchTeams(pattern);
      },
      itemBuilder: (context, Equipe suggestion) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        suggestion.nom,
                        style: const TextStyle(color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (suggestion.code != null)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          suggestion.code!,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              if (suggestion.logoPath != null)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Image.asset(suggestion.logoPath!, fit: BoxFit.contain),
                ),
            ],
          ),
        );
      },
      emptyBuilder: (context) => SizedBox.shrink(),
      offset: const Offset(0, -2),
      onSelected: onSuggestionSelected,
      decorationBuilder: (context, suggestionsBox) {
        return ValueListenableBuilder<bool>(
          valueListenable: focusNotifier,
          builder: (context, hasFocus, _) {
            return Container(
              decoration: hasFocus
                  ? BoxDecoration(
                      color: theme.secondaryHeaderColor,
                      border: Border.all(color: const Color(0xFF6750A4)),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    )
                  : const BoxDecoration(),
              child: suggestionsBox,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Équipe domicile
                  Expanded(
                    child: buildEquipeTypeAhead(
                      controller: _equipeDomicileController,
                      theme: theme,
                      onSuggestionSelected: (equipe) {
                        _equipeDomicileController.text = equipe.nom;
                        _selectedEquipeDomicile = equipe;
                      },
                      focusNotifier: _equipeDomicileHasFocus,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Score domicile
                  SizedBox(
                    width: 45,
                    child: TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      onChanged: (_) => _updateButeurs(),
                      controller: _scoreDomController,
                      decoration: InputDecoration(
                        hintText: "0",
                        filled: true,
                        fillColor: theme.secondaryHeaderColor,
                        border: OutlineInputBorder(),
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      onChanged: (_) => _updateButeurs(),
                      controller: _scoreExtController,
                      decoration: InputDecoration(
                        hintText: "0",
                        filled: true,
                        fillColor: theme.secondaryHeaderColor,
                        border: OutlineInputBorder(),
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
                    child: buildEquipeTypeAhead(
                      controller: _equipeExterieurController,
                      theme: theme,
                      onSuggestionSelected: (equipe) {
                        _equipeExterieurController.text = equipe.nom;
                        _selectedEquipeExterieur = equipe;
                      },
                      focusNotifier: _equipeExterieurHasFocus,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  // Compétition
                  Expanded(
                    child: TextFormField(
                      controller: _competitionController,
                      decoration: InputDecoration(
                        labelText: 'Compétition',
                        filled: true,
                        fillColor: theme.secondaryHeaderColor,
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Entrez une compétition'
                          : null,
                    ),
                  ),

                  const SizedBox(width: 12),

                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        filled: true,
                        fillColor: theme.secondaryHeaderColor,
                        border: OutlineInputBorder(),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _matchDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
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

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 290,
                      child: SingleChildScrollView(
                        child: Column(
                          children: _buteursDom
                              .map((c) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 1.0),
                                    child: TextFormField(
                                      textCapitalization:
                                          TextCapitalization.words,
                                      onChanged: (value) {
                                        final index = _buteursDom.indexOf(c);
                                        if (index >= 0) {
                                          if (index <
                                              _buteursDomString.length) {
                                            _buteursDomString[index] = value;
                                          } else {
                                            _buteursDomString.add(value);
                                          }
                                        }
                                      },
                                      controller: c,
                                      decoration: InputDecoration(
                                        labelText:
                                            'Buteur ${_buteursDom.indexOf(c) + 1}',
                                        filled: true,
                                        fillColor: theme.secondaryHeaderColor,
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 290,
                      child: SingleChildScrollView(
                        child: Column(
                          children: _buteursExt
                              .map((c) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 1.0),
                                    child: TextFormField(
                                      textCapitalization:
                                          TextCapitalization.words,
                                      onChanged: (value) {
                                        final index = _buteursExt.indexOf(c);
                                        if (index >= 0) {
                                          if (index <
                                              _buteursExtString.length) {
                                            _buteursExtString[index] = value;
                                          } else {
                                            _buteursExtString.add(value);
                                          }
                                        }
                                      },
                                      controller: c,
                                      decoration: InputDecoration(
                                        labelText:
                                            'Buteur ${_buteursExt.indexOf(c) + 1}',
                                        filled: true,
                                        fillColor: theme.secondaryHeaderColor,
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
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
                      id: '',
                      equipeDomicile: _selectedEquipeDomicile ??
                          Equipe(nom: _equipeDomicileController.text, id: ''),
                      equipeExterieur: _selectedEquipeExterieur ??
                          Equipe(nom: _equipeExterieurController.text, id: ''),
                      scoreEquipeDomicile:
                          int.tryParse(_scoreDomController.text) ?? 0,
                      scoreEquipeExterieur:
                          int.tryParse(_scoreExtController.text) ?? 0,
                      competition: _competitionController.text,
                      date: _matchDate,
                      butsEquipeDomicile: _buteursDom
                          .map(
                            (controller) => But(
                              buteur: parseNomJoueur(
                                capitalizeNomComplet(controller.text),
                              ),
                              minute: '1',
                            ),
                          )
                          .toList(),
                      butsEquipeExterieur: _buteursExt
                          .map(
                            (controller) => But(
                              buteur: parseNomJoueur(
                                capitalizeNomComplet(controller.text),
                              ),
                              minute: '1',
                            ),
                          )
                          .toList(),
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
