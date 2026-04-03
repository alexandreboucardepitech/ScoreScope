import 'package:flutter/material.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/widgets/match_details_tabs/mvp_vote_bottom_sheet.dart';

Future<Joueur?> openBottomSheetAndVoteMVP({
  required BuildContext context,
  required MatchModel match,
  Joueur? initialUserVote,
  Joueur? preselectedPlayer,
}) async {
  final user = await RepositoryProvider.userRepository.getCurrentUser();
  if (user == null) return null;

  final Joueur? newJoueurSelected = await showVoteBottomSheet(
    context: context,
    match: match,
    initialUserVote: initialUserVote,
    preselectedPlayer: preselectedPlayer,
  );

  if (newJoueurSelected != null) {
    await match.voterPourMVP(userId: user.uid, joueurId: newJoueurSelected.id);
    return newJoueurSelected;
  } else if (initialUserVote != null) {
    await match.enleverVote(userId: user.uid);
  }

  return null;
}
