import 'package:flutter/material.dart';
import 'package:scorescope/models/joueur.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/widgets/match_details_tabs/mvp_vote_bottom_sheet.dart';

Future<Map<String, dynamic>> openBottomSheetAndVoteMVP({
  required BuildContext context,
  required MatchModel match,
  Joueur? initialUserVote,
  Joueur? preselectedPlayer,
}) async {
  Joueur? joueurSelectionne = null;
  bool enleverVote = false;
  final user = await RepositoryProvider.userRepository.getCurrentUser();
  if (user == null)
    return {"joueur": joueurSelectionne, "enleverVote": enleverVote};

  Map<String, dynamic>? result = await showVoteBottomSheet(
    context: context,
    match: match,
    initialUserVote: initialUserVote,
    preselectedPlayer: preselectedPlayer,
  );
  if (result == null) {
    joueurSelectionne = initialUserVote;
    enleverVote = false;
    return {"joueur": joueurSelectionne, "enleverVote": enleverVote};
  }

  if (result["joueur"] != null) {
    await match.voterPourMVP(userId: user.uid, joueurId: result["joueur"].id);
  }
  if (result["enleverVote"] == true) {
    await match.enleverVote(userId: user.uid);
  }

  return {"joueur": joueurSelectionne, "enleverVote": enleverVote};
}
