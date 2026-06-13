// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get autresMatchs => 'Autres matchs';

  @override
  String get matchsDuJour => 'Matchs du jour';

  @override
  String get erreurLorsDuChargementDesDemandes =>
      'Erreur lors du chargement des demandes';

  @override
  String get tous => 'Tous';

  @override
  String get veuillezVerifierVotreEmailAvantDeVousConnecter =>
      'Veuillez vérifier votre email avant de vous connecter';

  @override
  String get utilisateurNonAuthentifie => 'Utilisateur non authentifié';

  @override
  String get erreurLorsDeLaConnexionAvecApple =>
      'Erreur lors de la connexion avec Apple';

  @override
  String get quelquUn => 'Quelqu\'un';

  @override
  String get ceProfilNExistePas => 'Ce profil n\'existe pas';

  @override
  String get utilisateurInvalide => 'Utilisateur invalide';

  @override
  String get utilisateurNonConnecte => 'Utilisateur non connecté';

  @override
  String get emailIntrouvable => 'Email introuvable';

  @override
  String get documentUtilisateurIntrouvable =>
      'Document utilisateur introuvable';

  @override
  String get compteDejaSupprime => 'Compte déjà supprimé';

  @override
  String get equipes => 'Équipes';

  @override
  String get matchs => 'Matchs';

  @override
  String get competitions => 'Compétitions';

  @override
  String get joueurs => 'Joueurs';

  @override
  String get domicile => 'Domicile';

  @override
  String get nuls => 'Nuls';

  @override
  String get exterieur => 'Extérieur';

  @override
  String get stade => 'Stade';

  @override
  String get tele => 'Télé';

  @override
  String get bar => 'Bar';

  @override
  String get victoires => 'Victoires';

  @override
  String get defaites => 'Défaites';

  @override
  String get vous => 'vous';

  @override
  String get avec => 'avec';

  @override
  String get et => 'et';

  @override
  String get autres => 'autres';

  @override
  String get demandeDAmiEnvoyeeAvecSucces =>
      'Demande d\'ami envoyée avec succès!';

  @override
  String get demandeDAmiAnnuleeAvecSucces =>
      'Demande d\'ami annulée avec succès!';

  @override
  String get demandeAcceptee => 'Demande acceptée !';

  @override
  String get amiRetireAvecSucces => 'Ami retiré avec succès!';

  @override
  String get utilisateurBloqueAvecSucces => 'Utilisateur bloqué avec succès!';

  @override
  String get utilisateurDebloqueAvecSucces =>
      'Utilisateur débloqué avec succès!';

  @override
  String get actionEffectueeAvecSucces => 'Action effectuée avec succès!';

  @override
  String get csc => 'CSC';

  @override
  String get pen => 'Pen';

  @override
  String typeInvalidePourMapStringStringX(String runtimeType) {
    return 'Type invalide pour Map<String,String>: $runtimeType';
  }

  @override
  String typeInvalidePourMapStringIntX(String runtimeType) {
    return 'Type invalide pour Map<String,int>: $runtimeType';
  }

  @override
  String get aujourdHui => 'Aujourd\'hui';

  @override
  String get hier => 'Hier';

  @override
  String get demain => 'Demain';

  @override
  String get aucunMatchCeJourLa => 'Aucun match ce jour-là';

  @override
  String get chargement => 'Chargement…';

  @override
  String get recuperationDesMatchs => 'Récupération des matchs…';

  @override
  String get chargementDesDetailsDesMatchs =>
      'Chargement des détails des matchs…';

  @override
  String get calculDesStatistiques => 'Calcul des statistiques';

  @override
  String get petiteSemaineFootball => '👀 Petite semaine football';

  @override
  String footballSpectacleXAvec3Buts(String value1) {
    return '🍿 Football spectacle • $value1% avec 3+ buts';
  }

  @override
  String defensesAbsentesXButsMatch(String value1) {
    return '💥 Défenses absentes • $value1 buts/match';
  }

  @override
  String semaineChaotiqueXMatchsAvec5Buts(String veryHighScoring) {
    return '🔥 Semaine chaotique • $veryHighScoring matchs avec 5+ buts';
  }

  @override
  String get aucun00AuProgramme => '🎯 Aucun 0-0 au programme';

  @override
  String get defensesEnCartonAucunMatchAMoinsDe2Buts =>
      '🤐 Défenses en carton • Aucun match à moins de 2 buts';

  @override
  String suspenseTotalXMatchsAUnButDEcart(String closeGames) {
    return '⚡ Suspense total • $closeGames matchs à un but d\'écart';
  }

  @override
  String attaquantsEnVacancesXButsMatch(String value1) {
    return '😴 Attaquants en vacances • $value1 buts/match';
  }

  @override
  String gardiensEnFeuXCleanSheets(String cleanSheets) {
    return '🧤 Gardiens en feu • $cleanSheets clean sheets';
  }

  @override
  String impossibleDeSeDepartagerXMatchsNuls(String draws) {
    return '🤝 Impossible de se départager • $draws matchs nuls';
  }

  @override
  String semaineDecevanteX10DeMoyenne(String value1) {
    return '📉 Semaine décevante • $value1/10 de moyenne';
  }

  @override
  String quelquesPurgesAuProgrammeXMatchsSous510(String badMatches) {
    return '💀 Quelques purges au programme • $badMatches matchs sous 5/10';
  }

  @override
  String semaineMemorableXMatchsNotes8OuPlus(String greatMatches) {
    return '🔥 Semaine mémorable • $greatMatches matchs notés 8 ou plus';
  }

  @override
  String semaineValideeX10DeMoyenne(String value1) {
    return '🌟 Semaine validée • $value1/10 de moyenne';
  }

  @override
  String get aucunFlopAuProgrammeTousLesMatchsNotes7OuPlus =>
      '🎬 Aucun flop au programme • Tous les matchs notés 7 ou plus';

  @override
  String modeXActive(String topCompetitionName) {
    return '🏆 Mode $topCompetitionName activé';
  }

  @override
  String marathonFootballXMatchsAuProgramme(String n) {
    return '📺 Marathon football • $n matchs au programme';
  }

  @override
  String festivalOffensifXButsCetteSemaine(String totalGoals) {
    return '⚽ Festival offensif • $totalGoals buts cette semaine';
  }

  @override
  String semaineFootballValideeXMatchsRegardes(String n) {
    return '👀 Semaine football validée • $n matchs regardés';
  }

  @override
  String get recapDeLaSemaine => 'Récap de la semaine';

  @override
  String get impossibleDeChargerLeRecap => 'Impossible de charger le récap';

  @override
  String get aucunMatchCetteSemaine => 'Aucun match cette semaine';

  @override
  String get ajouteLesMatchsQueTuRegardes =>
      'Ajoute les matchs que tu regardes\npour voir tes stats ici !';

  @override
  String get partagerMonRecap => 'Partager mon récap';

  @override
  String xMatchs(String totalNbMatches) {
    return '$totalNbMatches matchs';
  }

  @override
  String xButs(String totalNbGoalsAllTime) {
    return '$totalNbGoalsAllTime buts';
  }

  @override
  String matchXRegardeX(String value1) {
    return 'match$value1 regardé$value1';
  }

  @override
  String butXVus(String value1) {
    return 'but$value1 vus';
  }

  @override
  String get noteMoyenne => 'note moyenne';

  @override
  String get meilleurMatch => '🏆 Meilleur match';

  @override
  String get mvp => 'MVP';

  @override
  String get mvpDeLaSemaine => 'MVP de la semaine';

  @override
  String get competitionPreferee => '🏅 Compétition préférée';

  @override
  String xMatchX(String topCompetitionCount, String value2) {
    return '$topCompetitionCount match$value2';
  }

  @override
  String get serie => '🔥 Série';

  @override
  String get semainesConsecutives => 'semaines\nconsécutives';

  @override
  String get voiciMonRecapFootDeLaSemaine =>
      'Voici mon récap foot de la semaine !⚽📊';

  @override
  String get decouvrezLeVotreTelechargezScorescopeapp =>
      'Découvrez le votre, téléchargez @ScoreScopeApp !';

  @override
  String get erreurDeChargement => 'Erreur de chargement';

  @override
  String get details => 'Détails';

  @override
  String get commentaires => 'Commentaires';

  @override
  String get pasEncoreDeCommentaires => 'Pas encore de commentaires';

  @override
  String demandesDAmisX(String value1) {
    return 'Demandes d\'amis$value1';
  }

  @override
  String get impossibleDeChargerLeFil => 'Impossible de charger le fil';

  @override
  String get reessayer => 'Réessayer';

  @override
  String get aucuneActiviteRecenteDeVosAmis =>
      'Aucune activité récente de vos amis';

  @override
  String get invitezDesAmisPourVoirLeurActiviteIci =>
      'Invitez des amis pour voir leur activité ici';

  @override
  String get filDActuDesAmis => 'Fil d\'actu des amis';

  @override
  String get notifications => 'Notifications';

  @override
  String get impossibleDeChargerLesDonnees =>
      'Impossible de charger les données';

  @override
  String get etesVousSurDeVouloirSupprimerCeMatch =>
      'Êtes-vous sûr de vouloir supprimer ce match ?\nCela retirera votre note et votre vote MVP et il n\'apparaîtra plus sur votre profil';

  @override
  String get miTemps => 'Mi-Temps';

  @override
  String get infos => 'Infos';

  @override
  String get compositions => 'Compositions';

  @override
  String get mesAmis => 'Mes Amis';

  @override
  String jAiNoteXXSurScorescopeapp(String home, String away) {
    return 'J\'ai noté $home - $away sur @ScoreScopeApp !';
  }

  @override
  String get partagerCeMatch => 'Partager ce match';

  @override
  String get preparation => 'Préparation...';

  @override
  String get joueurIntrouvable => 'Joueur introuvable';

  @override
  String get statistiquesDeMesMatchsVus => 'Statistiques de mes matchs vus';

  @override
  String get statistiquesGlobales => 'Statistiques globales';

  @override
  String get matchsVus => 'Matchs vus';

  @override
  String get matchsJoues => 'Matchs joués';

  @override
  String get butsMarquesVus => 'Buts marqués vus';

  @override
  String get butsMarques => 'Buts marqués';

  @override
  String get mesVotesMvp => 'Mes votes MVP';

  @override
  String get votesMvp => 'Votes MVP';

  @override
  String get eluMvp => 'Élu MVP';

  @override
  String xAns(String value1) {
    return '$value1 ans';
  }

  @override
  String get mesStats => 'Mes stats';

  @override
  String get global => 'Global';

  @override
  String get equipeIntrouvable => 'Équipe introuvable';

  @override
  String get differenceDeButsDesMatchsVus =>
      'Différence de buts des matchs vus';

  @override
  String get differenceDeButs => 'Différence de buts';

  @override
  String get butsEncaissesVus => 'Buts encaissés vus';

  @override
  String get butsEncaisses => 'Buts encaissés';

  @override
  String get maNoteMoyenneDesMatchs => 'Ma note moyenne des matchs';

  @override
  String get noteMoyenneDesMatchs => 'Note moyenne des matchs';

  @override
  String get monMvpLePlusVote => 'Mon MVP le plus voté';

  @override
  String get mvpLePlusVote => 'MVP le plus voté';

  @override
  String get ratioVictoiresDefaitesMesMatchsVus =>
      'Ratio victoires/défaites (mes matchs vus)';

  @override
  String get ratioVictoiresDefaites => 'Ratio victoires/défaites';

  @override
  String get scorescopeEnEstEncoreASesDebuts =>
      'ScoreScope en est encore à ses débuts 🙌\n\n';

  @override
  String get tousLesRetoursSontLesBienvenusIdeesBugsAmeliorationsUi =>
      'Tous les retours sont les bienvenus : idées, bugs, améliorations UI… ';

  @override
  String get nHesiteSurtoutPas => 'n\'hésite surtout pas !';

  @override
  String get titre => 'Titre';

  @override
  String get exBugLorsDuVotePourLeMvp => 'Ex : Bug lors du vote pour le MVP';

  @override
  String get detail => 'Détail';

  @override
  String get expliqueTonRetourCeQuiNeMarchePasCeQueTuAimeraisVoir =>
      'Explique ton retour : ce qui ne marche pas, ce que tu aimerais voir...';

  @override
  String get envoyer => 'Envoyer';

  @override
  String xRequis(String label) {
    return '$label requis';
  }

  @override
  String get email => 'Email';

  @override
  String get emailInvalide => 'Email invalide';

  @override
  String get motDePasse => 'Mot de passe';

  @override
  String get confirmerLeMotDePasse => 'Confirmer le mot de passe';

  @override
  String get auMoins6Caracteres => 'Au moins 6 caractères';

  @override
  String get connexion => 'Connexion';

  @override
  String get connecteToiPourAccederAScorescope =>
      'Connecte-toi pour accéder à ScoreScope !';

  @override
  String get seConnecter => 'Se connecter';

  @override
  String get continuerAvecApple => 'Continuer avec Apple';

  @override
  String get continuerAvecGoogle => 'Continuer avec Google';

  @override
  String get creerUnCompte => 'Créer un compte';

  @override
  String get verifieTonEmail => 'Vérifie ton email 📩';

  @override
  String get unEmailDeConfirmationAEteEnvoye =>
      'Un email de confirmation a été envoyé.\nClique sur le lien avant de te connecter.\n\nAttention, pense à vérifier tes spams !';

  @override
  String get ok => 'OK';

  @override
  String get impossibleDeCreerLeCompte => 'Impossible de créer le compte.';

  @override
  String get erreurCreationCompte => 'Erreur création compte';

  @override
  String get erreurInconnue => 'Erreur inconnue';

  @override
  String get lesMotsDePasseNeCorrespondentPas =>
      'Les mots de passe ne correspondent pas';

  @override
  String get rejoinsLaCommunauteScorescope =>
      'Rejoins la communauté ScoreScope !';

  @override
  String get creerMonCompte => 'Créer mon compte';

  @override
  String get dejaUnCompteSeConnecter => 'Déjà un compte ? Se connecter';

  @override
  String get utilisateurDebloque => 'Utilisateur débloqué';

  @override
  String get erreurLorsDuDeblocage => 'Erreur lors du déblocage';

  @override
  String get utilisateursBloques => 'Utilisateurs bloqués';

  @override
  String get aucunUtilisateurBloque => 'Aucun utilisateur bloqué';

  @override
  String get rechercher => 'Rechercher...';

  @override
  String get leNomDUtilisateurEstObligatoire =>
      'Le nom d\'utilisateur est obligatoire';

  @override
  String supprimerX(String teamName) {
    return 'Supprimer $teamName ?';
  }

  @override
  String voulezVousSupprimerXDeVosEquipesPreferees(String teamName) {
    return 'Voulez-vous supprimer $teamName de vos équipes préférées ?';
  }

  @override
  String get annuler => 'Annuler';

  @override
  String get supprimer => 'Supprimer';

  @override
  String voulezVousSupprimerXDeVosCompetitionsPreferees(
      String competitionName) {
    return 'Voulez-vous supprimer $competitionName de vos compétitions préférées ?';
  }

  @override
  String get nomDUtilisateur => 'Nom d\'utilisateur';

  @override
  String get continuer => 'Continuer';

  @override
  String get enregistrer => 'Enregistrer';

  @override
  String get amis => 'Amis';

  @override
  String get demandesRecues => 'demandes reçues';

  @override
  String get demandesEnvoyees => 'demandes envoyées';

  @override
  String amisDeX(String displayName) {
    return 'Amis de $displayName';
  }

  @override
  String get amis2 => 'Amis';

  @override
  String get recues => 'Reçues';

  @override
  String get envoyees => 'Envoyées';

  @override
  String get aucunAmi => 'Aucun ami';

  @override
  String get aucuneDemandeRecue => 'Aucune demande reçue';

  @override
  String get aucuneDemandeEnvoyee => 'Aucune demande envoyée';

  @override
  String get erreurLorsDeLActionSurLUtilisateur =>
      'Erreur lors de l\'action sur l\'utilisateur';

  @override
  String get bienvenueSurScorescope => 'Bienvenue sur ScoreScope !';

  @override
  String get bienvenueSurScorescopeDescription =>
      '1: Répertorie les matchs que tu as regardé, donne leur une note, et vote pour le meilleur joueur.\n2: Ajoute des amis et partage les matchs que tu as regardé.\n3: Découvrez des dizaines de statistiques sur tes habitudes de visionnage.\n\nAvec ScoreScope, garde un souvenir de chaque match, tel qu\'il a été vécu !';

  @override
  String get choisisTesEquipesPreferees => 'Choisis tes équipes préférées';

  @override
  String get ajouterDesEquipes => 'Ajouter des équipes';

  @override
  String get choisisTesCompetitionsPreferees =>
      'Choisis tes compétitions préférées';

  @override
  String get ajouterDesCompetitions => 'Ajouter des compétitions';

  @override
  String get commenceLAventureScorescope => 'Commence l\'aventure ScoreScope !';

  @override
  String get personnaliseTonProfilPourEntrerDansLApp =>
      'Personnalise ton profil pour entrer dans l\'app';

  @override
  String get terminer => 'Terminer';

  @override
  String get passer => 'Passer';

  @override
  String bloquerX(String displayName) {
    return 'Bloquer $displayName?,';
  }

  @override
  String voulezVousBloquerX(String displayName) {
    return 'Voulez-vous bloquer $displayName?\nCet utilisateur ne pourra plus accéder à vos posts';
  }

  @override
  String get bloquer => 'Bloquer';

  @override
  String get ceCompteEstPrive => 'Ce compte est privé';

  @override
  String get ajoutezCetAmiPourSuivreSonActualite =>
      'Ajoutez cet ami pour suivre son actualité !';

  @override
  String get unEmailDeConfirmationAEteEnvoyeAVotreNouvelleAdresse =>
      'Un email de confirmation a été envoyé à votre nouvelle adresse';

  @override
  String get unEmailDeConfirmationAEteEnvoye2 =>
      'Un email de confirmation a été envoyé';

  @override
  String get motDePasseIncorrect => 'Mot de passe incorrect';

  @override
  String get confirmezVotreIdentite => 'Confirmez votre identité';

  @override
  String get confirmer => 'Confirmer';

  @override
  String get modifierLEmail => 'Modifier l\'email';

  @override
  String get emailActuel => 'Email actuel';

  @override
  String get nouvelEmail => 'Nouvel email';

  @override
  String get mettreAJour => 'Mettre à jour';

  @override
  String get motDePasseMisAJourAvecSucces =>
      'Mot de passe mis à jour avec succès';

  @override
  String get motDePasseActuelIncorrect => 'Mot de passe actuel incorrect';

  @override
  String get modifierLeMotDePasse => 'Modifier le mot de passe';

  @override
  String get motDePasseActuel => 'Mot de passe actuel';

  @override
  String get nouveauMotDePasse => 'Nouveau mot de passe';

  @override
  String get ceCompteGoogleEstDejaUtiliseParUnAutreUtilisateur =>
      'Ce compte Google est déjà utilisé par un autre utilisateur.';

  @override
  String get erreurGoogle => 'Erreur Google';

  @override
  String get erreurLorsDeLaConnexionGoogle =>
      'Erreur lors de la connexion Google';

  @override
  String get vousDevezAvoirAuMoinsUneMethodeDeConnexionActive =>
      'Vous devez avoir au moins une méthode de connexion active';

  @override
  String get compteGoogleDeconnecte => 'Compte Google déconnecté';

  @override
  String get erreurLorsDeLaDeconnexion => 'Erreur lors de la déconnexion';

  @override
  String get impossibleDeRecupererVotreEmail =>
      'Impossible de récupérer votre email';

  @override
  String get motDePasseAjouteAvecSucces => 'Mot de passe ajouté avec succès';

  @override
  String get erreur => 'Erreur';

  @override
  String get motDePasseSupprime => 'Mot de passe supprimé';

  @override
  String get erreurLorsDeLaSuppression => 'Erreur lors de la suppression';

  @override
  String get creerUnMotDePasse => 'Créer un mot de passe';

  @override
  String get nouveauMotDePasseMin6Caracteres =>
      'Nouveau mot de passe (min. 6 caractères)';

  @override
  String get valider => 'Valider';

  @override
  String get connecte => 'Connecté';

  @override
  String get nonConnecte => 'Non connecté';

  @override
  String get delier => 'Délier';

  @override
  String get connecter => 'Connecter';

  @override
  String get comptesConnectes => 'Comptes connectés';

  @override
  String get emailMotDePasse => 'Email / Mot de passe';

  @override
  String get google => 'Google';

  @override
  String get compteGoogleConnecte => 'Compte Google connecté';

  @override
  String get securite => 'Sécurité';

  @override
  String get zoneSensible => 'Zone sensible';

  @override
  String get seDeconnecter => 'Se déconnecter';

  @override
  String get supprimerLesDonnees => 'Supprimer les données';

  @override
  String get supprimerLeCompte => 'Supprimer le compte';

  @override
  String get voulezVousVraimentVousDeconnecter =>
      'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get supprimerLesMatchsRegardes => 'Supprimer les matchs regardés';

  @override
  String get supprimerLesAmis => 'Supprimer les amis';

  @override
  String get supprimerLesNotifications => 'Supprimer les notifications';

  @override
  String get reinitialiserLesPreferences => 'Réinitialiser les préférences';

  @override
  String get supprimerLesMatchsRegardesEnsemble =>
      'Supprimer les matchs regardés ensemble';

  @override
  String get donneesSupprimeesAvecSucces => 'Données supprimées avec succès';

  @override
  String get cetteActionEstIrreversibleToutesVosDonneesSerontDefinitivementSupprimees =>
      'Cette action est irréversible. Toutes vos données seront définitivement supprimées';

  @override
  String get compteSupprimeAvecSucces => 'Compte supprimé avec succès';

  @override
  String get compte => 'Compte';

  @override
  String get comptePrive => 'Compte privé';

  @override
  String get autresUtilisateurs => 'Autres utilisateurs';

  @override
  String get listeDesUtilisateursBloques => 'Liste des utilisateurs bloqués';

  @override
  String get general => 'Général';

  @override
  String get activerLesNotifications => 'Activer les notifications';

  @override
  String get social => 'Social';

  @override
  String get demandesDAmis => 'Demandes d\'amis';

  @override
  String get demandeDAmiAcceptee => 'Demande d\'ami acceptée';

  @override
  String get reactionsSurTesMatchs => 'Réactions sur tes matchs';

  @override
  String get commentairesSurTesMatchs => 'Commentaires sur tes matchs';

  @override
  String get finDeMatchEquipeFavorite => 'Fin de match équipe favorite';

  @override
  String get recapHebdomadaire => 'Récap hebdomadaire';

  @override
  String get theme => 'Thème';

  @override
  String get langue => 'Langue';

  @override
  String get modeDeVisionnageParDefaut => 'Mode de visionnage par défaut';

  @override
  String get utiliserLeCache => 'Utiliser le cache';

  @override
  String get conditionsDUtilisation => 'Conditions d\'utilisation';

  @override
  String get enUtilisantScorescopeVousAcceptezDUtiliserLApplicationDeManiereResponsable =>
      'En utilisant ScoreScope, vous acceptez d\'utiliser l\'application de manière responsable.';

  @override
  String get vousEtesResponsableDuContenuQueVousPubliezNotesAvisMvpEtc =>
      'Vous êtes responsable du contenu que vous publiez (notes, avis, MVP, etc.).';

  @override
  String get scorescopeSeReserveLeDroitDeSupprimerToutContenuInapproprie =>
      'ScoreScope se réserve le droit de supprimer tout contenu inapproprié.';

  @override
  String get lApplicationEstFournieTelleQuelleSansGarantieDeDisponibilitePermanente =>
      'L\'application est fournie telle quelle, sans garantie de disponibilité permanente.';

  @override
  String get politiqueDeConfidentialite => 'Politique de confidentialité';

  @override
  String get scorescopeCollecteUniquementLesDonneesNecessairesAuFonctionnementDeLApplicationCompteMatchsInteractionsSociales =>
      'ScoreScope collecte uniquement les données nécessaires au fonctionnement de l\'application (compte, matchs, interactions sociales).';

  @override
  String get vosDonneesNeSontPasRevenduesADesTiers =>
      'Vos données ne sont pas revendues à des tiers.';

  @override
  String get vousPouvezDemanderLaSuppressionDeVotreCompteAToutMoment =>
      'Vous pouvez demander la suppression de votre compte à tout moment.';

  @override
  String get nousFaisonsDeNotreMieuxPourProtegerVosDonnees =>
      'Nous faisons de notre mieux pour protéger vos données.';

  @override
  String get supportInformations => 'Support & Informations';

  @override
  String get aPropos => 'À propos';

  @override
  String get signalerUnBug => 'Signaler un bug';

  @override
  String get cgu => 'CGU';

  @override
  String get version => 'Version';

  @override
  String get tonCarnetDeMatchsDeFoot => 'Ton carnet de matchs de foot ⚽';

  @override
  String get noteLesMatchsQueTuRegardesElisLeMvpEtPartageTonExperienceAvecTesAmis =>
      'Note les matchs que tu regardes, élis le MVP et partage ton expérience avec tes amis';

  @override
  String get fermer => 'Fermer';

  @override
  String saisonXX(String season, String totalSeasons) {
    return 'Saison $season/$totalSeasons';
  }

  @override
  String get aucunAmiNAVuCeMatch => 'Aucun ami n\'a vu ce match';

  @override
  String get utilisateur => 'Utilisateur';

  @override
  String vousAvezSupprimeLaReactionX(String emoji) {
    return 'Vous avez supprimé la réaction $emoji';
  }

  @override
  String get ecrireUnCommentaire => 'Écrire un commentaire';

  @override
  String get ecrisUnCommentaire => 'Écris un commentaire...';

  @override
  String get ajouteLesAmisAvecQuiTuAsRegardeLeMatch =>
      'Ajoute les amis avec qui tu as regardé le match';

  @override
  String get rechercherUnAmi => 'Rechercher un ami...';

  @override
  String get aucunAmiTrouve => 'Aucun ami trouvé';

  @override
  String get enAttente => 'En attente';

  @override
  String get laCompositionNEstPasEncoreDisponible =>
      'La composition n\'est pas encore disponible';

  @override
  String get remplacants => 'Remplaçants';

  @override
  String voulezVousSupprimerXDesAmisQuiOntRegardeLeMatchAvecVous(
      String displayName) {
    return 'Voulez-vous supprimer $displayName des amis qui ont regardé le match avec vous ?';
  }

  @override
  String get leMatchNAPasEncoreCommence =>
      'Le match n\'a pas encore commencé !';

  @override
  String get activeLesNotifications => 'Active les notifications';

  @override
  String get impossibleDeChargerLaListeDesAmis =>
      'Impossible de charger la liste des amis';

  @override
  String get impossibleDeRecupererLUtilisateur =>
      'Impossible de récupérer l\'utilisateur';

  @override
  String get echecDeLaSauvegardeReessayePlusTard =>
      'Échec de la sauvegarde — réessaye plus tard';

  @override
  String get visionnage => 'Visionnage';

  @override
  String get choisirLeModeDeVisionnage => 'Choisir le mode de visionnage';

  @override
  String get confirme => 'Confirmé';

  @override
  String get regardeAvec => 'Regardé avec';

  @override
  String get tuAsRegardeCeMatchAvecDesAmis =>
      'Tu as regardé ce match avec des amis ?';

  @override
  String get ajouteLesAmisAvecQuiTuAsVuCeMatch =>
      'Ajoute les amis avec qui tu as vu ce match';

  @override
  String get ajouterUnAmi => 'Ajouter un ami';

  @override
  String get mt => 'MT';

  @override
  String get toutMarquerCommeVu => 'Tout marquer comme vu';

  @override
  String get aucuneNouvelleNotification => 'Aucune nouvelle notification';

  @override
  String get dejaVues => 'Déjà vues';

  @override
  String get invitationARegarderLeMatchEnsemble =>
      'Invitation à regarder le match ensemble';

  @override
  String acceptezVousLInvitationARegarderLeMatchAvecX(String displayName) {
    return 'Acceptez-vous l\'invitation à regarder le match avec $displayName ?';
  }

  @override
  String get refuser => 'Refuser';

  @override
  String get accepter => 'Accepter';

  @override
  String get ontCommenteVotreMatch => 'ont commenté votre match';

  @override
  String get aCommenteVotreMatch => 'a commenté votre match';

  @override
  String get ontReagiAVotreMatch => 'ont réagi à votre match';

  @override
  String get aReagiAVotreMatch => 'a réagi à votre match';

  @override
  String get vousInviteARegarderLeMatchEnsemble =>
      'vous invite à regarder le match ensemble';

  @override
  String get aInteragiAvecVotrePost => 'a interagi avec votre post';

  @override
  String etXAutres(String remaining) {
    return 'et $remaining autres';
  }

  @override
  String get aucuneCompetitionPreferee => 'Aucune compétition préférée';

  @override
  String xMatchsRegardes(String nbMatchs) {
    return '$nbMatchs matchs regardés';
  }

  @override
  String get aucuneEquipePreferee => 'Aucune équipe préférée';

  @override
  String get aucunMatchFavori => 'Aucun match favori';

  @override
  String get aucunMatchRegarde => 'Aucun match regardé';

  @override
  String get erreurAucunUtilisateurNEstSpecifie =>
      'Erreur : aucun utilisateur n\'est spécifié';

  @override
  String get modifierLeProfil => 'Modifier le profil';

  @override
  String get demandeRecue => 'Demande reçue';

  @override
  String get bloque => 'Bloqué';

  @override
  String get ajouter => 'Ajouter';

  @override
  String get retirerLaDemande => 'Retirer la demande';

  @override
  String get retirer => 'Retirer';

  @override
  String get debloquer => 'Débloquer';

  @override
  String get amitie => 'Amitié';

  @override
  String get cetUtilisateur => 'cet utilisateur';

  @override
  String voulezVousRetirerLAmiX(String displayName) {
    return 'Voulez-vous retirer l\'ami $displayName ?';
  }

  @override
  String voulezVousRetirerLaDemandeDAmiAX(String displayName) {
    return 'Voulez-vous retirer la demande d\'ami à $displayName ?';
  }

  @override
  String accepterLaDemandeDAmiDeX(String displayName) {
    return 'Accepter la demande d\'ami de $displayName ?';
  }

  @override
  String voulezVousDebloquerX(String displayName) {
    return 'Voulez-vous débloquer $displayName ?';
  }

  @override
  String voulezVousEnvoyerUneDemandeDAmiAX(String displayName) {
    return 'Voulez-vous envoyer une demande d\'ami à $displayName ?';
  }

  @override
  String get clubs => 'Clubs';

  @override
  String get international => 'International';

  @override
  String get selectionDesCompetitions => 'Sélection des compétitions';

  @override
  String get mesCompetitionsFavorites => 'Mes compétitions favorites';

  @override
  String get toutesLesCompetitions => 'Toutes les compétitions';

  @override
  String get validerLaSelection => 'Valider la sélection';

  @override
  String get selectionDesEquipes => 'Sélection des équipes';

  @override
  String get rechercherUneEquipe => 'Rechercher une équipe…';

  @override
  String get rechercheTonEquipePreferee => '🔍 Recherche ton équipe préférée';

  @override
  String get mesEquipesFavorites => 'Mes équipes favorites';

  @override
  String get aucuneEquipeTrouvee => 'Aucune équipe trouvée';

  @override
  String get resultats => 'Résultats';

  @override
  String get tuPeuxSelectionnerJusquA10Equipes =>
      'Tu peux sélectionner jusqu\'à 10 équipes';

  @override
  String get statistiques => 'Statistiques';

  @override
  String get profil => 'Profil';

  @override
  String get retours => 'Retours';

  @override
  String get inconnu => 'Inconnu';

  @override
  String get unMatch => 'un match';

  @override
  String get autres2 => 'Autres';

  @override
  String get selectionnerUneDate => 'Sélectionner une date';

  @override
  String get appliquer => 'Appliquer';

  @override
  String get commenceATaperPourRechercher => 'Commence à taper pour rechercher';

  @override
  String encoreXCaractereX(String value1, String value2) {
    return 'Encore $value1 caractère$value2…';
  }

  @override
  String get aucunResultat => 'Aucun résultat';

  @override
  String get ajouterDesAmis => 'Ajouter des amis';

  @override
  String get rechercherUnUtilisateur => 'Rechercher un utilisateur';

  @override
  String tapezAuMoinsXCaracteresPourLancerLaRecherche(String minCharsToSearch) {
    return 'Tapez au moins $minCharsToSearch caractères pour lancer la recherche';
  }

  @override
  String get entrezUneRecherchePourTrouverDesUtilisateurs =>
      'Entrez une recherche pour trouver des utilisateurs';

  @override
  String erreurLorsDeLaRechercheX(String error) {
    return 'Erreur lors de la recherche : $error';
  }

  @override
  String get aucunUtilisateurTrouve => 'Aucun utilisateur trouvé';

  @override
  String xPostsCharges(String length) {
    return '$length posts chargés';
  }

  @override
  String erreurLorsDuChargementDesDonneesUtilisateurDuMatchX(String error) {
    return 'Erreur lors du chargement des données utilisateur du match: $error';
  }

  @override
  String get matchAjouteAuxFavoris => 'Match ajouté aux favoris';

  @override
  String get matchRetireDesFavoris => 'Match retiré des favoris';

  @override
  String get erreurLorsDeLaMiseAJourDuFavori =>
      'Erreur lors de la mise à jour du favori';

  @override
  String get rendreLeMatchPublic => 'Rendre le match public';

  @override
  String get leMatchSeraRenduPublicEtVisibleParVosAmis =>
      'Le match sera rendu public et visible par vos amis';

  @override
  String get rendrePublic => 'Rendre public';

  @override
  String get rendreLeMatchPrive => 'Rendre le match privé';

  @override
  String get leMatchResteraPriveEtNeSeraPasVisibleParVosAmis =>
      'Le match restera privé et ne sera pas visible par vos amis.';

  @override
  String get rendrePrive => 'Rendre privé';

  @override
  String get supprimerLeMatch => 'Supprimer le match';

  @override
  String get matchRenduPrive => 'Match rendu privé';

  @override
  String get matchRenduPublic => 'Match rendu public';

  @override
  String get erreurLorsDeLaMiseAJourDeLaConfidentialite =>
      'Erreur lors de la mise à jour de la confidentialité';

  @override
  String get matchSupprime => 'Match supprimé';

  @override
  String get erreurLorsDeLaSuppressionDuMatch =>
      'Erreur lors de la suppression du match (réessayez)';

  @override
  String notificationsXPourXX(String value1, String value2, String value3) {
    return 'Notifications $value1 pour $value2 - $value3';
  }

  @override
  String get matchPrive => 'Match privé';

  @override
  String get matchPublic => 'Match public';

  @override
  String get aRegardeCeMatch => 'a regardé ce match';

  @override
  String get nonNote => 'Non noté';

  @override
  String get note => 'Note';

  @override
  String get mvpVote => 'MVP voté';

  @override
  String get bio => 'Bio';

  @override
  String get equipesPreferees => 'Équipes préférées';

  @override
  String get modifier => 'Modifier';

  @override
  String get competitionsPreferees => 'Compétitions préférées';

  @override
  String get creezVotreProfil => 'Créez votre profil';

  @override
  String get parametres => 'Paramètres';

  @override
  String get confidentialite => 'Confidentialité';

  @override
  String get preferences => 'Préférences';

  @override
  String get derniersMatchs => 'Derniers matchs';

  @override
  String get matchsFavoris => 'Matchs favoris';

  @override
  String get filtrerParPeriode => 'Filtrer par période';

  @override
  String get periodePersonnalisee => 'Période personnalisée';

  @override
  String get saison => 'Saison';

  @override
  String get selectionnerUnePeriode => 'Sélectionner une période';

  @override
  String get selectionnerLaSaison => 'Sélectionner la saison';

  @override
  String get mesStatistiques => 'Mes statistiques';

  @override
  String statistiquesDeX(String displayName) {
    return 'Statistiques de $displayName';
  }

  @override
  String get filtrerParDate => 'Filtrer par date';

  @override
  String get afficherEnListe => 'Afficher en liste';

  @override
  String get afficherEnCards => 'Afficher en cards';

  @override
  String get matchsPublicsUniquement => 'Matchs publics uniquement';

  @override
  String saisonXX2(String season, String season2) {
    return 'Saison : $season / $season2';
  }

  @override
  String periodeXX(String start, String end) {
    return 'Période : $start → $end';
  }

  @override
  String get habitudes => 'Habitudes';

  @override
  String get recapHebdo => 'RECAP HEBDO';

  @override
  String get meilleurMatch2 => 'MEILLEUR MATCH';

  @override
  String get competition => 'COMPÉTITION';

  @override
  String get serie2 => 'SÉRIE';

  @override
  String get telechargeScorescope => 'Télécharge ScoreScope';

  @override
  String xXVsSemainePrecedente(String value1, String diff) {
    return '$value1$diff vs semaine précédente,';
  }

  @override
  String get votePourMvp => 'Vote pour MVP';

  @override
  String get pasDeVotePourLeMvp => 'Pas de vote pour le MVP';

  @override
  String get utilisateurIntrouvable => 'Utilisateur introuvable';

  @override
  String voirTousLesXCommentaires(String length) {
    return 'Voir tous les $length commentaires';
  }

  @override
  String get voirTousLesCommentaires => 'Voir tous les commentaires';

  @override
  String get recents => 'Récents';

  @override
  String get rechercherUnEmojiParNomOuCategorie =>
      'Rechercher un emoji par nom ou catégorie…';

  @override
  String get infosMatch => 'Infos match';

  @override
  String get noteDuMatch => 'Note du match';

  @override
  String xVoteX(String noteCount, String value2) {
    return '$noteCount vote$value2';
  }

  @override
  String get moyenne => 'Moyenne';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get effacerMaNote => 'Effacer ma note';

  @override
  String get note2 => 'Noté';

  @override
  String get mvpDuMatch => 'MVP du match';

  @override
  String get aucunMvpElu => 'Aucun MVP élu';

  @override
  String get soisLePremierAVoter => 'Sois le premier à voter !';

  @override
  String get votreVote => 'Votre vote';

  @override
  String get changer => 'Changer';

  @override
  String get voter => 'Voter';

  @override
  String get aucunJoueurSelectionne => 'Aucun joueur sélectionné';

  @override
  String get selectionnezUnJoueurPourVoter =>
      'Sélectionnez un joueur pour voter';

  @override
  String get vider => 'Vider';

  @override
  String get vote => 'Voté';

  @override
  String get aucunMatchEnregistre => 'Aucun match enregistré';

  @override
  String get aucuneNotification => 'Aucune notification';

  @override
  String get buts => 'Buts';

  @override
  String get voirPlus => 'Voir plus';

  @override
  String get derniersMatchsAjoutes => 'Derniers matchs ajoutés';

  @override
  String get matchs2 => 'matchs';

  @override
  String get buts2 => 'buts';

  @override
  String get rechercherUnMatchUneEquipeUnJoueur =>
      'Rechercher un match, une équipe, un joueur…';

  @override
  String get aucuneDonneeDisponible => 'Aucune donnée disponible';

  @override
  String get comparerAvecUnAmi => 'Comparer avec un ami';

  @override
  String get aucunAmiAAfficher => 'Aucun ami à afficher';

  @override
  String baseSurXMatchsRegardes(String watchedMatchesCount) {
    return 'Basé sur $watchedMatchesCount matchs regardés';
  }

  @override
  String get comparer => 'Comparer';

  @override
  String get mvps => 'MVPs';

  @override
  String get appuieSurUnPointPourVoirLeJoueur =>
      'Appuie sur un point pour voir le joueur';

  @override
  String get matchsRegardes => 'matchs regardés';

  @override
  String get janvier => 'Janvier';

  @override
  String get fevrier => 'Février';

  @override
  String get mars => 'Mars';

  @override
  String get avril => 'Avril';

  @override
  String get mai => 'Mai';

  @override
  String get juin => 'Juin';

  @override
  String get juillet => 'Juillet';

  @override
  String get aout => 'Août';

  @override
  String get septembre => 'Septembre';

  @override
  String get octobre => 'Octobre';

  @override
  String get novembre => 'Novembre';

  @override
  String get decembre => 'Décembre';

  @override
  String get jan => 'Jan';

  @override
  String get fev => 'Fév';

  @override
  String get mar => 'Mar';

  @override
  String get avr => 'Avr';

  @override
  String get juil => 'Juil';

  @override
  String get sep => 'Sep';

  @override
  String get oct => 'Oct';

  @override
  String get nov => 'Nov';

  @override
  String get dec => 'Déc';

  @override
  String erreurLorsDuChargementDesStatistiques(String value1) {
    return 'Erreur lors du chargement des statistiques.\n$value1';
  }

  @override
  String get erreurLorsDuCalculDesStatistiques =>
      'Erreur lors du calcul des statistiques';

  @override
  String get competitionsLesPlusSuivies => 'Compétitions les plus suivies';

  @override
  String get aucuneCompetition => 'Aucune compétition';

  @override
  String get competitionsDifferentesVues => 'Compétitions différentes vues';

  @override
  String get butsParCompetition => 'Buts par compétition';

  @override
  String get aucuneDonnee => 'Aucune donnée';

  @override
  String get moyButsMatch => 'Moy. buts / match';

  @override
  String get repartitionParCompetition => 'Répartition par compétition';

  @override
  String get typesDeCompetitions => 'Types de compétitions';

  @override
  String get equipesDifferentesVues => 'Équipes différentes vues';

  @override
  String get equipesLesPlusVues => 'Équipes les plus vues';

  @override
  String get aucuneEquipe => 'Aucune équipe';

  @override
  String get equipesLesPlusVuesGagner => 'Équipes les plus vues gagner';

  @override
  String get equipesLesPlusVuesPerdre => 'Équipes les plus vues perdre';

  @override
  String get pourcentageDeVictoiresMin3MatchsVus =>
      'Pourcentage de victoires (min. 3 matchs vus)';

  @override
  String get pourcentageVictoires => '% Victoires';

  @override
  String get butsVus => 'Buts vus';

  @override
  String get joueursLesPlusVusMarquer => 'Joueurs les plus vus marquer';

  @override
  String get aucunButeur => 'Aucun buteur';

  @override
  String get buteursDifferents => 'Buteurs différents';

  @override
  String get moyDesNotesDonnees => 'Moy. des notes données';

  @override
  String get mvpLesPlusVotes => 'MVP les plus votés';

  @override
  String get aucunMvp => 'Aucun MVP';

  @override
  String get matchsLesMieuxNotes => 'Matchs les mieux notés';

  @override
  String get aucunMatch => 'Aucun match';

  @override
  String get matchsLesCommentes => 'Matchs les + commentés';

  @override
  String get matchsLesReactions => 'Matchs les + réactions';

  @override
  String get joursAvecLePlusDeMatchsVus => 'Jours avec le plus de matchs vus';

  @override
  String get typesDeVisionnage => 'Types de visionnage';

  @override
  String get nombreDeMatchsVusParMois => 'Nombre de matchs vus par mois';

  @override
  String get buteursLesPlusVus => 'Buteurs les plus vus';

  @override
  String get aucunJoueur => 'Aucun joueur';

  @override
  String get passesDecisives => 'Passes décisives';

  @override
  String get gA => 'G+A';

  @override
  String get titularisations => 'Titularisations';

  @override
  String get recordDeButsSurUnMatch => 'Record de buts sur un match';

  @override
  String get nombreDeButsVotesMvp => 'Nombre de buts / votes MVP';

  @override
  String get plusGrosScore => 'Plus gros score';

  @override
  String get plusGrosEcart => 'Plus gros écart';

  @override
  String get moyenneDifferenceButsMatch => 'Moyenne différence buts / match';

  @override
  String get resultatsDomicileNulExterieur =>
      'Résultats (domicile / nul / extérieur)';

  @override
  String get clubsVsInternationaux => 'Clubs vs Internationaux';

  @override
  String get supprimerLeCommentaire => 'Supprimer le commentaire';

  @override
  String get voulezVousSupprimerVotreCommentaire =>
      'Voulez-vous supprimer votre commentaire ?';

  @override
  String get monCommentaire => 'Mon commentaire';

  @override
  String get ajouterUnCommentaire => 'Ajouter un commentaire';

  @override
  String get publier => 'Publier';

  @override
  String get commenter => 'Commenter';

  @override
  String get quAstuPenseDeCeMatch => 'Qu\'as-tu pensé de ce match ?';

  @override
  String get favoris => 'Favoris';

  @override
  String chargementDesMatchsXSurX(
      String matchModelIdsLoaded, String matchIdsTotal) {
    return 'Chargement des matchs ($matchModelIdsLoaded / $matchIdsTotal)...';
  }

  @override
  String get chargementDesEquipesEtDesJoueurs =>
      'Chargement des équipes et joueurs...';

  @override
  String get preparationDesStatistiques => 'Préparation des statistiques...';

  @override
  String get pret => 'Prêt';

  @override
  String get tab => 'TAB';

  @override
  String get ap => 'AP';
}
