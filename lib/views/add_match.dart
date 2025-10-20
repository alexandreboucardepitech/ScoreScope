import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scorescope/models/but.dart';
import 'package:scorescope/services/repositories/equipe/i_equipe_repository.dart';
import 'package:scorescope/services/repositories/equipe/mock_equipe_repository.dart';
import 'package:scorescope/utils/joueur_name_parser.dart';
import '../models/match.dart';
import '../models/equipe.dart';

import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  final List<TextEditingController> _buteursDomCount = [];
  final List<TextEditingController> _buteursExtCount = [];

  //////// VALEURS STOCKÉES /////////
  final List<String> _buteursDomString = [];
  final List<String> _buteursExtString = [];
  final List<int> _buteursDomCountsInt = [];
  final List<int> _buteursExtCountsInt = [];
  DateTime _matchDate = DateTime.now();
  Equipe? _selectedEquipeDomicile;
  Equipe? _selectedEquipeExterieur;

  //////// VALUE NOTIFIERS /////////
  final ValueNotifier<bool> _equipeDomicileHasFocus = ValueNotifier(false);
  final ValueNotifier<bool> _equipeExterieurHasFocus = ValueNotifier(false);
  final Map<FocusNode, VoidCallback> _focusListeners = {};

  /////// FOCUS NODES /////////
  List<FocusNode> focusNodes = [];
  List<FocusNode> focusNodesButeurs = [];

  /////// UI STATE /////////
  bool _showDom = false;
  bool _showExt = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_matchDate);

    focusNodes = List.generate(6, (_) => FocusNode());
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

  int checkMultipleGoals(
      int score,
      List<TextEditingController> buteursControllers,
      List<String> buteursControllersString,
      List<TextEditingController> buteursCountControllers,
      List<int> buteursCountControllersInt) {
    int nbChamps = score;
    String buteurDouble = "";
    for (int i = 0; i < buteursCountControllers.length; i++) {
      for (int j = 0; j < buteursCountControllers.length; j++) {
        if (i != j &&
            buteursControllers[i].text.trim() ==
                buteursControllers[j].text.trim() &&
            buteursControllers[i].text.isNotEmpty) {
          buteurDouble = buteursControllers[i].text;
        }
      }
    }
    int doubleButeurIndexToRemove = -1;
    bool seen = false;
    for (int i = 0; i < buteursControllers.length - 1; i++) {
      if (buteursControllers[i].text == buteurDouble && buteurDouble.isNotEmpty) {
        if (!seen) {
          seen = true;
          final currentCount =
              int.tryParse(buteursCountControllers[i].text) ?? 1;
          buteursCountControllers[i].text = (currentCount + 1).toString();
        } else {
          doubleButeurIndexToRemove = i;
        }
      }
    }
    if (doubleButeurIndexToRemove != -1) {
      buteursControllers.removeAt(doubleButeurIndexToRemove);
      buteursControllersString.removeAt(doubleButeurIndexToRemove);

      buteursCountControllers.removeAt(doubleButeurIndexToRemove);
      if (buteursCountControllersInt.length > doubleButeurIndexToRemove) {
        buteursCountControllersInt.removeAt(doubleButeurIndexToRemove);
      }
    }

    for (int i = 0; i < buteursCountControllers.length; i++) {
      final count = int.tryParse(buteursCountControllers[i].text) ?? 1;
      if (count > 1) {
        nbChamps -= (count - 1);
        if (nbChamps < 1) {
          nbChamps = 1;
        }
      }
    }
    return nbChamps;
  }

  void _updateButeurs() {
    final scoreDom = int.tryParse(_scoreDomController.text) ?? 0;
    final scoreExt = int.tryParse(_scoreExtController.text) ?? 0;

    final int nbChampsDom = checkMultipleGoals(scoreDom, _buteursDom,
        _buteursDomString, _buteursDomCount, _buteursDomCountsInt);

    final int nbChampsExt = checkMultipleGoals(scoreExt, _buteursExt,
        _buteursExtString, _buteursExtCount, _buteursExtCountsInt);

    while (_buteursDom.length < nbChampsDom) {
      final idx = _buteursDom.length;
      final ctrl = _createControllerWithSync(_buteursDomString, idx);
      _buteursDom.add(ctrl);
      final ctrlCount = _createControllerWithSync(
        _buteursDomCountsInt.map((c) => c.toString()).toList(),
        idx,
      );
      ctrlCount.value = TextEditingValue(text: '1');
      _buteursDomCount.add(ctrlCount);
    }

    while (_buteursDom.length > nbChampsDom) {
      final removed = _buteursDom.removeLast();
      removed.dispose();
      final removedCount = _buteursDomCount.removeLast();
      removedCount.dispose();
    }

    while (_buteursExt.length < nbChampsExt) {
      final idx = _buteursExt.length;
      final ctrl = _createControllerWithSync(_buteursExtString, idx);
      _buteursExt.add(ctrl);
      final ctrlCount = _createControllerWithSync(
        _buteursExtCountsInt.map((c) => c.toString()).toList(),
        idx,
      );
      ctrlCount.value = TextEditingValue(text: '1');
      _buteursExtCount.add(ctrlCount);
    }
    while (_buteursExt.length > nbChampsExt) {
      final removed = _buteursExt.removeLast();
      removed.dispose();
      final removedCount = _buteursDom.removeLast();
      removedCount.dispose();
    }

    setState(() {});
  }

  int maxValueWithScore(int index, int score) {
    int count = 0;
    for (int i = 0; i < _buteursDomCount.length; i++) {
      if (i < index) {
        count += int.tryParse(_buteursDomCount[i].text) ?? 1;
      }
    }
    return score - count;
  }

  Widget buildEquipeTypeAhead(
      {required TextEditingController controller,
      required void Function(Equipe) onSuggestionSelected,
      required ThemeData theme,
      required ValueNotifier<bool> focusNotifier,
      required FocusNode focusNode,
      String labelText = 'Équipe'}) {
    return TypeAheadField<Equipe>(
      focusNode: focusNode,
      controller: controller,
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
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: labelText,
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
        final q = controller.text;
        if (q.length < 3) return [];
        return await widget.equipeRepository.searchTeams(q);
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

  Widget buildButeursColumn({
    required List<TextEditingController> buteursControllers,
    required List<TextEditingController> buteursCountControllers,
    required List<String> buteursStrings,
    required List<int> buteursCountsInt,
    required int score,
    required ThemeData theme,
  }) {
    focusNodesButeurs.clear();
    focusNodesButeurs =
        List.generate(buteursControllers.length, (_) => FocusNode());
    return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: SizedBox(
          height: 58 *
              (buteursControllers.length <= 5
                  ? buteursControllers.length.toDouble()
                  : 5.0),
          child: SingleChildScrollView(
            child: Column(
              children: buteursControllers.map((buteurController) {
                final index = buteursControllers.indexOf(buteurController);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 85,
                        child: TextFormField(
                          focusNode: focusNodesButeurs[index],
                          enabled: index == 0 ||
                              buteursStrings[index - 1].isNotEmpty,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            _updateButeurs();
                            if (index + 1 >= buteursControllers.length) return;
                            FocusScope.of(context)
                                .requestFocus(focusNodesButeurs[index + 1]);
                          },
                          textCapitalization: TextCapitalization.words,
                          controller: buteurController,
                          onChanged: (value) {
                            if (index < buteursStrings.length) {
                              buteursStrings[index] = value;
                            } else {
                              buteursStrings.add(value);
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Buteur ${index + 1}',
                            filled: true,
                            fillColor: theme.secondaryHeaderColor,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 15,
                        child: Padding(
                          padding: EdgeInsetsGeometry.directional(start: 5),
                          child: TextFormField(
                            enabled: index == 0 ||
                                buteursStrings[index - 1].isNotEmpty,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            controller: buteursCountControllers[index],
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(
                                  score.toString().length),
                            ],
                            onFieldSubmitted: (value) {
                              int maxValue = maxValueWithScore(index, score);
                              int parsedValue = int.tryParse(value) ?? 1;
                              if (parsedValue > maxValue) {
                                parsedValue = maxValue;
                                buteursCountControllers[index].text =
                                    parsedValue.toString();
                                Fluttertoast.showToast(
                                  msg:
                                      "Le nombre de buts ne peut pas dépasser le score ! ($score)",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.black54,
                                  textColor: Colors.white,
                                );
                              }
                              if (index < buteursCountsInt.length) {
                                buteursCountsInt[index] = parsedValue;
                              } else {
                                buteursCountsInt.add(parsedValue);
                              }
                              _updateButeurs();
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: theme.secondaryHeaderColor,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ));
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
                        setState(() {});
                        FocusScope.of(context).requestFocus(focusNodes[1]);
                      },
                      focusNotifier: _equipeDomicileHasFocus,
                      labelText: 'Domicile',
                      focusNode: focusNodes[0],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Score domicile
                  SizedBox(
                    width: 45,
                    child: TextFormField(
                      focusNode: focusNodes[1],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (String value) {
                        if (value.isEmpty || value == '0') {
                          _showDom = false;
                          setState(() {});
                        }
                        FocusScope.of(context).requestFocus(focusNodes[2]);
                      },
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
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
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
                      focusNode: focusNodes[2],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(focusNodes[3]);
                      },
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
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
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
                        setState(() {});
                        FocusScope.of(context).requestFocus(focusNodes[4]);
                      },
                      focusNotifier: _equipeExterieurHasFocus,
                      labelText: 'Éxterieur',
                      focusNode: focusNodes[3],
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
                      focusNode: focusNodes[4],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(focusNodes[5]);
                      },
                      controller: _competitionController,
                      decoration: InputDecoration(
                        labelText: 'Compétition',
                        filled: true,
                        fillColor: theme.secondaryHeaderColor,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Entrez une compétition'
                          : null,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Date
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      focusNode: focusNodes[5],
                      textInputAction: TextInputAction.next,
                      controller: _dateController,
                      readOnly: true,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        filled: true,
                        fillColor: theme.secondaryHeaderColor,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
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

              const SizedBox(height: 12),

              // Buteurs
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _showDom
                            ? theme.focusColor
                            : theme.secondaryHeaderColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black),
                      ),
                      child: TextButton(
                        onPressed: () {
                          if (_scoreDomController.text == '0' ||
                              _scoreDomController.text.isEmpty) {
                            return;
                          }
                          setState(() {
                            _showDom = !_showDom;
                            _showExt = false;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors
                              .transparent, // on laisse le container gérer le fond
                        ),
                        child: Text(
                          _equipeDomicileController.text.isNotEmpty
                              ? "Buteurs ${_equipeDomicileController.text}"
                              : "Buteurs domicile",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _showExt
                            ? theme.focusColor
                            : theme.secondaryHeaderColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black),
                      ),
                      child: TextButton(
                        onPressed: () {
                          if (_scoreExtController.text == '0' ||
                              _scoreExtController.text.isEmpty) {
                            return;
                          }
                          setState(() {
                            _showExt = !_showExt;
                            _showDom = false;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.transparent,
                        ),
                        child: Text(
                          _equipeExterieurController.text.isNotEmpty
                              ? "Buteurs ${_equipeExterieurController.text}"
                              : "Buteurs extérieur",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (_showDom)
                buildButeursColumn(
                  buteursControllers: _buteursDom,
                  buteursCountControllers: _buteursDomCount,
                  buteursStrings: _buteursDomString,
                  buteursCountsInt: _buteursDomCountsInt,
                  score: int.tryParse(_scoreDomController.text) ?? 0,
                  theme: theme,
                ),

              if (_showExt)
                buildButeursColumn(
                  buteursControllers: _buteursExt,
                  buteursCountControllers: _buteursExtCount,
                  buteursStrings: _buteursExtString,
                  buteursCountsInt: _buteursExtCountsInt,
                  score: int.tryParse(_scoreExtController.text) ?? 0,
                  theme: theme,
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
