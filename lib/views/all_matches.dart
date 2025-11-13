import 'package:flutter/material.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/widgets/match_list/match_list.dart';
import '../services/repositories/i_match_repository.dart';
import '../models/match.dart';
import 'add_match.dart';

class AllMatchesView extends StatefulWidget {
  final IMatchRepository matchRepository = RepositoryProvider.matchRepository;
  AllMatchesView({super.key});

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
    _futureMatches = widget.matchRepository.fetchAllMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text("Matchs regardés"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder<List<Match>>(
        future: _futureMatches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else {
            final matches = snapshot.data ?? [];
            return MatchList(
              matches: matches,
              header: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Matchs favoris',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newMatch = await Navigator.push<Match>(
            context,
            MaterialPageRoute(builder: (context) => AddMatchView()),
          );

          if (newMatch != null) {
            await widget.matchRepository.addMatch(newMatch);
            setState(() {
              _futureMatches = widget.matchRepository.fetchAllMatches();
            });
          }
        },
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        child: Icon(Icons.add),
      ),
    );
  }
}
