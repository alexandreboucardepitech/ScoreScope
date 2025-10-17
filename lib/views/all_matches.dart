import 'package:flutter/material.dart';
import '../views/match_tile.dart';
import '../services/repositories/i_match_repository.dart';
import '../models/match.dart';

class AllMatchesView extends StatefulWidget {
  final IMatchRepository repository;
  const AllMatchesView({Key? key, required this.repository}) : super(key: key);

  @override
  State<AllMatchesView> createState() => _AllMatchesViewState();
}

class _AllMatchesViewState extends State<AllMatchesView> {
  late Future<List<Match>> _futureMatches;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _futureMatches = widget.repository.fetchAllMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text("Matchs regardés"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black), // contour noir
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).secondaryHeaderColor,
        ),
        child: FutureBuilder<List<Match>>(
          future: _futureMatches,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            } else {
              final matches = snapshot.data ?? [];
              if (matches.isEmpty) {
                return const Center(child: Text('Aucun match enregistré'));
              }
              return ListView.separated(
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  return MatchTile(match: matches[index]);
                },
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.black),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: navigation vers le formulaire d'ajout
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
    );
  }
}
