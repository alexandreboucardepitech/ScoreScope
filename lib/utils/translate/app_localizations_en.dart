// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get autresMatchs => 'Other matches';

  @override
  String get matchsDuJour => 'Today\'s matches';

  @override
  String get erreurLorsDuChargementDesDemandes => 'Error loading requests';

  @override
  String get tous => 'All';

  @override
  String get veuillezVerifierVotreEmailAvantDeVousConnecter =>
      'Please verify your email before logging in';

  @override
  String get utilisateurNonAuthentifie => 'Unauthenticated user';

  @override
  String get erreurLorsDeLaConnexionAvecApple => 'Error logging in with Apple';

  @override
  String get quelquUn => 'Someone';

  @override
  String get ceProfilNExistePas => 'This profile does not exist';

  @override
  String get utilisateurInvalide => 'Invalid user';

  @override
  String get utilisateurNonConnecte => 'User not logged in';

  @override
  String get emailIntrouvable => 'Email not found';

  @override
  String get documentUtilisateurIntrouvable => 'User document not found';

  @override
  String get compteDejaSupprime => 'Account already deleted';

  @override
  String get equipes => 'Teams';

  @override
  String get matchs => 'Matches';

  @override
  String get competitions => 'Competitions';

  @override
  String get joueurs => 'Players';

  @override
  String get domicile => 'Home';

  @override
  String get nuls => 'Draws';

  @override
  String get exterieur => 'Away';

  @override
  String get stade => 'Stadium';

  @override
  String get tele => 'TV';

  @override
  String get bar => 'Bar';

  @override
  String get victoires => 'Wins';

  @override
  String get defaites => 'Losses';

  @override
  String get vous => 'you';

  @override
  String get avec => 'with';

  @override
  String get et => 'and';

  @override
  String get autres => 'others';

  @override
  String get demandeDAmiEnvoyeeAvecSucces =>
      'Friend request sent successfully!';

  @override
  String get demandeDAmiAnnuleeAvecSucces =>
      'Friend request canceled successfully!';

  @override
  String get demandeAcceptee => 'Request accepted!';

  @override
  String get amiRetireAvecSucces => 'Friend removed successfully!';

  @override
  String get utilisateurBloqueAvecSucces => 'User blocked successfully!';

  @override
  String get utilisateurDebloqueAvecSucces => 'User unblocked successfully!';

  @override
  String get actionEffectueeAvecSucces => 'Action completed successfully!';

  @override
  String get csc => 'OG';

  @override
  String get pen => 'Pen';

  @override
  String typeInvalidePourMapStringStringX(String runtimeType) {
    return 'Invalid type for Map<String,String>: $runtimeType';
  }

  @override
  String typeInvalidePourMapStringIntX(String runtimeType) {
    return 'Invalid type for Map<String,int>: $runtimeType';
  }

  @override
  String get aujourdHui => 'Today';

  @override
  String get hier => 'Yesterday';

  @override
  String get demain => 'Tomorrow';

  @override
  String get aucunMatchCeJourLa => 'No matches on this day';

  @override
  String get chargement => 'Loading…';

  @override
  String get recuperationDesMatchs => 'Fetching matches…';

  @override
  String get chargementDesDetailsDesMatchs => 'Loading match details…';

  @override
  String get calculDesStatistiques => 'Calculating statistics';

  @override
  String get petiteSemaineFootball => '👀 Quiet football week';

  @override
  String footballSpectacleXAvec3Buts(String value1) {
    return '🍿 Spectacular football • $value1% with 3+ goals';
  }

  @override
  String defensesAbsentesXButsMatch(String value1) {
    return '💥 Missing defenses • $value1 goals/match';
  }

  @override
  String semaineChaotiqueXMatchsAvec5Buts(String veryHighScoring) {
    return '🔥 Chaotic week • $veryHighScoring matches with 5+ goals';
  }

  @override
  String get aucun00AuProgramme => '🎯 No 0-0 on the schedule';

  @override
  String get defensesEnCartonAucunMatchAMoinsDe2Buts =>
      '🤐 Cardboard defenses • No match under 2 goals';

  @override
  String suspenseTotalXMatchsAUnButDEcart(String closeGames) {
    return '⚡ Total suspense • $closeGames matches with a one-goal difference';
  }

  @override
  String attaquantsEnVacancesXButsMatch(String value1) {
    return '😴 Strikers on vacation • $value1 goals/match';
  }

  @override
  String gardiensEnFeuXCleanSheets(String cleanSheets) {
    return '🧤 Goalkeepers on fire • $cleanSheets clean sheets';
  }

  @override
  String impossibleDeSeDepartagerXMatchsNuls(String draws) {
    return '🤝 Can\'t be separated • $draws draws';
  }

  @override
  String semaineDecevanteX10DeMoyenne(String value1) {
    return '📉 Disappointing week • $value1/10 average';
  }

  @override
  String quelquesPurgesAuProgrammeXMatchsSous510(String badMatches) {
    return '💀 Some dreadful games • $badMatches matches under 5/10';
  }

  @override
  String semaineMemorableXMatchsNotes8OuPlus(String greatMatches) {
    return '🔥 Memorable week • $greatMatches matches rated 8 or higher';
  }

  @override
  String semaineValideeX10DeMoyenne(String value1) {
    return '🌟 Successful week • $value1/10 average';
  }

  @override
  String get aucunFlopAuProgrammeTousLesMatchsNotes7OuPlus =>
      '🎬 No flops scheduled • All matches rated 7 or higher';

  @override
  String modeXActive(String topCompetitionName) {
    return '🏆 $topCompetitionName mode activated';
  }

  @override
  String marathonFootballXMatchsAuProgramme(String n) {
    return '📺 Football marathon • $n matches scheduled';
  }

  @override
  String festivalOffensifXButsCetteSemaine(String totalGoals) {
    return '⚽ Scoring festival • $totalGoals goals this week';
  }

  @override
  String semaineFootballValideeXMatchsRegardes(String n) {
    return '👀 Football week approved • $n matches watched';
  }

  @override
  String get recapDeLaSemaine => 'Week recap';

  @override
  String get impossibleDeChargerLeRecap => 'Unable to load the recap';

  @override
  String get aucunMatchCetteSemaine => 'No matches this week';

  @override
  String get ajouteLesMatchsQueTuRegardes =>
      'Add the matches you watch\nto see your stats here!';

  @override
  String get partagerMonRecap => 'Share my recap';

  @override
  String xMatchs(String totalNbMatches) {
    return '$totalNbMatches matches';
  }

  @override
  String xButs(String totalNbGoalsAllTime) {
    return '$totalNbGoalsAllTime goals';
  }

  @override
  String matchXRegardeX(String value1) {
    return 'match$value1 watched';
  }

  @override
  String butXVus(String value1) {
    return 'goal$value1 seen';
  }

  @override
  String get noteMoyenne => 'average rating';

  @override
  String get meilleurMatch => '🏆 Best match';

  @override
  String get mvp => 'MVP';

  @override
  String get mvpDeLaSemaine => 'MVP of the week';

  @override
  String get competitionPreferee => '🏅 Favorite competition';

  @override
  String xMatchX(String topCompetitionCount, String value2) {
    return '$topCompetitionCount match$value2';
  }

  @override
  String get serie => '🔥 Streak';

  @override
  String get semainesConsecutives => 'consecutive\nweeks';

  @override
  String get voiciMonRecapFootDeLaSemaine =>
      'Here is my football recap of the week!⚽📊';

  @override
  String get decouvrezLeVotreTelechargezScorescopeapp =>
      'Discover yours, download @ScoreScopeApp!';

  @override
  String get erreurDeChargement => 'Loading error';

  @override
  String get details => 'Details';

  @override
  String get commentaires => 'Comments';

  @override
  String get pasEncoreDeCommentaires => 'No comments yet';

  @override
  String demandesDAmisX(String value1) {
    return 'Friend requests$value1';
  }

  @override
  String get impossibleDeChargerLeFil => 'Unable to load feed';

  @override
  String get reessayer => 'Retry';

  @override
  String get aucuneActiviteRecenteDeVosAmis =>
      'No recent activity from your friends';

  @override
  String get invitezDesAmisPourVoirLeurActiviteIci =>
      'Invite friends to see their activity here';

  @override
  String get filDActuDesAmis => 'Friends\' feed';

  @override
  String get notifications => 'Notifications';

  @override
  String get impossibleDeChargerLesDonnees => 'Unable to load data';

  @override
  String get etesVousSurDeVouloirSupprimerCeMatch =>
      'Are you sure you want to delete this match?\nThis will remove your rating and MVP vote, and it will no longer appear on your profile';

  @override
  String get miTemps => 'Half-time';

  @override
  String get infos => 'Info';

  @override
  String get compositions => 'Lineups';

  @override
  String get mesAmis => 'My Friends';

  @override
  String jAiNoteXXSurScorescopeapp(String home, String away) {
    return 'I rated $home - $away on @ScoreScopeApp!';
  }

  @override
  String get partagerCeMatch => 'Share this match';

  @override
  String get preparation => 'Preparing...';

  @override
  String get joueurIntrouvable => 'Player not found';

  @override
  String get statistiquesDeMesMatchsVus => 'Statistics of my watched matches';

  @override
  String get statistiquesGlobales => 'Overall statistics';

  @override
  String get matchsVus => 'Matches watched';

  @override
  String get matchsJoues => 'Matches played';

  @override
  String get butsMarquesVus => 'Goals scored (watched)';

  @override
  String get butsMarques => 'Goals scored';

  @override
  String get mesVotesMvp => 'My MVP votes';

  @override
  String get votesMvp => 'MVP votes';

  @override
  String get eluMvp => 'Voted MVP';

  @override
  String xAns(String value1) {
    return '$value1 years';
  }

  @override
  String get mesStats => 'My stats';

  @override
  String get global => 'Overall';

  @override
  String get equipeIntrouvable => 'Team not found';

  @override
  String get differenceDeButsDesMatchsVus =>
      'Goal difference from watched matches';

  @override
  String get differenceDeButs => 'Goal difference';

  @override
  String get butsEncaissesVus => 'Goals conceded (watched)';

  @override
  String get butsEncaisses => 'Goals conceded';

  @override
  String get maNoteMoyenneDesMatchs => 'My average match rating';

  @override
  String get noteMoyenneDesMatchs => 'Average match rating';

  @override
  String get monMvpLePlusVote => 'My most voted MVP';

  @override
  String get mvpLePlusVote => 'Most voted MVP';

  @override
  String get ratioVictoiresDefaitesMesMatchsVus =>
      'Win/loss ratio (my watched matches)';

  @override
  String get ratioVictoiresDefaites => 'Win/loss ratio';

  @override
  String get scorescopeEnEstEncoreASesDebuts =>
      'ScoreScope is still in its early stages 🙌\n\n';

  @override
  String get tousLesRetoursSontLesBienvenusIdeesBugsAmeliorationsUi =>
      'All feedback is welcome: ideas, bugs, UI improvements… ';

  @override
  String get nHesiteSurtoutPas => 'don\'t hesitate at all!';

  @override
  String get titre => 'Title';

  @override
  String get exBugLorsDuVotePourLeMvp => 'Ex: Bug when voting for MVP';

  @override
  String get detail => 'Details';

  @override
  String get expliqueTonRetourCeQuiNeMarchePasCeQueTuAimeraisVoir =>
      'Explain your feedback: what isn\'t working, what you would like to see...';

  @override
  String get envoyer => 'Send';

  @override
  String xRequis(String label) {
    return '$label required';
  }

  @override
  String get email => 'Email';

  @override
  String get emailInvalide => 'Invalid email';

  @override
  String get motDePasse => 'Password';

  @override
  String get confirmerLeMotDePasse => 'Confirm password';

  @override
  String get auMoins6Caracteres => 'At least 6 characters';

  @override
  String get connexion => 'Login';

  @override
  String get connecteToiPourAccederAScorescope =>
      'Log in to access ScoreScope!';

  @override
  String get seConnecter => 'Log in';

  @override
  String get continuerAvecApple => 'Continue with Apple';

  @override
  String get continuerAvecGoogle => 'Continue with Google';

  @override
  String get creerUnCompte => 'Create an account';

  @override
  String get verifieTonEmail => 'Verify your email 📩';

  @override
  String get unEmailDeConfirmationAEteEnvoye =>
      'A confirmation email has been sent.\nClick on the link before logging in.\n\nPlease remember to check your spam folder!';

  @override
  String get ok => 'OK';

  @override
  String get impossibleDeCreerLeCompte => 'Unable to create account.';

  @override
  String get erreurCreationCompte => 'Account creation error';

  @override
  String get erreurInconnue => 'Unknown error';

  @override
  String get lesMotsDePasseNeCorrespondentPas => 'Passwords do not match';

  @override
  String get rejoinsLaCommunauteScorescope => 'Join the ScoreScope community!';

  @override
  String get creerMonCompte => 'Create my account';

  @override
  String get dejaUnCompteSeConnecter => 'Already have an account? Log in';

  @override
  String get utilisateurDebloque => 'User unblocked';

  @override
  String get erreurLorsDuDeblocage => 'Error unblocking user';

  @override
  String get utilisateursBloques => 'Blocked users';

  @override
  String get aucunUtilisateurBloque => 'No blocked users';

  @override
  String get rechercher => 'Search...';

  @override
  String get leNomDUtilisateurEstObligatoire => 'Username is required';

  @override
  String supprimerX(String teamName) {
    return 'Remove $teamName?';
  }

  @override
  String voulezVousSupprimerXDeVosEquipesPreferees(String teamName) {
    return 'Do you want to remove $teamName from your favorite teams?';
  }

  @override
  String get annuler => 'Cancel';

  @override
  String get supprimer => 'Remove';

  @override
  String voulezVousSupprimerXDeVosCompetitionsPreferees(
      String competitionName) {
    return 'Do you want to remove $competitionName from your favorite competitions?';
  }

  @override
  String get nomDUtilisateur => 'Username';

  @override
  String get continuer => 'Continue';

  @override
  String get enregistrer => 'Save';

  @override
  String get amis => 'Friends';

  @override
  String get demandesRecues => 'requests received';

  @override
  String get demandesEnvoyees => 'requests sent';

  @override
  String amisDeX(String displayName) {
    return '$displayName\'s Friends';
  }

  @override
  String get amis2 => 'Friends';

  @override
  String get recues => 'Received';

  @override
  String get envoyees => 'Sent';

  @override
  String get aucunAmi => 'No friends';

  @override
  String get aucuneDemandeRecue => 'No requests received';

  @override
  String get aucuneDemandeEnvoyee => 'No requests sent';

  @override
  String get erreurLorsDeLActionSurLUtilisateur =>
      'Error while processing user action';

  @override
  String get bienvenueSurScorescope => 'Welcome to ScoreScope!';

  @override
  String get bienvenueSurScorescopeDescription =>
      '1: Log the matches you watched, rate them, and vote for the best player.\n2: Add friends and share the matches you watched.\n3: Discover dozens of stats about your viewing habits.\n\nWith ScoreScope, keep a memory of every match exactly as you experienced it!';

  @override
  String get choisisTesEquipesPreferees => 'Choose your favorite teams';

  @override
  String get ajouterDesEquipes => 'Add teams';

  @override
  String get choisisTesCompetitionsPreferees =>
      'Choose your favorite competitions';

  @override
  String get ajouterDesCompetitions => 'Add competitions';

  @override
  String get commenceLAventureScorescope => 'Start the ScoreScope adventure!';

  @override
  String get personnaliseTonProfilPourEntrerDansLApp =>
      'Customize your profile to enter the app';

  @override
  String get terminer => 'Finish';

  @override
  String get passer => 'Skip';

  @override
  String bloquerX(String displayName) {
    return 'Block $displayName?';
  }

  @override
  String voulezVousBloquerX(String displayName) {
    return 'Do you want to block $displayName?\nThis user will no longer have access to your posts';
  }

  @override
  String get bloquer => 'Block';

  @override
  String get ceCompteEstPrive => 'This account is private';

  @override
  String get ajoutezCetAmiPourSuivreSonActualite =>
      'Add this friend to follow their activity!';

  @override
  String get unEmailDeConfirmationAEteEnvoyeAVotreNouvelleAdresse =>
      'A confirmation email has been sent to your new address';

  @override
  String get unEmailDeConfirmationAEteEnvoye2 =>
      'A confirmation email has been sent';

  @override
  String get motDePasseIncorrect => 'Incorrect password';

  @override
  String get confirmezVotreIdentite => 'Confirm your identity';

  @override
  String get confirmer => 'Confirm';

  @override
  String get modifierLEmail => 'Change email';

  @override
  String get emailActuel => 'Current email';

  @override
  String get nouvelEmail => 'New email';

  @override
  String get mettreAJour => 'Update';

  @override
  String get motDePasseMisAJourAvecSucces => 'Password updated successfully';

  @override
  String get motDePasseActuelIncorrect => 'Incorrect current password';

  @override
  String get modifierLeMotDePasse => 'Change password';

  @override
  String get motDePasseActuel => 'Current password';

  @override
  String get nouveauMotDePasse => 'New password';

  @override
  String get ceCompteGoogleEstDejaUtiliseParUnAutreUtilisateur =>
      'This Google account is already in use by another user.';

  @override
  String get erreurGoogle => 'Google error';

  @override
  String get erreurLorsDeLaConnexionGoogle => 'Error during Google login';

  @override
  String get vousDevezAvoirAuMoinsUneMethodeDeConnexionActive =>
      'You must have at least one active login method';

  @override
  String get compteGoogleDeconnecte => 'Google account disconnected';

  @override
  String get erreurLorsDeLaDeconnexion => 'Error during logout';

  @override
  String get impossibleDeRecupererVotreEmail => 'Unable to retrieve your email';

  @override
  String get motDePasseAjouteAvecSucces => 'Password added successfully';

  @override
  String get erreur => 'Error';

  @override
  String get motDePasseSupprime => 'Password removed';

  @override
  String get erreurLorsDeLaSuppression => 'Error during deletion';

  @override
  String get creerUnMotDePasse => 'Create a password';

  @override
  String get nouveauMotDePasseMin6Caracteres =>
      'New password (min. 6 characters)';

  @override
  String get valider => 'Confirm';

  @override
  String get connecte => 'Connected';

  @override
  String get nonConnecte => 'Not connected';

  @override
  String get delier => 'Unlink';

  @override
  String get connecter => 'Connect';

  @override
  String get comptesConnectes => 'Connected accounts';

  @override
  String get emailMotDePasse => 'Email / Password';

  @override
  String get google => 'Google';

  @override
  String get compteGoogleConnecte => 'Google account connected';

  @override
  String get securite => 'Security';

  @override
  String get zoneSensible => 'Danger zone';

  @override
  String get seDeconnecter => 'Log out';

  @override
  String get supprimerLesDonnees => 'Delete data';

  @override
  String get supprimerLeCompte => 'Delete account';

  @override
  String get voulezVousVraimentVousDeconnecter =>
      'Are you sure you want to log out?';

  @override
  String get supprimerLesMatchsRegardes => 'Delete watched matches';

  @override
  String get supprimerLesAmis => 'Delete friends';

  @override
  String get supprimerLesNotifications => 'Delete notifications';

  @override
  String get reinitialiserLesPreferences => 'Reset preferences';

  @override
  String get supprimerLesMatchsRegardesEnsemble =>
      'Delete matches watched together';

  @override
  String get donneesSupprimeesAvecSucces => 'Data deleted successfully';

  @override
  String get cetteActionEstIrreversibleToutesVosDonneesSerontDefinitivementSupprimees =>
      'This action is irreversible. All your data will be permanently deleted';

  @override
  String get compteSupprimeAvecSucces => 'Account deleted successfully';

  @override
  String get compte => 'Account';

  @override
  String get comptePrive => 'Private account';

  @override
  String get autresUtilisateurs => 'Other users';

  @override
  String get listeDesUtilisateursBloques => 'Blocked users list';

  @override
  String get general => 'General';

  @override
  String get activerLesNotifications => 'Enable notifications';

  @override
  String get social => 'Social';

  @override
  String get demandesDAmis => 'Friend requests';

  @override
  String get demandeDAmiAcceptee => 'Friend request accepted';

  @override
  String get reactionsSurTesMatchs => 'Reactions on your matches';

  @override
  String get commentairesSurTesMatchs => 'Comments on your matches';

  @override
  String get finDeMatchEquipeFavorite => 'Favorite team match end';

  @override
  String get recapHebdomadaire => 'Weekly recap';

  @override
  String get theme => 'Theme';

  @override
  String get langue => 'Language';

  @override
  String get modeDeVisionnageParDefaut => 'Default viewing mode';

  @override
  String get utiliserLeCache => 'Use cache';

  @override
  String get conditionsDUtilisation => 'Terms of Service';

  @override
  String
      get enUtilisantScorescopeVousAcceptezDUtiliserLApplicationDeManiereResponsable =>
          'By using ScoreScope, you agree to use the application responsibly.';

  @override
  String get vousEtesResponsableDuContenuQueVousPubliezNotesAvisMvpEtc =>
      'You are responsible for the content you publish (ratings, reviews, MVP, etc.).';

  @override
  String get scorescopeSeReserveLeDroitDeSupprimerToutContenuInapproprie =>
      'ScoreScope reserves the right to remove any inappropriate content.';

  @override
  String get lApplicationEstFournieTelleQuelleSansGarantieDeDisponibilitePermanente =>
      'The application is provided as is, without guarantee of permanent availability.';

  @override
  String get politiqueDeConfidentialite => 'Privacy Policy';

  @override
  String get scorescopeCollecteUniquementLesDonneesNecessairesAuFonctionnementDeLApplicationCompteMatchsInteractionsSociales =>
      'ScoreScope only collects data necessary for the application\'s operation (account, matches, social interactions).';

  @override
  String get vosDonneesNeSontPasRevenduesADesTiers =>
      'Your data is not resold to third parties.';

  @override
  String get vousPouvezDemanderLaSuppressionDeVotreCompteAToutMoment =>
      'You can request the deletion of your account at any time.';

  @override
  String get nousFaisonsDeNotreMieuxPourProtegerVosDonnees =>
      'We do our best to protect your data.';

  @override
  String get supportInformations => 'Support & Information';

  @override
  String get aPropos => 'About';

  @override
  String get signalerUnBug => 'Report a bug';

  @override
  String get cgu => 'Terms and Conditions';

  @override
  String get version => 'Version';

  @override
  String get tonCarnetDeMatchsDeFoot => 'Your football match logbook ⚽';

  @override
  String get noteLesMatchsQueTuRegardesElisLeMvpEtPartageTonExperienceAvecTesAmis =>
      'Rate the matches you watch, elect the MVP, and share your experience with your friends';

  @override
  String get fermer => 'Close';

  @override
  String saisonXX(String season, String totalSeasons) {
    return 'Season $season/$totalSeasons';
  }

  @override
  String get aucunAmiNAVuCeMatch => 'No friends watched this match';

  @override
  String get utilisateur => 'User';

  @override
  String vousAvezSupprimeLaReactionX(String emoji) {
    return 'You removed the reaction $emoji';
  }

  @override
  String get ecrireUnCommentaire => 'Write a comment';

  @override
  String get ecrisUnCommentaire => 'Write a comment...';

  @override
  String get ajouteLesAmisAvecQuiTuAsRegardeLeMatch =>
      'Add the friends you watched the match with';

  @override
  String get rechercherUnAmi => 'Search for a friend...';

  @override
  String get aucunAmiTrouve => 'No friends found';

  @override
  String get enAttente => 'Pending';

  @override
  String get laCompositionNEstPasEncoreDisponible =>
      'The lineup is not available yet';

  @override
  String get remplacants => 'Substitutes';

  @override
  String voulezVousSupprimerXDesAmisQuiOntRegardeLeMatchAvecVous(
      String displayName) {
    return 'Do you want to remove $displayName from the friends who watched the match with you?';
  }

  @override
  String get leMatchNAPasEncoreCommence => 'The match hasn\'t started yet!';

  @override
  String get activeLesNotifications => 'Enable notifications';

  @override
  String get impossibleDeChargerLaListeDesAmis => 'Unable to load friend list';

  @override
  String get impossibleDeRecupererLUtilisateur => 'Unable to retrieve user';

  @override
  String get echecDeLaSauvegardeReessayePlusTard =>
      'Save failed — try again later';

  @override
  String get visionnage => 'Viewing';

  @override
  String get choisirLeModeDeVisionnage => 'Choose viewing mode';

  @override
  String get confirme => 'Confirmed';

  @override
  String get regardeAvec => 'Watched with';

  @override
  String get tuAsRegardeCeMatchAvecDesAmis =>
      'Did you watch this match with friends?';

  @override
  String get ajouteLesAmisAvecQuiTuAsVuCeMatch =>
      'Add the friends you watched this match with';

  @override
  String get ajouterUnAmi => 'Add a friend';

  @override
  String get mt => 'HT';

  @override
  String get toutMarquerCommeVu => 'Mark all as seen';

  @override
  String get aucuneNouvelleNotification => 'No new notifications';

  @override
  String get dejaVues => 'Already seen';

  @override
  String get invitationARegarderLeMatchEnsemble =>
      'Invitation to watch the match together';

  @override
  String acceptezVousLInvitationARegarderLeMatchAvecX(String displayName) {
    return 'Do you accept the invitation to watch the match with $displayName?';
  }

  @override
  String get refuser => 'Decline';

  @override
  String get accepter => 'Accept';

  @override
  String get ontCommenteVotreMatch => 'commented on your match';

  @override
  String get aCommenteVotreMatch => 'commented on your match';

  @override
  String get ontReagiAVotreMatch => 'reacted to your match';

  @override
  String get aReagiAVotreMatch => 'reacted to your match';

  @override
  String get vousInviteARegarderLeMatchEnsemble =>
      'invites you to watch the match together';

  @override
  String get aInteragiAvecVotrePost => 'interacted with your post';

  @override
  String etXAutres(String remaining) {
    return 'and $remaining others';
  }

  @override
  String get aucuneCompetitionPreferee => 'No favorite competitions';

  @override
  String xMatchsRegardes(String nbMatchs) {
    return '$nbMatchs matches watched';
  }

  @override
  String get aucuneEquipePreferee => 'No favorite teams';

  @override
  String get aucunMatchFavori => 'No favorite matches';

  @override
  String get aucunMatchRegarde => 'No matches watched';

  @override
  String get erreurAucunUtilisateurNEstSpecifie => 'Error: no user specified';

  @override
  String get modifierLeProfil => 'Edit profile';

  @override
  String get demandeRecue => 'Request received';

  @override
  String get bloque => 'Blocked';

  @override
  String get ajouter => 'Add';

  @override
  String get retirerLaDemande => 'Cancel request';

  @override
  String get retirer => 'Remove';

  @override
  String get debloquer => 'Unblock';

  @override
  String get amitie => 'Friendship';

  @override
  String get cetUtilisateur => 'this user';

  @override
  String voulezVousRetirerLAmiX(String displayName) {
    return 'Do you want to remove the friend $displayName?';
  }

  @override
  String voulezVousRetirerLaDemandeDAmiAX(String displayName) {
    return 'Do you want to cancel the friend request to $displayName?';
  }

  @override
  String accepterLaDemandeDAmiDeX(String displayName) {
    return 'Accept the friend request from $displayName?';
  }

  @override
  String voulezVousDebloquerX(String displayName) {
    return 'Do you want to unblock $displayName?';
  }

  @override
  String voulezVousEnvoyerUneDemandeDAmiAX(String displayName) {
    return 'Do you want to send a friend request to $displayName?';
  }

  @override
  String get clubs => 'Clubs';

  @override
  String get international => 'International';

  @override
  String get selectionDesCompetitions => 'Competition selection';

  @override
  String get mesCompetitionsFavorites => 'My favorite competitions';

  @override
  String get toutesLesCompetitions => 'All competitions';

  @override
  String get validerLaSelection => 'Confirm selection';

  @override
  String get selectionDesEquipes => 'Team selection';

  @override
  String get rechercherUneEquipe => 'Search for a team…';

  @override
  String get rechercheTonEquipePreferee => '🔍 Search for your favorite team';

  @override
  String get mesEquipesFavorites => 'My favorite teams';

  @override
  String get aucuneEquipeTrouvee => 'No team found';

  @override
  String get resultats => 'Results';

  @override
  String get tuPeuxSelectionnerJusquA10Equipes =>
      'You can select up to 10 teams';

  @override
  String get statistiques => 'Statistics';

  @override
  String get profil => 'Profile';

  @override
  String get retours => 'Feedback';

  @override
  String get inconnu => 'Unknown';

  @override
  String get unMatch => 'one match';

  @override
  String get autres2 => 'Others';

  @override
  String get selectionnerUneDate => 'Select a date';

  @override
  String get appliquer => 'Apply';

  @override
  String get commenceATaperPourRechercher => 'Start typing to search';

  @override
  String encoreXCaractereX(String value1, String value2) {
    return '$value1 more character$value2…';
  }

  @override
  String get aucunResultat => 'No results';

  @override
  String get ajouterDesAmis => 'Add friends';

  @override
  String get rechercherUnUtilisateur => 'Search for a user';

  @override
  String tapezAuMoinsXCaracteresPourLancerLaRecherche(String minCharsToSearch) {
    return 'Type at least $minCharsToSearch characters to start searching';
  }

  @override
  String get entrezUneRecherchePourTrouverDesUtilisateurs =>
      'Enter a search to find users';

  @override
  String erreurLorsDeLaRechercheX(String error) {
    return 'Search error: $error';
  }

  @override
  String get aucunUtilisateurTrouve => 'No user found';

  @override
  String xPostsCharges(String length) {
    return '$length posts loaded';
  }

  @override
  String erreurLorsDuChargementDesDonneesUtilisateurDuMatchX(String error) {
    return 'Error loading user data for match: $error';
  }

  @override
  String get matchAjouteAuxFavoris => 'Match added to favorites';

  @override
  String get matchRetireDesFavoris => 'Match removed from favorites';

  @override
  String get erreurLorsDeLaMiseAJourDuFavori => 'Error updating favorite';

  @override
  String get rendreLeMatchPublic => 'Make match public';

  @override
  String get leMatchSeraRenduPublicEtVisibleParVosAmis =>
      'The match will be made public and visible to your friends';

  @override
  String get rendrePublic => 'Make public';

  @override
  String get rendreLeMatchPrive => 'Make match private';

  @override
  String get leMatchResteraPriveEtNeSeraPasVisibleParVosAmis =>
      'The match will remain private and won\'t be visible to your friends.';

  @override
  String get rendrePrive => 'Make private';

  @override
  String get supprimerLeMatch => 'Delete match';

  @override
  String get matchRenduPrive => 'Match made private';

  @override
  String get matchRenduPublic => 'Match made public';

  @override
  String get erreurLorsDeLaMiseAJourDeLaConfidentialite =>
      'Error updating privacy';

  @override
  String get matchSupprime => 'Match deleted';

  @override
  String get erreurLorsDeLaSuppressionDuMatch =>
      'Error deleting match (try again)';

  @override
  String notificationsXPourXX(String value1, String value2, String value3) {
    return '$value1 notifications for $value2 - $value3';
  }

  @override
  String get matchPrive => 'Private match';

  @override
  String get matchPublic => 'Public match';

  @override
  String get aRegardeCeMatch => 'watched this match';

  @override
  String get nonNote => 'Unrated';

  @override
  String get note => 'Rating';

  @override
  String get mvpVote => 'MVP voted';

  @override
  String get bio => 'Bio';

  @override
  String get equipesPreferees => 'Favorite teams';

  @override
  String get modifier => 'Edit';

  @override
  String get competitionsPreferees => 'Favorite competitions';

  @override
  String get creezVotreProfil => 'Create your profile';

  @override
  String get parametres => 'Settings';

  @override
  String get confidentialite => 'Privacy';

  @override
  String get preferences => 'Preferences';

  @override
  String get derniersMatchs => 'Latest matches';

  @override
  String get matchsFavoris => 'Favorite matches';

  @override
  String get filtrerParPeriode => 'Filter by period';

  @override
  String get periodePersonnalisee => 'Custom period';

  @override
  String get saison => 'Season';

  @override
  String get selectionnerUnePeriode => 'Select a period';

  @override
  String get selectionnerLaSaison => 'Select season';

  @override
  String get mesStatistiques => 'My statistics';

  @override
  String statistiquesDeX(String displayName) {
    return '$displayName\'s statistics';
  }

  @override
  String get filtrerParDate => 'Filter by date';

  @override
  String get afficherEnListe => 'Show as list';

  @override
  String get afficherEnCards => 'Show as cards';

  @override
  String get matchsPublicsUniquement => 'Public matches only';

  @override
  String saisonXX2(String season, String season2) {
    return 'Season: $season / $season2';
  }

  @override
  String periodeXX(String start, String end) {
    return 'Period: $start → $end';
  }

  @override
  String get habitudes => 'Habits';

  @override
  String get recapHebdo => 'WEEKLY RECAP';

  @override
  String get meilleurMatch2 => 'BEST MATCH';

  @override
  String get competition => 'COMPETITION';

  @override
  String get serie2 => 'STREAK';

  @override
  String get telechargeScorescope => 'Download ScoreScope';

  @override
  String xXVsSemainePrecedente(String value1, String diff) {
    return '$value1$diff vs previous week,';
  }

  @override
  String get votePourMvp => 'Vote for MVP';

  @override
  String get pasDeVotePourLeMvp => 'No MVP vote';

  @override
  String get utilisateurIntrouvable => 'User not found';

  @override
  String voirTousLesXCommentaires(String length) {
    return 'View all $length comments';
  }

  @override
  String get voirTousLesCommentaires => 'View all comments';

  @override
  String get recents => 'Recent';

  @override
  String get rechercherUnEmojiParNomOuCategorie =>
      'Search for an emoji by name or category…';

  @override
  String get infosMatch => 'Match info';

  @override
  String get noteDuMatch => 'Match rating';

  @override
  String xVoteX(String noteCount, String value2) {
    return '$noteCount vote$value2';
  }

  @override
  String get moyenne => 'Average';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get effacerMaNote => 'Clear my rating';

  @override
  String get note2 => 'Rated';

  @override
  String get mvpDuMatch => 'Match MVP';

  @override
  String get aucunMvpElu => 'No MVP elected';

  @override
  String get soisLePremierAVoter => 'Be the first to vote!';

  @override
  String get votreVote => 'Your vote';

  @override
  String get changer => 'Change';

  @override
  String get voter => 'Vote';

  @override
  String get aucunJoueurSelectionne => 'No player selected';

  @override
  String get selectionnezUnJoueurPourVoter => 'Select a player to vote';

  @override
  String get vider => 'Clear';

  @override
  String get vote => 'Voted';

  @override
  String get aucunMatchEnregistre => 'No matches recorded';

  @override
  String get aucuneNotification => 'No notifications';

  @override
  String get buts => 'Goals';

  @override
  String get voirPlus => 'See more';

  @override
  String get derniersMatchsAjoutes => 'Latest added matches';

  @override
  String get matchs2 => 'matches';

  @override
  String get buts2 => 'goals';

  @override
  String get rechercherUnMatchUneEquipeUnJoueur =>
      'Search for a match, team, player…';

  @override
  String get aucuneDonneeDisponible => 'No data available';

  @override
  String get comparerAvecUnAmi => 'Compare with a friend';

  @override
  String get aucunAmiAAfficher => 'No friends to display';

  @override
  String baseSurXMatchsRegardes(String watchedMatchesCount) {
    return 'Based on $watchedMatchesCount watched matches';
  }

  @override
  String get comparer => 'Compare';

  @override
  String get mvps => 'MVPs';

  @override
  String get appuieSurUnPointPourVoirLeJoueur =>
      'Tap a point to see the player';

  @override
  String get matchsRegardes => 'watched matches';

  @override
  String get janvier => 'January';

  @override
  String get fevrier => 'February';

  @override
  String get mars => 'March';

  @override
  String get avril => 'April';

  @override
  String get mai => 'May';

  @override
  String get juin => 'June';

  @override
  String get juillet => 'July';

  @override
  String get aout => 'August';

  @override
  String get septembre => 'September';

  @override
  String get octobre => 'October';

  @override
  String get novembre => 'November';

  @override
  String get decembre => 'December';

  @override
  String get jan => 'Jan';

  @override
  String get fev => 'Feb';

  @override
  String get mar => 'Mar';

  @override
  String get avr => 'Apr';

  @override
  String get juil => 'Jul';

  @override
  String get sep => 'Sep';

  @override
  String get oct => 'Oct';

  @override
  String get nov => 'Nov';

  @override
  String get dec => 'Dec';

  @override
  String erreurLorsDuChargementDesStatistiques(String value1) {
    return 'Error loading statistics.\n$value1';
  }

  @override
  String get erreurLorsDuCalculDesStatistiques =>
      'Error calculating statistics';

  @override
  String get competitionsLesPlusSuivies => 'Most followed competitions';

  @override
  String get aucuneCompetition => 'No competition';

  @override
  String get competitionsDifferentesVues => 'Different competitions watched';

  @override
  String get butsParCompetition => 'Goals per competition';

  @override
  String get aucuneDonnee => 'No data';

  @override
  String get moyButsMatch => 'Avg goals / match';

  @override
  String get repartitionParCompetition => 'Distribution by competition';

  @override
  String get typesDeCompetitions => 'Competition types';

  @override
  String get equipesDifferentesVues => 'Different teams watched';

  @override
  String get equipesLesPlusVues => 'Most watched teams';

  @override
  String get aucuneEquipe => 'No team';

  @override
  String get equipesLesPlusVuesGagner => 'Most watched teams winning';

  @override
  String get equipesLesPlusVuesPerdre => 'Most watched teams losing';

  @override
  String get pourcentageDeVictoiresMin3MatchsVus =>
      'Win percentage (min. 3 matches watched)';

  @override
  String get pourcentageVictoires => 'Win %';

  @override
  String get butsVus => 'Goals watched';

  @override
  String get joueursLesPlusVusMarquer => 'Most watched players scoring';

  @override
  String get aucunButeur => 'No goalscorer';

  @override
  String get buteursDifferents => 'Different goalscorers';

  @override
  String get moyDesNotesDonnees => 'Avg rating given';

  @override
  String get mvpLesPlusVotes => 'Most voted MVPs';

  @override
  String get aucunMvp => 'No MVP';

  @override
  String get matchsLesMieuxNotes => 'Best rated matches';

  @override
  String get aucunMatch => 'No match';

  @override
  String get matchsLesCommentes => 'Most commented matches';

  @override
  String get matchsLesReactions => 'Most reacted matches';

  @override
  String get joursAvecLePlusDeMatchsVus => 'Days with most matches watched';

  @override
  String get typesDeVisionnage => 'Viewing types';

  @override
  String get nombreDeMatchsVusParMois => 'Number of matches watched per month';

  @override
  String get buteursLesPlusVus => 'Most watched goalscorers';

  @override
  String get aucunJoueur => 'No player';

  @override
  String get passesDecisives => 'Assists';

  @override
  String get gA => 'G+A';

  @override
  String get titularisations => 'Starts';

  @override
  String get recordDeButsSurUnMatch => 'Record goals in a match';

  @override
  String get nombreDeButsVotesMvp => 'Number of goals / MVP votes';

  @override
  String get plusGrosScore => 'Highest score';

  @override
  String get plusGrosEcart => 'Biggest margin';

  @override
  String get moyenneDifferenceButsMatch => 'Average goal diff / match';

  @override
  String get resultatsDomicileNulExterieur => 'Results (home / draw / away)';

  @override
  String get clubsVsInternationaux => 'Clubs vs Internationals';

  @override
  String get supprimerLeCommentaire => 'Remove comment';

  @override
  String get voulezVousSupprimerVotreCommentaire =>
      'Do you want to delete your comment?';

  @override
  String get monCommentaire => 'My comment';

  @override
  String get ajouterUnCommentaire => 'Add a comment';

  @override
  String get publier => 'Publish';

  @override
  String get commenter => 'Comment';

  @override
  String get quAstuPenseDeCeMatch => 'What did you think of this match?';

  @override
  String get favoris => 'Favorites';

  @override
  String chargementDesMatchsXSurX(
      String matchModelIdsLoaded, String matchIdsTotal) {
    return 'Loading matches ($matchModelIdsLoaded / $matchIdsTotal)...';
  }

  @override
  String get chargementDesEquipesEtDesJoueurs => 'Loading teams and players...';

  @override
  String get preparationDesStatistiques => 'Preparing statistics...';

  @override
  String get pret => 'Ready';
}
