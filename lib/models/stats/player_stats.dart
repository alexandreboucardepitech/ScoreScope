class PlayerStats {
  final int matchsJoues;
  final int butsMarques;
  final int votesMvp;
  final int eluMvp;
  
  final int userMatchsJoues;
  final int userButsMarques;
  final int userVotesMvp;
  final int userEluMvp;

  PlayerStats({
    required this.matchsJoues,
    required this.butsMarques,
    required this.eluMvp,
    required this.votesMvp,
    
    required this.userMatchsJoues,
    required this.userButsMarques,
    required this.userEluMvp,
    required this.userVotesMvp,
  });
}