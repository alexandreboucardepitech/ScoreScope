import 'package:flutter/material.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';
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
  late Future<List<MatchModel>> _futureMatches;

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
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        title: Text(
          "Matchs regardés",
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
          ),
        ),
        backgroundColor: ColorPalette.background(context),
      ),
      body: FutureBuilder<List<MatchModel>>(
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
                  Icon(Icons.star, color: ColorPalette.accent(context)),
                  const SizedBox(width: 8),
                  Text(
                    'Matchs favoris',
                    style: TextStyle(
                      color: ColorPalette.textPrimary(context),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newMatch = await Navigator.push<MatchModel>(
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
        backgroundColor: ColorPalette.buttonSecondary(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
