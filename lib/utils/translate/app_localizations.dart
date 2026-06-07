import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'translate/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @autresMatchs.
  ///
  /// In fr, this message translates to:
  /// **'Autres matchs'**
  String get autresMatchs;

  /// No description provided for @matchsDuJour.
  ///
  /// In fr, this message translates to:
  /// **'Matchs du jour'**
  String get matchsDuJour;

  /// No description provided for @erreurLorsDuChargementDesDemandes.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement des demandes'**
  String get erreurLorsDuChargementDesDemandes;

  /// No description provided for @tous.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get tous;

  /// No description provided for @veuillezVerifierVotreEmailAvantDeVousConnecter.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez vérifier votre email avant de vous connecter'**
  String get veuillezVerifierVotreEmailAvantDeVousConnecter;

  /// No description provided for @utilisateurNonAuthentifie.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur non authentifié'**
  String get utilisateurNonAuthentifie;

  /// No description provided for @erreurLorsDeLaConnexionAvecApple.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la connexion avec Apple'**
  String get erreurLorsDeLaConnexionAvecApple;

  /// No description provided for @quelquUn.
  ///
  /// In fr, this message translates to:
  /// **'Quelqu\'un'**
  String get quelquUn;

  /// No description provided for @ceProfilNExistePas.
  ///
  /// In fr, this message translates to:
  /// **'Ce profil n\'existe pas'**
  String get ceProfilNExistePas;

  /// No description provided for @utilisateurInvalide.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur invalide'**
  String get utilisateurInvalide;

  /// No description provided for @utilisateurNonConnecte.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur non connecté'**
  String get utilisateurNonConnecte;

  /// No description provided for @emailIntrouvable.
  ///
  /// In fr, this message translates to:
  /// **'Email introuvable'**
  String get emailIntrouvable;

  /// No description provided for @documentUtilisateurIntrouvable.
  ///
  /// In fr, this message translates to:
  /// **'Document utilisateur introuvable'**
  String get documentUtilisateurIntrouvable;

  /// No description provided for @compteDejaSupprime.
  ///
  /// In fr, this message translates to:
  /// **'Compte déjà supprimé'**
  String get compteDejaSupprime;

  /// No description provided for @equipes.
  ///
  /// In fr, this message translates to:
  /// **'Équipes'**
  String get equipes;

  /// No description provided for @matchs.
  ///
  /// In fr, this message translates to:
  /// **'Matchs'**
  String get matchs;

  /// No description provided for @competitions.
  ///
  /// In fr, this message translates to:
  /// **'Compétitions'**
  String get competitions;

  /// No description provided for @joueurs.
  ///
  /// In fr, this message translates to:
  /// **'Joueurs'**
  String get joueurs;

  /// No description provided for @domicile.
  ///
  /// In fr, this message translates to:
  /// **'Domicile'**
  String get domicile;

  /// No description provided for @nuls.
  ///
  /// In fr, this message translates to:
  /// **'Nuls'**
  String get nuls;

  /// No description provided for @exterieur.
  ///
  /// In fr, this message translates to:
  /// **'Extérieur'**
  String get exterieur;

  /// No description provided for @stade.
  ///
  /// In fr, this message translates to:
  /// **'Stade'**
  String get stade;

  /// No description provided for @tele.
  ///
  /// In fr, this message translates to:
  /// **'Télé'**
  String get tele;

  /// No description provided for @bar.
  ///
  /// In fr, this message translates to:
  /// **'Bar'**
  String get bar;

  /// No description provided for @victoires.
  ///
  /// In fr, this message translates to:
  /// **'Victoires'**
  String get victoires;

  /// No description provided for @defaites.
  ///
  /// In fr, this message translates to:
  /// **'Défaites'**
  String get defaites;

  /// No description provided for @vous.
  ///
  /// In fr, this message translates to:
  /// **'vous'**
  String get vous;

  /// No description provided for @avec.
  ///
  /// In fr, this message translates to:
  /// **'avec'**
  String get avec;

  /// No description provided for @et.
  ///
  /// In fr, this message translates to:
  /// **'et'**
  String get et;

  /// No description provided for @autres.
  ///
  /// In fr, this message translates to:
  /// **'autres'**
  String get autres;

  /// No description provided for @demandeDAmiEnvoyeeAvecSucces.
  ///
  /// In fr, this message translates to:
  /// **'Demande d\'ami envoyée avec succès!'**
  String get demandeDAmiEnvoyeeAvecSucces;

  /// No description provided for @demandeDAmiAnnuleeAvecSucces.
  ///
  /// In fr, this message translates to:
  /// **'Demande d\'ami annulée avec succès!'**
  String get demandeDAmiAnnuleeAvecSucces;

  /// No description provided for @demandeAcceptee.
  ///
  /// In fr, this message translates to:
  /// **'Demande acceptée !'**
  String get demandeAcceptee;

  /// No description provided for @amiRetireAvecSucces.
  ///
  /// In fr, this message translates to:
  /// **'Ami retiré avec succès!'**
  String get amiRetireAvecSucces;

  /// No description provided for @utilisateurBloqueAvecSucces.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur bloqué avec succès!'**
  String get utilisateurBloqueAvecSucces;

  /// No description provided for @utilisateurDebloqueAvecSucces.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur débloqué avec succès!'**
  String get utilisateurDebloqueAvecSucces;

  /// No description provided for @actionEffectueeAvecSucces.
  ///
  /// In fr, this message translates to:
  /// **'Action effectuée avec succès!'**
  String get actionEffectueeAvecSucces;

  /// No description provided for @csc.
  ///
  /// In fr, this message translates to:
  /// **'CSC'**
  String get csc;

  /// No description provided for @pen.
  ///
  /// In fr, this message translates to:
  /// **'Pen'**
  String get pen;

  /// No description provided for @typeInvalidePourMapStringStringX.
  ///
  /// In fr, this message translates to:
  /// **'Type invalide pour Map<String,String>: {runtimeType}'**
  String typeInvalidePourMapStringStringX(String runtimeType);

  /// No description provided for @typeInvalidePourMapStringIntX.
  ///
  /// In fr, this message translates to:
  /// **'Type invalide pour Map<String,int>: {runtimeType}'**
  String typeInvalidePourMapStringIntX(String runtimeType);

  /// No description provided for @aujourdHui.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get aujourdHui;

  /// No description provided for @hier.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get hier;

  /// No description provided for @demain.
  ///
  /// In fr, this message translates to:
  /// **'Demain'**
  String get demain;

  /// No description provided for @aucunMatchCeJourLa.
  ///
  /// In fr, this message translates to:
  /// **'Aucun match ce jour-là'**
  String get aucunMatchCeJourLa;

  /// No description provided for @chargement.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get chargement;

  /// No description provided for @recuperationDesMatchs.
  ///
  /// In fr, this message translates to:
  /// **'Récupération des matchs…'**
  String get recuperationDesMatchs;

  /// No description provided for @chargementDesDetailsDesMatchs.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des détails des matchs…'**
  String get chargementDesDetailsDesMatchs;

  /// No description provided for @calculDesStatistiques.
  ///
  /// In fr, this message translates to:
  /// **'Calcul des statistiques'**
  String get calculDesStatistiques;

  /// No description provided for @petiteSemaineFootball.
  ///
  /// In fr, this message translates to:
  /// **'👀 Petite semaine football'**
  String get petiteSemaineFootball;

  /// No description provided for @footballSpectacleXAvec3Buts.
  ///
  /// In fr, this message translates to:
  /// **'🍿 Football spectacle • {value1}% avec 3+ buts'**
  String footballSpectacleXAvec3Buts(String value1);

  /// No description provided for @defensesAbsentesXButsMatch.
  ///
  /// In fr, this message translates to:
  /// **'💥 Défenses absentes • {value1} buts/match'**
  String defensesAbsentesXButsMatch(String value1);

  /// No description provided for @semaineChaotiqueXMatchsAvec5Buts.
  ///
  /// In fr, this message translates to:
  /// **'🔥 Semaine chaotique • {veryHighScoring} matchs avec 5+ buts'**
  String semaineChaotiqueXMatchsAvec5Buts(String veryHighScoring);

  /// No description provided for @aucun00AuProgramme.
  ///
  /// In fr, this message translates to:
  /// **'🎯 Aucun 0-0 au programme'**
  String get aucun00AuProgramme;

  /// No description provided for @defensesEnCartonAucunMatchAMoinsDe2Buts.
  ///
  /// In fr, this message translates to:
  /// **'🤐 Défenses en carton • Aucun match à moins de 2 buts'**
  String get defensesEnCartonAucunMatchAMoinsDe2Buts;

  /// No description provided for @suspenseTotalXMatchsAUnButDEcart.
  ///
  /// In fr, this message translates to:
  /// **'⚡ Suspense total • {closeGames} matchs à un but d\'écart'**
  String suspenseTotalXMatchsAUnButDEcart(String closeGames);

  /// No description provided for @attaquantsEnVacancesXButsMatch.
  ///
  /// In fr, this message translates to:
  /// **'😴 Attaquants en vacances • {value1} buts/match'**
  String attaquantsEnVacancesXButsMatch(String value1);

  /// No description provided for @gardiensEnFeuXCleanSheets.
  ///
  /// In fr, this message translates to:
  /// **'🧤 Gardiens en feu • {cleanSheets} clean sheets'**
  String gardiensEnFeuXCleanSheets(String cleanSheets);

  /// No description provided for @impossibleDeSeDepartagerXMatchsNuls.
  ///
  /// In fr, this message translates to:
  /// **'🤝 Impossible de se départager • {draws} matchs nuls'**
  String impossibleDeSeDepartagerXMatchsNuls(String draws);

  /// No description provided for @semaineDecevanteX10DeMoyenne.
  ///
  /// In fr, this message translates to:
  /// **'📉 Semaine décevante • {value1}/10 de moyenne'**
  String semaineDecevanteX10DeMoyenne(String value1);

  /// No description provided for @quelquesPurgesAuProgrammeXMatchsSous510.
  ///
  /// In fr, this message translates to:
  /// **'💀 Quelques purges au programme • {badMatches} matchs sous 5/10'**
  String quelquesPurgesAuProgrammeXMatchsSous510(String badMatches);

  /// No description provided for @semaineMemorableXMatchsNotes8OuPlus.
  ///
  /// In fr, this message translates to:
  /// **'🔥 Semaine mémorable • {greatMatches} matchs notés 8 ou plus'**
  String semaineMemorableXMatchsNotes8OuPlus(String greatMatches);

  /// No description provided for @semaineValideeX10DeMoyenne.
  ///
  /// In fr, this message translates to:
  /// **'🌟 Semaine validée • {value1}/10 de moyenne'**
  String semaineValideeX10DeMoyenne(String value1);

  /// No description provided for @aucunFlopAuProgrammeTousLesMatchsNotes7OuPlus.
  ///
  /// In fr, this message translates to:
  /// **'🎬 Aucun flop au programme • Tous les matchs notés 7 ou plus'**
  String get aucunFlopAuProgrammeTousLesMatchsNotes7OuPlus;

  /// No description provided for @modeXActive.
  ///
  /// In fr, this message translates to:
  /// **'🏆 Mode {topCompetitionName} activé'**
  String modeXActive(String topCompetitionName);

  /// No description provided for @marathonFootballXMatchsAuProgramme.
  ///
  /// In fr, this message translates to:
  /// **'📺 Marathon football • {n} matchs au programme'**
  String marathonFootballXMatchsAuProgramme(String n);

  /// No description provided for @festivalOffensifXButsCetteSemaine.
  ///
  /// In fr, this message translates to:
  /// **'⚽ Festival offensif • {totalGoals} buts cette semaine'**
  String festivalOffensifXButsCetteSemaine(String totalGoals);

  /// No description provided for @semaineFootballValideeXMatchsRegardes.
  ///
  /// In fr, this message translates to:
  /// **'👀 Semaine football validée • {n} matchs regardés'**
  String semaineFootballValideeXMatchsRegardes(String n);

  /// No description provided for @recapDeLaSemaine.
  ///
  /// In fr, this message translates to:
  /// **'Récap de la semaine'**
  String get recapDeLaSemaine;

  /// No description provided for @impossibleDeChargerLeRecap.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le récap'**
  String get impossibleDeChargerLeRecap;

  /// No description provided for @aucunMatchCetteSemaine.
  ///
  /// In fr, this message translates to:
  /// **'Aucun match cette semaine'**
  String get aucunMatchCetteSemaine;

  /// No description provided for @ajouteLesMatchsQueTuRegardes.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute les matchs que tu regardes\npour voir tes stats ici !'**
  String get ajouteLesMatchsQueTuRegardes;

  /// No description provided for @partagerMonRecap.
  ///
  /// In fr, this message translates to:
  /// **'Partager mon récap'**
  String get partagerMonRecap;

  /// No description provided for @xMatchs.
  ///
  /// In fr, this message translates to:
  /// **'{totalNbMatches} matchs'**
  String xMatchs(String totalNbMatches);

  /// No description provided for @xButs.
  ///
  /// In fr, this message translates to:
  /// **'{totalNbGoalsAllTime} buts'**
  String xButs(String totalNbGoalsAllTime);

  /// No description provided for @matchXRegardeX.
  ///
  /// In fr, this message translates to:
  /// **'match{value1} regardé{value1}'**
  String matchXRegardeX(String value1);

  /// No description provided for @butXVus.
  ///
  /// In fr, this message translates to:
  /// **'but{value1} vus'**
  String butXVus(String value1);

  /// No description provided for @noteMoyenne.
  ///
  /// In fr, this message translates to:
  /// **'note moyenne'**
  String get noteMoyenne;

  /// No description provided for @meilleurMatch.
  ///
  /// In fr, this message translates to:
  /// **'🏆 Meilleur match'**
  String get meilleurMatch;

  /// No description provided for @mvp.
  ///
  /// In fr, this message translates to:
  /// **'MVP'**
  String get mvp;

  /// No description provided for @mvpDeLaSemaine.
  ///
  /// In fr, this message translates to:
  /// **'MVP de la semaine'**
  String get mvpDeLaSemaine;

  /// No description provided for @competitionPreferee.
  ///
  /// In fr, this message translates to:
  /// **'🏅 Compétition préférée'**
  String get competitionPreferee;

  /// No description provided for @xMatchX.
  ///
  /// In fr, this message translates to:
  /// **'{topCompetitionCount} match{value2}'**
  String xMatchX(String topCompetitionCount, String value2);

  /// No description provided for @serie.
  ///
  /// In fr, this message translates to:
  /// **'🔥 Série'**
  String get serie;

  /// No description provided for @semainesConsecutives.
  ///
  /// In fr, this message translates to:
  /// **'semaines\nconsécutives'**
  String get semainesConsecutives;

  /// No description provided for @voiciMonRecapFootDeLaSemaine.
  ///
  /// In fr, this message translates to:
  /// **'Voici mon récap foot de la semaine !⚽📊'**
  String get voiciMonRecapFootDeLaSemaine;

  /// No description provided for @decouvrezLeVotreTelechargezScorescopeapp.
  ///
  /// In fr, this message translates to:
  /// **'Découvrez le votre, téléchargez @ScoreScopeApp !'**
  String get decouvrezLeVotreTelechargezScorescopeapp;

  /// No description provided for @erreurDeChargement.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get erreurDeChargement;

  /// No description provided for @details.
  ///
  /// In fr, this message translates to:
  /// **'Détails'**
  String get details;

  /// No description provided for @commentaires.
  ///
  /// In fr, this message translates to:
  /// **'Commentaires'**
  String get commentaires;

  /// No description provided for @pasEncoreDeCommentaires.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de commentaires'**
  String get pasEncoreDeCommentaires;

  /// No description provided for @demandesDAmisX.
  ///
  /// In fr, this message translates to:
  /// **'Demandes d\'amis{value1}'**
  String demandesDAmisX(String value1);

  /// No description provided for @impossibleDeChargerLeFil.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le fil'**
  String get impossibleDeChargerLeFil;

  /// No description provided for @reessayer.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get reessayer;

  /// No description provided for @aucuneActiviteRecenteDeVosAmis.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité récente de vos amis'**
  String get aucuneActiviteRecenteDeVosAmis;

  /// No description provided for @invitezDesAmisPourVoirLeurActiviteIci.
  ///
  /// In fr, this message translates to:
  /// **'Invitez des amis pour voir leur activité ici'**
  String get invitezDesAmisPourVoirLeurActiviteIci;

  /// No description provided for @filDActuDesAmis.
  ///
  /// In fr, this message translates to:
  /// **'Fil d\'actu des amis'**
  String get filDActuDesAmis;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @impossibleDeChargerLesDonnees.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les données'**
  String get impossibleDeChargerLesDonnees;

  /// No description provided for @etesVousSurDeVouloirSupprimerCeMatch.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer ce match ?\nCela retirera votre note et votre vote MVP et il n\'apparaîtra plus sur votre profil'**
  String get etesVousSurDeVouloirSupprimerCeMatch;

  /// No description provided for @miTemps.
  ///
  /// In fr, this message translates to:
  /// **'Mi-Temps'**
  String get miTemps;

  /// No description provided for @infos.
  ///
  /// In fr, this message translates to:
  /// **'Infos'**
  String get infos;

  /// No description provided for @compositions.
  ///
  /// In fr, this message translates to:
  /// **'Compositions'**
  String get compositions;

  /// No description provided for @mesAmis.
  ///
  /// In fr, this message translates to:
  /// **'Mes Amis'**
  String get mesAmis;

  /// No description provided for @jAiNoteXXSurScorescopeapp.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai noté {home} - {away} sur @ScoreScopeApp !'**
  String jAiNoteXXSurScorescopeapp(String home, String away);

  /// No description provided for @partagerCeMatch.
  ///
  /// In fr, this message translates to:
  /// **'Partager ce match'**
  String get partagerCeMatch;

  /// No description provided for @preparation.
  ///
  /// In fr, this message translates to:
  /// **'Préparation...'**
  String get preparation;

  /// No description provided for @joueurIntrouvable.
  ///
  /// In fr, this message translates to:
  /// **'Joueur introuvable'**
  String get joueurIntrouvable;

  /// No description provided for @statistiquesDeMesMatchsVus.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques de mes matchs vus'**
  String get statistiquesDeMesMatchsVus;

  /// No description provided for @statistiquesGlobales.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques globales'**
  String get statistiquesGlobales;

  /// No description provided for @matchsVus.
  ///
  /// In fr, this message translates to:
  /// **'Matchs vus'**
  String get matchsVus;

  /// No description provided for @matchsJoues.
  ///
  /// In fr, this message translates to:
  /// **'Matchs joués'**
  String get matchsJoues;

  /// No description provided for @butsMarquesVus.
  ///
  /// In fr, this message translates to:
  /// **'Buts marqués vus'**
  String get butsMarquesVus;

  /// No description provided for @butsMarques.
  ///
  /// In fr, this message translates to:
  /// **'Buts marqués'**
  String get butsMarques;

  /// No description provided for @mesVotesMvp.
  ///
  /// In fr, this message translates to:
  /// **'Mes votes MVP'**
  String get mesVotesMvp;

  /// No description provided for @votesMvp.
  ///
  /// In fr, this message translates to:
  /// **'Votes MVP'**
  String get votesMvp;

  /// No description provided for @eluMvp.
  ///
  /// In fr, this message translates to:
  /// **'Élu MVP'**
  String get eluMvp;

  /// No description provided for @xAns.
  ///
  /// In fr, this message translates to:
  /// **'{value1} ans'**
  String xAns(String value1);

  /// No description provided for @mesStats.
  ///
  /// In fr, this message translates to:
  /// **'Mes stats'**
  String get mesStats;

  /// No description provided for @global.
  ///
  /// In fr, this message translates to:
  /// **'Global'**
  String get global;

  /// No description provided for @equipeIntrouvable.
  ///
  /// In fr, this message translates to:
  /// **'Équipe introuvable'**
  String get equipeIntrouvable;

  /// No description provided for @differenceDeButsDesMatchsVus.
  ///
  /// In fr, this message translates to:
  /// **'Différence de buts des matchs vus'**
  String get differenceDeButsDesMatchsVus;

  /// No description provided for @differenceDeButs.
  ///
  /// In fr, this message translates to:
  /// **'Différence de buts'**
  String get differenceDeButs;

  /// No description provided for @butsEncaissesVus.
  ///
  /// In fr, this message translates to:
  /// **'Buts encaissés vus'**
  String get butsEncaissesVus;

  /// No description provided for @butsEncaisses.
  ///
  /// In fr, this message translates to:
  /// **'Buts encaissés'**
  String get butsEncaisses;

  /// No description provided for @maNoteMoyenneDesMatchs.
  ///
  /// In fr, this message translates to:
  /// **'Ma note moyenne des matchs'**
  String get maNoteMoyenneDesMatchs;

  /// No description provided for @noteMoyenneDesMatchs.
  ///
  /// In fr, this message translates to:
  /// **'Note moyenne des matchs'**
  String get noteMoyenneDesMatchs;

  /// No description provided for @monMvpLePlusVote.
  ///
  /// In fr, this message translates to:
  /// **'Mon MVP le plus voté'**
  String get monMvpLePlusVote;

  /// No description provided for @mvpLePlusVote.
  ///
  /// In fr, this message translates to:
  /// **'MVP le plus voté'**
  String get mvpLePlusVote;

  /// No description provided for @ratioVictoiresDefaitesMesMatchsVus.
  ///
  /// In fr, this message translates to:
  /// **'Ratio victoires/défaites (mes matchs vus)'**
  String get ratioVictoiresDefaitesMesMatchsVus;

  /// No description provided for @ratioVictoiresDefaites.
  ///
  /// In fr, this message translates to:
  /// **'Ratio victoires/défaites'**
  String get ratioVictoiresDefaites;

  /// No description provided for @scorescopeEnEstEncoreASesDebuts.
  ///
  /// In fr, this message translates to:
  /// **'ScoreScope en est encore à ses débuts 🙌\n\n'**
  String get scorescopeEnEstEncoreASesDebuts;

  /// No description provided for @tousLesRetoursSontLesBienvenusIdeesBugsAmeliorationsUi.
  ///
  /// In fr, this message translates to:
  /// **'Tous les retours sont les bienvenus : idées, bugs, améliorations UI… '**
  String get tousLesRetoursSontLesBienvenusIdeesBugsAmeliorationsUi;

  /// No description provided for @nHesiteSurtoutPas.
  ///
  /// In fr, this message translates to:
  /// **'n\'hésite surtout pas !'**
  String get nHesiteSurtoutPas;

  /// No description provided for @titre.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get titre;

  /// No description provided for @exBugLorsDuVotePourLeMvp.
  ///
  /// In fr, this message translates to:
  /// **'Ex : Bug lors du vote pour le MVP'**
  String get exBugLorsDuVotePourLeMvp;

  /// No description provided for @detail.
  ///
  /// In fr, this message translates to:
  /// **'Détail'**
  String get detail;

  /// No description provided for @expliqueTonRetourCeQuiNeMarchePasCeQueTuAimeraisVoir.
  ///
  /// In fr, this message translates to:
  /// **'Explique ton retour : ce qui ne marche pas, ce que tu aimerais voir...'**
  String get expliqueTonRetourCeQuiNeMarchePasCeQueTuAimeraisVoir;

  /// No description provided for @envoyer.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get envoyer;

  /// No description provided for @xRequis.
  ///
  /// In fr, this message translates to:
  /// **'{label} requis'**
  String xRequis(String label);

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailInvalide.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get emailInvalide;

  /// No description provided for @motDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get motDePasse;

  /// No description provided for @confirmerLeMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmerLeMotDePasse;

  /// No description provided for @auMoins6Caracteres.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 6 caractères'**
  String get auMoins6Caracteres;

  /// No description provided for @connexion.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get connexion;

  /// No description provided for @connecteToiPourAccederAScorescope.
  ///
  /// In fr, this message translates to:
  /// **'Connecte-toi pour accéder à ScoreScope !'**
  String get connecteToiPourAccederAScorescope;

  /// No description provided for @seConnecter.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get seConnecter;

  /// No description provided for @continuerAvecApple.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Apple'**
  String get continuerAvecApple;

  /// No description provided for @continuerAvecGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get continuerAvecGoogle;

  /// No description provided for @creerUnCompte.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get creerUnCompte;

  /// No description provided for @verifieTonEmail.
  ///
  /// In fr, this message translates to:
  /// **'Vérifie ton email 📩'**
  String get verifieTonEmail;

  /// No description provided for @unEmailDeConfirmationAEteEnvoye.
  ///
  /// In fr, this message translates to:
  /// **'Un email de confirmation a été envoyé.\nClique sur le lien avant de te connecter.\n\nAttention, pense à vérifier tes spams !'**
  String get unEmailDeConfirmationAEteEnvoye;

  /// No description provided for @ok.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @impossibleDeCreerLeCompte.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de créer le compte.'**
  String get impossibleDeCreerLeCompte;

  /// No description provided for @erreurCreationCompte.
  ///
  /// In fr, this message translates to:
  /// **'Erreur création compte'**
  String get erreurCreationCompte;

  /// No description provided for @erreurInconnue.
  ///
  /// In fr, this message translates to:
  /// **'Erreur inconnue'**
  String get erreurInconnue;

  /// No description provided for @lesMotsDePasseNeCorrespondentPas.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get lesMotsDePasseNeCorrespondentPas;

  /// No description provided for @rejoinsLaCommunauteScorescope.
  ///
  /// In fr, this message translates to:
  /// **'Rejoins la communauté ScoreScope !'**
  String get rejoinsLaCommunauteScorescope;

  /// No description provided for @creerMonCompte.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get creerMonCompte;

  /// No description provided for @dejaUnCompteSeConnecter.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ? Se connecter'**
  String get dejaUnCompteSeConnecter;

  /// No description provided for @utilisateurDebloque.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur débloqué'**
  String get utilisateurDebloque;

  /// No description provided for @erreurLorsDuDeblocage.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du déblocage'**
  String get erreurLorsDuDeblocage;

  /// No description provided for @utilisateursBloques.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs bloqués'**
  String get utilisateursBloques;

  /// No description provided for @aucunUtilisateurBloque.
  ///
  /// In fr, this message translates to:
  /// **'Aucun utilisateur bloqué'**
  String get aucunUtilisateurBloque;

  /// No description provided for @rechercher.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher...'**
  String get rechercher;

  /// No description provided for @leNomDUtilisateurEstObligatoire.
  ///
  /// In fr, this message translates to:
  /// **'Le nom d\'utilisateur est obligatoire'**
  String get leNomDUtilisateurEstObligatoire;

  /// No description provided for @supprimerX.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer {teamName} ?'**
  String supprimerX(String teamName);

  /// No description provided for @voulezVousSupprimerXDeVosEquipesPreferees.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous supprimer {teamName} de vos équipes préférées ?'**
  String voulezVousSupprimerXDeVosEquipesPreferees(String teamName);

  /// No description provided for @annuler.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get annuler;

  /// No description provided for @supprimer.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get supprimer;

  /// No description provided for @voulezVousSupprimerXDeVosCompetitionsPreferees.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous supprimer {competitionName} de vos compétitions préférées ?'**
  String voulezVousSupprimerXDeVosCompetitionsPreferees(String competitionName);

  /// No description provided for @nomDUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get nomDUtilisateur;

  /// No description provided for @continuer.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continuer;

  /// No description provided for @enregistrer.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get enregistrer;

  /// No description provided for @amis.
  ///
  /// In fr, this message translates to:
  /// **'Amis'**
  String get amis;

  /// No description provided for @demandesRecues.
  ///
  /// In fr, this message translates to:
  /// **'demandes reçues'**
  String get demandesRecues;

  /// No description provided for @demandesEnvoyees.
  ///
  /// In fr, this message translates to:
  /// **'demandes envoyées'**
  String get demandesEnvoyees;

  /// No description provided for @amisDeX.
  ///
  /// In fr, this message translates to:
  /// **'Amis de {displayName}'**
  String amisDeX(String displayName);

  /// No description provided for @amis2.
  ///
  /// In fr, this message translates to:
  /// **'Amis'**
  String get amis2;

  /// No description provided for @recues.
  ///
  /// In fr, this message translates to:
  /// **'Reçues'**
  String get recues;

  /// No description provided for @envoyees.
  ///
  /// In fr, this message translates to:
  /// **'Envoyées'**
  String get envoyees;

  /// No description provided for @aucunAmi.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ami'**
  String get aucunAmi;

  /// No description provided for @aucuneDemandeRecue.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande reçue'**
  String get aucuneDemandeRecue;

  /// No description provided for @aucuneDemandeEnvoyee.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande envoyée'**
  String get aucuneDemandeEnvoyee;

  /// No description provided for @erreurLorsDeLActionSurLUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'action sur l\'utilisateur'**
  String get erreurLorsDeLActionSurLUtilisateur;

  /// No description provided for @bienvenueSurScorescope.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur ScoreScope !'**
  String get bienvenueSurScorescope;

  /// No description provided for @bienvenueSurScorescopeDescription.
  ///
  /// In fr, this message translates to:
  /// **'1: Répertorie les matchs que tu as regardé, donne leur une note, et vote pour le meilleur joueur.\n2: Ajoute des amis et partage les matchs que tu as regardé.\n3: Découvrez des dizaines de statistiques sur tes habitudes de visionnage.\n\nAvec ScoreScope, garde un souvenir de chaque match, tel qu\'il a été vécu !'**
  String get bienvenueSurScorescopeDescription;

  /// No description provided for @choisisTesEquipesPreferees.
  ///
  /// In fr, this message translates to:
  /// **'Choisis tes équipes préférées'**
  String get choisisTesEquipesPreferees;

  /// No description provided for @ajouterDesEquipes.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des équipes'**
  String get ajouterDesEquipes;

  /// No description provided for @choisisTesCompetitionsPreferees.
  ///
  /// In fr, this message translates to:
  /// **'Choisis tes compétitions préférées'**
  String get choisisTesCompetitionsPreferees;

  /// No description provided for @ajouterDesCompetitions.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des compétitions'**
  String get ajouterDesCompetitions;

  /// No description provided for @commenceLAventureScorescope.
  ///
  /// In fr, this message translates to:
  /// **'Commence l\'aventure ScoreScope !'**
  String get commenceLAventureScorescope;

  /// No description provided for @personnaliseTonProfilPourEntrerDansLApp.
  ///
  /// In fr, this message translates to:
  /// **'Personnalise ton profil pour entrer dans l\'app'**
  String get personnaliseTonProfilPourEntrerDansLApp;

  /// No description provided for @terminer.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get terminer;

  /// No description provided for @passer.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get passer;

  /// No description provided for @bloquerX.
  ///
  /// In fr, this message translates to:
  /// **'Bloquer {displayName}?,'**
  String bloquerX(String displayName);

  /// No description provided for @voulezVousBloquerX.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous bloquer {displayName}?\nCet utilisateur ne pourra plus accéder à vos posts'**
  String voulezVousBloquerX(String displayName);

  /// No description provided for @bloquer.
  ///
  /// In fr, this message translates to:
  /// **'Bloquer'**
  String get bloquer;

  /// No description provided for @ceCompteEstPrive.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte est privé'**
  String get ceCompteEstPrive;

  /// No description provided for @ajoutezCetAmiPourSuivreSonActualite.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez cet ami pour suivre son actualité !'**
  String get ajoutezCetAmiPourSuivreSonActualite;

  /// No description provided for @unEmailDeConfirmationAEteEnvoyeAVotreNouvelleAdresse.
  ///
  /// In fr, this message translates to:
  /// **'Un email de confirmation a été envoyé à votre nouvelle adresse'**
  String get unEmailDeConfirmationAEteEnvoyeAVotreNouvelleAdresse;

  /// No description provided for @unEmailDeConfirmationAEteEnvoye2.
  ///
  /// In fr, this message translates to:
  /// **'Un email de confirmation a été envoyé'**
  String get unEmailDeConfirmationAEteEnvoye2;

  /// No description provided for @motDePasseIncorrect.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe incorrect'**
  String get motDePasseIncorrect;

  /// No description provided for @confirmezVotreIdentite.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez votre identité'**
  String get confirmezVotreIdentite;

  /// No description provided for @confirmer.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirmer;

  /// No description provided for @modifierLEmail.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'email'**
  String get modifierLEmail;

  /// No description provided for @emailActuel.
  ///
  /// In fr, this message translates to:
  /// **'Email actuel'**
  String get emailActuel;

  /// No description provided for @nouvelEmail.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel email'**
  String get nouvelEmail;

  /// No description provided for @mettreAJour.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour'**
  String get mettreAJour;

  /// No description provided for @motDePasseMisAJourAvecSucces.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe mis à jour avec succès'**
  String get motDePasseMisAJourAvecSucces;

  /// No description provided for @motDePasseActuelIncorrect.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel incorrect'**
  String get motDePasseActuelIncorrect;

  /// No description provided for @modifierLeMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le mot de passe'**
  String get modifierLeMotDePasse;

  /// No description provided for @motDePasseActuel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get motDePasseActuel;

  /// No description provided for @nouveauMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get nouveauMotDePasse;

  /// No description provided for @ceCompteGoogleEstDejaUtiliseParUnAutreUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte Google est déjà utilisé par un autre utilisateur.'**
  String get ceCompteGoogleEstDejaUtiliseParUnAutreUtilisateur;

  /// No description provided for @erreurGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Erreur Google'**
  String get erreurGoogle;

  /// No description provided for @erreurLorsDeLaConnexionGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la connexion Google'**
  String get erreurLorsDeLaConnexionGoogle;

  /// No description provided for @vousDevezAvoirAuMoinsUneMethodeDeConnexionActive.
  ///
  /// In fr, this message translates to:
  /// **'Vous devez avoir au moins une méthode de connexion active'**
  String get vousDevezAvoirAuMoinsUneMethodeDeConnexionActive;

  /// No description provided for @compteGoogleDeconnecte.
  ///
  /// In fr, this message translates to:
  /// **'Compte Google déconnecté'**
  String get compteGoogleDeconnecte;

  /// No description provided for @erreurLorsDeLaDeconnexion.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la déconnexion'**
  String get erreurLorsDeLaDeconnexion;

  /// No description provided for @impossibleDeRecupererVotreEmail.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de récupérer votre email'**
  String get impossibleDeRecupererVotreEmail;

  /// No description provided for @motDePasseAjouteAvecSucces.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe ajouté avec succès'**
  String get motDePasseAjouteAvecSucces;

  /// No description provided for @erreur.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get erreur;

  /// No description provided for @motDePasseSupprime.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe supprimé'**
  String get motDePasseSupprime;

  /// No description provided for @erreurLorsDeLaSuppression.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la suppression'**
  String get erreurLorsDeLaSuppression;

  /// No description provided for @creerUnMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Créer un mot de passe'**
  String get creerUnMotDePasse;

  /// No description provided for @nouveauMotDePasseMin6Caracteres.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe (min. 6 caractères)'**
  String get nouveauMotDePasseMin6Caracteres;

  /// No description provided for @valider.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get valider;

  /// No description provided for @connecte.
  ///
  /// In fr, this message translates to:
  /// **'Connecté'**
  String get connecte;

  /// No description provided for @nonConnecte.
  ///
  /// In fr, this message translates to:
  /// **'Non connecté'**
  String get nonConnecte;

  /// No description provided for @delier.
  ///
  /// In fr, this message translates to:
  /// **'Délier'**
  String get delier;

  /// No description provided for @connecter.
  ///
  /// In fr, this message translates to:
  /// **'Connecter'**
  String get connecter;

  /// No description provided for @comptesConnectes.
  ///
  /// In fr, this message translates to:
  /// **'Comptes connectés'**
  String get comptesConnectes;

  /// No description provided for @emailMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Email / Mot de passe'**
  String get emailMotDePasse;

  /// No description provided for @google.
  ///
  /// In fr, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @compteGoogleConnecte.
  ///
  /// In fr, this message translates to:
  /// **'Compte Google connecté'**
  String get compteGoogleConnecte;

  /// No description provided for @securite.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get securite;

  /// No description provided for @zoneSensible.
  ///
  /// In fr, this message translates to:
  /// **'Zone sensible'**
  String get zoneSensible;

  /// No description provided for @seDeconnecter.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get seDeconnecter;

  /// No description provided for @supprimerLesDonnees.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer les données'**
  String get supprimerLesDonnees;

  /// No description provided for @supprimerLeCompte.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte'**
  String get supprimerLeCompte;

  /// No description provided for @voulezVousVraimentVousDeconnecter.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment vous déconnecter ?'**
  String get voulezVousVraimentVousDeconnecter;

  /// No description provided for @supprimerLesMatchsRegardes.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer les matchs regardés'**
  String get supprimerLesMatchsRegardes;

  /// No description provided for @supprimerLesAmis.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer les amis'**
  String get supprimerLesAmis;

  /// No description provided for @supprimerLesNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer les notifications'**
  String get supprimerLesNotifications;

  /// No description provided for @reinitialiserLesPreferences.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser les préférences'**
  String get reinitialiserLesPreferences;

  /// No description provided for @supprimerLesMatchsRegardesEnsemble.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer les matchs regardés ensemble'**
  String get supprimerLesMatchsRegardesEnsemble;

  /// No description provided for @donneesSupprimeesAvecSucces.
  ///
  /// In fr, this message translates to:
  /// **'Données supprimées avec succès'**
  String get donneesSupprimeesAvecSucces;

  /// No description provided for @cetteActionEstIrreversibleToutesVosDonneesSerontDefinitivementSupprimees.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible. Toutes vos données seront définitivement supprimées'**
  String
      get cetteActionEstIrreversibleToutesVosDonneesSerontDefinitivementSupprimees;

  /// No description provided for @compteSupprimeAvecSucces.
  ///
  /// In fr, this message translates to:
  /// **'Compte supprimé avec succès'**
  String get compteSupprimeAvecSucces;

  /// No description provided for @compte.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get compte;

  /// No description provided for @comptePrive.
  ///
  /// In fr, this message translates to:
  /// **'Compte privé'**
  String get comptePrive;

  /// No description provided for @autresUtilisateurs.
  ///
  /// In fr, this message translates to:
  /// **'Autres utilisateurs'**
  String get autresUtilisateurs;

  /// No description provided for @listeDesUtilisateursBloques.
  ///
  /// In fr, this message translates to:
  /// **'Liste des utilisateurs bloqués'**
  String get listeDesUtilisateursBloques;

  /// No description provided for @general.
  ///
  /// In fr, this message translates to:
  /// **'Général'**
  String get general;

  /// No description provided for @activerLesNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Activer les notifications'**
  String get activerLesNotifications;

  /// No description provided for @social.
  ///
  /// In fr, this message translates to:
  /// **'Social'**
  String get social;

  /// No description provided for @demandesDAmis.
  ///
  /// In fr, this message translates to:
  /// **'Demandes d\'amis'**
  String get demandesDAmis;

  /// No description provided for @demandeDAmiAcceptee.
  ///
  /// In fr, this message translates to:
  /// **'Demande d\'ami acceptée'**
  String get demandeDAmiAcceptee;

  /// No description provided for @reactionsSurTesMatchs.
  ///
  /// In fr, this message translates to:
  /// **'Réactions sur tes matchs'**
  String get reactionsSurTesMatchs;

  /// No description provided for @commentairesSurTesMatchs.
  ///
  /// In fr, this message translates to:
  /// **'Commentaires sur tes matchs'**
  String get commentairesSurTesMatchs;

  /// No description provided for @finDeMatchEquipeFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Fin de match équipe favorite'**
  String get finDeMatchEquipeFavorite;

  /// No description provided for @recapHebdomadaire.
  ///
  /// In fr, this message translates to:
  /// **'Récap hebdomadaire'**
  String get recapHebdomadaire;

  /// No description provided for @theme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get theme;

  /// No description provided for @langue.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get langue;

  /// No description provided for @modeDeVisionnageParDefaut.
  ///
  /// In fr, this message translates to:
  /// **'Mode de visionnage par défaut'**
  String get modeDeVisionnageParDefaut;

  /// No description provided for @utiliserLeCache.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser le cache'**
  String get utiliserLeCache;

  /// No description provided for @conditionsDUtilisation.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get conditionsDUtilisation;

  /// No description provided for @enUtilisantScorescopeVousAcceptezDUtiliserLApplicationDeManiereResponsable.
  ///
  /// In fr, this message translates to:
  /// **'En utilisant ScoreScope, vous acceptez d\'utiliser l\'application de manière responsable.'**
  String
      get enUtilisantScorescopeVousAcceptezDUtiliserLApplicationDeManiereResponsable;

  /// No description provided for @vousEtesResponsableDuContenuQueVousPubliezNotesAvisMvpEtc.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes responsable du contenu que vous publiez (notes, avis, MVP, etc.).'**
  String get vousEtesResponsableDuContenuQueVousPubliezNotesAvisMvpEtc;

  /// No description provided for @scorescopeSeReserveLeDroitDeSupprimerToutContenuInapproprie.
  ///
  /// In fr, this message translates to:
  /// **'ScoreScope se réserve le droit de supprimer tout contenu inapproprié.'**
  String get scorescopeSeReserveLeDroitDeSupprimerToutContenuInapproprie;

  /// No description provided for @lApplicationEstFournieTelleQuelleSansGarantieDeDisponibilitePermanente.
  ///
  /// In fr, this message translates to:
  /// **'L\'application est fournie telle quelle, sans garantie de disponibilité permanente.'**
  String
      get lApplicationEstFournieTelleQuelleSansGarantieDeDisponibilitePermanente;

  /// No description provided for @politiqueDeConfidentialite.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get politiqueDeConfidentialite;

  /// No description provided for @scorescopeCollecteUniquementLesDonneesNecessairesAuFonctionnementDeLApplicationCompteMatchsInteractionsSociales.
  ///
  /// In fr, this message translates to:
  /// **'ScoreScope collecte uniquement les données nécessaires au fonctionnement de l\'application (compte, matchs, interactions sociales).'**
  String
      get scorescopeCollecteUniquementLesDonneesNecessairesAuFonctionnementDeLApplicationCompteMatchsInteractionsSociales;

  /// No description provided for @vosDonneesNeSontPasRevenduesADesTiers.
  ///
  /// In fr, this message translates to:
  /// **'Vos données ne sont pas revendues à des tiers.'**
  String get vosDonneesNeSontPasRevenduesADesTiers;

  /// No description provided for @vousPouvezDemanderLaSuppressionDeVotreCompteAToutMoment.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez demander la suppression de votre compte à tout moment.'**
  String get vousPouvezDemanderLaSuppressionDeVotreCompteAToutMoment;

  /// No description provided for @nousFaisonsDeNotreMieuxPourProtegerVosDonnees.
  ///
  /// In fr, this message translates to:
  /// **'Nous faisons de notre mieux pour protéger vos données.'**
  String get nousFaisonsDeNotreMieuxPourProtegerVosDonnees;

  /// No description provided for @supportInformations.
  ///
  /// In fr, this message translates to:
  /// **'Support & Informations'**
  String get supportInformations;

  /// No description provided for @aPropos.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get aPropos;

  /// No description provided for @signalerUnBug.
  ///
  /// In fr, this message translates to:
  /// **'Signaler un bug'**
  String get signalerUnBug;

  /// No description provided for @cgu.
  ///
  /// In fr, this message translates to:
  /// **'CGU'**
  String get cgu;

  /// No description provided for @version.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @tonCarnetDeMatchsDeFoot.
  ///
  /// In fr, this message translates to:
  /// **'Ton carnet de matchs de foot ⚽'**
  String get tonCarnetDeMatchsDeFoot;

  /// No description provided for @noteLesMatchsQueTuRegardesElisLeMvpEtPartageTonExperienceAvecTesAmis.
  ///
  /// In fr, this message translates to:
  /// **'Note les matchs que tu regardes, élis le MVP et partage ton expérience avec tes amis'**
  String
      get noteLesMatchsQueTuRegardesElisLeMvpEtPartageTonExperienceAvecTesAmis;

  /// No description provided for @fermer.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get fermer;

  /// No description provided for @saisonXX.
  ///
  /// In fr, this message translates to:
  /// **'Saison {season}/{totalSeasons}'**
  String saisonXX(String season, String totalSeasons);

  /// No description provided for @aucunAmiNAVuCeMatch.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ami n\'a vu ce match'**
  String get aucunAmiNAVuCeMatch;

  /// No description provided for @utilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get utilisateur;

  /// No description provided for @vousAvezSupprimeLaReactionX.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez supprimé la réaction {emoji}'**
  String vousAvezSupprimeLaReactionX(String emoji);

  /// No description provided for @ecrireUnCommentaire.
  ///
  /// In fr, this message translates to:
  /// **'Écrire un commentaire'**
  String get ecrireUnCommentaire;

  /// No description provided for @ecrisUnCommentaire.
  ///
  /// In fr, this message translates to:
  /// **'Écris un commentaire...'**
  String get ecrisUnCommentaire;

  /// No description provided for @ajouteLesAmisAvecQuiTuAsRegardeLeMatch.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute les amis avec qui tu as regardé le match'**
  String get ajouteLesAmisAvecQuiTuAsRegardeLeMatch;

  /// No description provided for @rechercherUnAmi.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un ami...'**
  String get rechercherUnAmi;

  /// No description provided for @aucunAmiTrouve.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ami trouvé'**
  String get aucunAmiTrouve;

  /// No description provided for @enAttente.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get enAttente;

  /// No description provided for @laCompositionNEstPasEncoreDisponible.
  ///
  /// In fr, this message translates to:
  /// **'La composition n\'est pas encore disponible'**
  String get laCompositionNEstPasEncoreDisponible;

  /// No description provided for @remplacants.
  ///
  /// In fr, this message translates to:
  /// **'Remplaçants'**
  String get remplacants;

  /// No description provided for @voulezVousSupprimerXDesAmisQuiOntRegardeLeMatchAvecVous.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous supprimer {displayName} des amis qui ont regardé le match avec vous ?'**
  String voulezVousSupprimerXDesAmisQuiOntRegardeLeMatchAvecVous(
      String displayName);

  /// No description provided for @leMatchNAPasEncoreCommence.
  ///
  /// In fr, this message translates to:
  /// **'Le match n\'a pas encore commencé !'**
  String get leMatchNAPasEncoreCommence;

  /// No description provided for @activeLesNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Active les notifications'**
  String get activeLesNotifications;

  /// No description provided for @impossibleDeChargerLaListeDesAmis.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger la liste des amis'**
  String get impossibleDeChargerLaListeDesAmis;

  /// No description provided for @impossibleDeRecupererLUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de récupérer l\'utilisateur'**
  String get impossibleDeRecupererLUtilisateur;

  /// No description provided for @echecDeLaSauvegardeReessayePlusTard.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la sauvegarde — réessaye plus tard'**
  String get echecDeLaSauvegardeReessayePlusTard;

  /// No description provided for @visionnage.
  ///
  /// In fr, this message translates to:
  /// **'Visionnage'**
  String get visionnage;

  /// No description provided for @choisirLeModeDeVisionnage.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le mode de visionnage'**
  String get choisirLeModeDeVisionnage;

  /// No description provided for @confirme.
  ///
  /// In fr, this message translates to:
  /// **'Confirmé'**
  String get confirme;

  /// No description provided for @regardeAvec.
  ///
  /// In fr, this message translates to:
  /// **'Regardé avec'**
  String get regardeAvec;

  /// No description provided for @tuAsRegardeCeMatchAvecDesAmis.
  ///
  /// In fr, this message translates to:
  /// **'Tu as regardé ce match avec des amis ?'**
  String get tuAsRegardeCeMatchAvecDesAmis;

  /// No description provided for @ajouteLesAmisAvecQuiTuAsVuCeMatch.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute les amis avec qui tu as vu ce match'**
  String get ajouteLesAmisAvecQuiTuAsVuCeMatch;

  /// No description provided for @ajouterUnAmi.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un ami'**
  String get ajouterUnAmi;

  /// No description provided for @mt.
  ///
  /// In fr, this message translates to:
  /// **'MT'**
  String get mt;

  /// No description provided for @toutMarquerCommeVu.
  ///
  /// In fr, this message translates to:
  /// **'Tout marquer comme vu'**
  String get toutMarquerCommeVu;

  /// No description provided for @aucuneNouvelleNotification.
  ///
  /// In fr, this message translates to:
  /// **'Aucune nouvelle notification'**
  String get aucuneNouvelleNotification;

  /// No description provided for @dejaVues.
  ///
  /// In fr, this message translates to:
  /// **'Déjà vues'**
  String get dejaVues;

  /// No description provided for @invitationARegarderLeMatchEnsemble.
  ///
  /// In fr, this message translates to:
  /// **'Invitation à regarder le match ensemble'**
  String get invitationARegarderLeMatchEnsemble;

  /// No description provided for @acceptezVousLInvitationARegarderLeMatchAvecX.
  ///
  /// In fr, this message translates to:
  /// **'Acceptez-vous l\'invitation à regarder le match avec {displayName} ?'**
  String acceptezVousLInvitationARegarderLeMatchAvecX(String displayName);

  /// No description provided for @refuser.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get refuser;

  /// No description provided for @accepter.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get accepter;

  /// No description provided for @ontCommenteVotreMatch.
  ///
  /// In fr, this message translates to:
  /// **'ont commenté votre match'**
  String get ontCommenteVotreMatch;

  /// No description provided for @aCommenteVotreMatch.
  ///
  /// In fr, this message translates to:
  /// **'a commenté votre match'**
  String get aCommenteVotreMatch;

  /// No description provided for @ontReagiAVotreMatch.
  ///
  /// In fr, this message translates to:
  /// **'ont réagi à votre match'**
  String get ontReagiAVotreMatch;

  /// No description provided for @aReagiAVotreMatch.
  ///
  /// In fr, this message translates to:
  /// **'a réagi à votre match'**
  String get aReagiAVotreMatch;

  /// No description provided for @vousInviteARegarderLeMatchEnsemble.
  ///
  /// In fr, this message translates to:
  /// **'vous invite à regarder le match ensemble'**
  String get vousInviteARegarderLeMatchEnsemble;

  /// No description provided for @aInteragiAvecVotrePost.
  ///
  /// In fr, this message translates to:
  /// **'a interagi avec votre post'**
  String get aInteragiAvecVotrePost;

  /// No description provided for @etXAutres.
  ///
  /// In fr, this message translates to:
  /// **'et {remaining} autres'**
  String etXAutres(String remaining);

  /// No description provided for @aucuneCompetitionPreferee.
  ///
  /// In fr, this message translates to:
  /// **'Aucune compétition préférée'**
  String get aucuneCompetitionPreferee;

  /// No description provided for @xMatchsRegardes.
  ///
  /// In fr, this message translates to:
  /// **'{nbMatchs} matchs regardés'**
  String xMatchsRegardes(String nbMatchs);

  /// No description provided for @aucuneEquipePreferee.
  ///
  /// In fr, this message translates to:
  /// **'Aucune équipe préférée'**
  String get aucuneEquipePreferee;

  /// No description provided for @aucunMatchFavori.
  ///
  /// In fr, this message translates to:
  /// **'Aucun match favori'**
  String get aucunMatchFavori;

  /// No description provided for @aucunMatchRegarde.
  ///
  /// In fr, this message translates to:
  /// **'Aucun match regardé'**
  String get aucunMatchRegarde;

  /// No description provided for @erreurAucunUtilisateurNEstSpecifie.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : aucun utilisateur n\'est spécifié'**
  String get erreurAucunUtilisateurNEstSpecifie;

  /// No description provided for @modifierLeProfil.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get modifierLeProfil;

  /// No description provided for @demandeRecue.
  ///
  /// In fr, this message translates to:
  /// **'Demande reçue'**
  String get demandeRecue;

  /// No description provided for @bloque.
  ///
  /// In fr, this message translates to:
  /// **'Bloqué'**
  String get bloque;

  /// No description provided for @ajouter.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get ajouter;

  /// No description provided for @retirerLaDemande.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la demande'**
  String get retirerLaDemande;

  /// No description provided for @retirer.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get retirer;

  /// No description provided for @debloquer.
  ///
  /// In fr, this message translates to:
  /// **'Débloquer'**
  String get debloquer;

  /// No description provided for @amitie.
  ///
  /// In fr, this message translates to:
  /// **'Amitié'**
  String get amitie;

  /// No description provided for @cetUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'cet utilisateur'**
  String get cetUtilisateur;

  /// No description provided for @voulezVousRetirerLAmiX.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous retirer l\'ami {displayName} ?'**
  String voulezVousRetirerLAmiX(String displayName);

  /// No description provided for @voulezVousRetirerLaDemandeDAmiAX.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous retirer la demande d\'ami à {displayName} ?'**
  String voulezVousRetirerLaDemandeDAmiAX(String displayName);

  /// No description provided for @accepterLaDemandeDAmiDeX.
  ///
  /// In fr, this message translates to:
  /// **'Accepter la demande d\'ami de {displayName} ?'**
  String accepterLaDemandeDAmiDeX(String displayName);

  /// No description provided for @voulezVousDebloquerX.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous débloquer {displayName} ?'**
  String voulezVousDebloquerX(String displayName);

  /// No description provided for @voulezVousEnvoyerUneDemandeDAmiAX.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous envoyer une demande d\'ami à {displayName} ?'**
  String voulezVousEnvoyerUneDemandeDAmiAX(String displayName);

  /// No description provided for @clubs.
  ///
  /// In fr, this message translates to:
  /// **'Clubs'**
  String get clubs;

  /// No description provided for @international.
  ///
  /// In fr, this message translates to:
  /// **'International'**
  String get international;

  /// No description provided for @selectionDesCompetitions.
  ///
  /// In fr, this message translates to:
  /// **'Sélection des compétitions'**
  String get selectionDesCompetitions;

  /// No description provided for @mesCompetitionsFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Mes compétitions favorites'**
  String get mesCompetitionsFavorites;

  /// No description provided for @toutesLesCompetitions.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les compétitions'**
  String get toutesLesCompetitions;

  /// No description provided for @validerLaSelection.
  ///
  /// In fr, this message translates to:
  /// **'Valider la sélection'**
  String get validerLaSelection;

  /// No description provided for @selectionDesEquipes.
  ///
  /// In fr, this message translates to:
  /// **'Sélection des équipes'**
  String get selectionDesEquipes;

  /// No description provided for @rechercherUneEquipe.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une équipe…'**
  String get rechercherUneEquipe;

  /// No description provided for @rechercheTonEquipePreferee.
  ///
  /// In fr, this message translates to:
  /// **'🔍 Recherche ton équipe préférée'**
  String get rechercheTonEquipePreferee;

  /// No description provided for @mesEquipesFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Mes équipes favorites'**
  String get mesEquipesFavorites;

  /// No description provided for @aucuneEquipeTrouvee.
  ///
  /// In fr, this message translates to:
  /// **'Aucune équipe trouvée'**
  String get aucuneEquipeTrouvee;

  /// No description provided for @resultats.
  ///
  /// In fr, this message translates to:
  /// **'Résultats'**
  String get resultats;

  /// No description provided for @tuPeuxSelectionnerJusquA10Equipes.
  ///
  /// In fr, this message translates to:
  /// **'Tu peux sélectionner jusqu\'à 10 équipes'**
  String get tuPeuxSelectionnerJusquA10Equipes;

  /// No description provided for @statistiques.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get statistiques;

  /// No description provided for @profil.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profil;

  /// No description provided for @retours.
  ///
  /// In fr, this message translates to:
  /// **'Retours'**
  String get retours;

  /// No description provided for @inconnu.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu'**
  String get inconnu;

  /// No description provided for @unMatch.
  ///
  /// In fr, this message translates to:
  /// **'un match'**
  String get unMatch;

  /// No description provided for @autres2.
  ///
  /// In fr, this message translates to:
  /// **'Autres'**
  String get autres2;

  /// No description provided for @selectionnerUneDate.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une date'**
  String get selectionnerUneDate;

  /// No description provided for @appliquer.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get appliquer;

  /// No description provided for @commenceATaperPourRechercher.
  ///
  /// In fr, this message translates to:
  /// **'Commence à taper pour rechercher'**
  String get commenceATaperPourRechercher;

  /// No description provided for @encoreXCaractereX.
  ///
  /// In fr, this message translates to:
  /// **'Encore {value1} caractère{value2}…'**
  String encoreXCaractereX(String value1, String value2);

  /// No description provided for @aucunResultat.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get aucunResultat;

  /// No description provided for @ajouterDesAmis.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des amis'**
  String get ajouterDesAmis;

  /// No description provided for @rechercherUnUtilisateur.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un utilisateur'**
  String get rechercherUnUtilisateur;

  /// No description provided for @tapezAuMoinsXCaracteresPourLancerLaRecherche.
  ///
  /// In fr, this message translates to:
  /// **'Tapez au moins {minCharsToSearch} caractères pour lancer la recherche'**
  String tapezAuMoinsXCaracteresPourLancerLaRecherche(String minCharsToSearch);

  /// No description provided for @entrezUneRecherchePourTrouverDesUtilisateurs.
  ///
  /// In fr, this message translates to:
  /// **'Entrez une recherche pour trouver des utilisateurs'**
  String get entrezUneRecherchePourTrouverDesUtilisateurs;

  /// No description provided for @erreurLorsDeLaRechercheX.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la recherche : {error}'**
  String erreurLorsDeLaRechercheX(String error);

  /// No description provided for @aucunUtilisateurTrouve.
  ///
  /// In fr, this message translates to:
  /// **'Aucun utilisateur trouvé'**
  String get aucunUtilisateurTrouve;

  /// No description provided for @xPostsCharges.
  ///
  /// In fr, this message translates to:
  /// **'{length} posts chargés'**
  String xPostsCharges(String length);

  /// No description provided for @erreurLorsDuChargementDesDonneesUtilisateurDuMatchX.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement des données utilisateur du match: {error}'**
  String erreurLorsDuChargementDesDonneesUtilisateurDuMatchX(String error);

  /// No description provided for @matchAjouteAuxFavoris.
  ///
  /// In fr, this message translates to:
  /// **'Match ajouté aux favoris'**
  String get matchAjouteAuxFavoris;

  /// No description provided for @matchRetireDesFavoris.
  ///
  /// In fr, this message translates to:
  /// **'Match retiré des favoris'**
  String get matchRetireDesFavoris;

  /// No description provided for @erreurLorsDeLaMiseAJourDuFavori.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la mise à jour du favori'**
  String get erreurLorsDeLaMiseAJourDuFavori;

  /// No description provided for @rendreLeMatchPublic.
  ///
  /// In fr, this message translates to:
  /// **'Rendre le match public'**
  String get rendreLeMatchPublic;

  /// No description provided for @leMatchSeraRenduPublicEtVisibleParVosAmis.
  ///
  /// In fr, this message translates to:
  /// **'Le match sera rendu public et visible par vos amis'**
  String get leMatchSeraRenduPublicEtVisibleParVosAmis;

  /// No description provided for @rendrePublic.
  ///
  /// In fr, this message translates to:
  /// **'Rendre public'**
  String get rendrePublic;

  /// No description provided for @rendreLeMatchPrive.
  ///
  /// In fr, this message translates to:
  /// **'Rendre le match privé'**
  String get rendreLeMatchPrive;

  /// No description provided for @leMatchResteraPriveEtNeSeraPasVisibleParVosAmis.
  ///
  /// In fr, this message translates to:
  /// **'Le match restera privé et ne sera pas visible par vos amis.'**
  String get leMatchResteraPriveEtNeSeraPasVisibleParVosAmis;

  /// No description provided for @rendrePrive.
  ///
  /// In fr, this message translates to:
  /// **'Rendre privé'**
  String get rendrePrive;

  /// No description provided for @supprimerLeMatch.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le match'**
  String get supprimerLeMatch;

  /// No description provided for @matchRenduPrive.
  ///
  /// In fr, this message translates to:
  /// **'Match rendu privé'**
  String get matchRenduPrive;

  /// No description provided for @matchRenduPublic.
  ///
  /// In fr, this message translates to:
  /// **'Match rendu public'**
  String get matchRenduPublic;

  /// No description provided for @erreurLorsDeLaMiseAJourDeLaConfidentialite.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la mise à jour de la confidentialité'**
  String get erreurLorsDeLaMiseAJourDeLaConfidentialite;

  /// No description provided for @matchSupprime.
  ///
  /// In fr, this message translates to:
  /// **'Match supprimé'**
  String get matchSupprime;

  /// No description provided for @erreurLorsDeLaSuppressionDuMatch.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la suppression du match (réessayez)'**
  String get erreurLorsDeLaSuppressionDuMatch;

  /// No description provided for @notificationsXPourXX.
  ///
  /// In fr, this message translates to:
  /// **'Notifications {value1} pour {value2} - {value3}'**
  String notificationsXPourXX(String value1, String value2, String value3);

  /// No description provided for @matchPrive.
  ///
  /// In fr, this message translates to:
  /// **'Match privé'**
  String get matchPrive;

  /// No description provided for @matchPublic.
  ///
  /// In fr, this message translates to:
  /// **'Match public'**
  String get matchPublic;

  /// No description provided for @aRegardeCeMatch.
  ///
  /// In fr, this message translates to:
  /// **'a regardé ce match'**
  String get aRegardeCeMatch;

  /// No description provided for @nonNote.
  ///
  /// In fr, this message translates to:
  /// **'Non noté'**
  String get nonNote;

  /// No description provided for @note.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @mvpVote.
  ///
  /// In fr, this message translates to:
  /// **'MVP voté'**
  String get mvpVote;

  /// No description provided for @bio.
  ///
  /// In fr, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @equipesPreferees.
  ///
  /// In fr, this message translates to:
  /// **'Équipes préférées'**
  String get equipesPreferees;

  /// No description provided for @modifier.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get modifier;

  /// No description provided for @competitionsPreferees.
  ///
  /// In fr, this message translates to:
  /// **'Compétitions préférées'**
  String get competitionsPreferees;

  /// No description provided for @creezVotreProfil.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre profil'**
  String get creezVotreProfil;

  /// No description provided for @parametres.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get parametres;

  /// No description provided for @confidentialite.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get confidentialite;

  /// No description provided for @preferences.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get preferences;

  /// No description provided for @derniersMatchs.
  ///
  /// In fr, this message translates to:
  /// **'Derniers matchs'**
  String get derniersMatchs;

  /// No description provided for @matchsFavoris.
  ///
  /// In fr, this message translates to:
  /// **'Matchs favoris'**
  String get matchsFavoris;

  /// No description provided for @filtrerParPeriode.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer par période'**
  String get filtrerParPeriode;

  /// No description provided for @periodePersonnalisee.
  ///
  /// In fr, this message translates to:
  /// **'Période personnalisée'**
  String get periodePersonnalisee;

  /// No description provided for @saison.
  ///
  /// In fr, this message translates to:
  /// **'Saison'**
  String get saison;

  /// No description provided for @selectionnerUnePeriode.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une période'**
  String get selectionnerUnePeriode;

  /// No description provided for @selectionnerLaSaison.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner la saison'**
  String get selectionnerLaSaison;

  /// No description provided for @mesStatistiques.
  ///
  /// In fr, this message translates to:
  /// **'Mes statistiques'**
  String get mesStatistiques;

  /// No description provided for @statistiquesDeX.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques de {displayName}'**
  String statistiquesDeX(String displayName);

  /// No description provided for @filtrerParDate.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer par date'**
  String get filtrerParDate;

  /// No description provided for @afficherEnListe.
  ///
  /// In fr, this message translates to:
  /// **'Afficher en liste'**
  String get afficherEnListe;

  /// No description provided for @afficherEnCards.
  ///
  /// In fr, this message translates to:
  /// **'Afficher en cards'**
  String get afficherEnCards;

  /// No description provided for @matchsPublicsUniquement.
  ///
  /// In fr, this message translates to:
  /// **'Matchs publics uniquement'**
  String get matchsPublicsUniquement;

  /// No description provided for @saisonXX2.
  ///
  /// In fr, this message translates to:
  /// **'Saison : {season} / {season2}'**
  String saisonXX2(String season, String season2);

  /// No description provided for @periodeXX.
  ///
  /// In fr, this message translates to:
  /// **'Période : {start} → {end}'**
  String periodeXX(String start, String end);

  /// No description provided for @habitudes.
  ///
  /// In fr, this message translates to:
  /// **'Habitudes'**
  String get habitudes;

  /// No description provided for @recapHebdo.
  ///
  /// In fr, this message translates to:
  /// **'RECAP HEBDO'**
  String get recapHebdo;

  /// No description provided for @meilleurMatch2.
  ///
  /// In fr, this message translates to:
  /// **'MEILLEUR MATCH'**
  String get meilleurMatch2;

  /// No description provided for @competition.
  ///
  /// In fr, this message translates to:
  /// **'COMPÉTITION'**
  String get competition;

  /// No description provided for @serie2.
  ///
  /// In fr, this message translates to:
  /// **'SÉRIE'**
  String get serie2;

  /// No description provided for @telechargeScorescope.
  ///
  /// In fr, this message translates to:
  /// **'Télécharge ScoreScope'**
  String get telechargeScorescope;

  /// No description provided for @xXVsSemainePrecedente.
  ///
  /// In fr, this message translates to:
  /// **'{value1}{diff} vs semaine précédente,'**
  String xXVsSemainePrecedente(String value1, String diff);

  /// No description provided for @votePourMvp.
  ///
  /// In fr, this message translates to:
  /// **'Vote pour MVP'**
  String get votePourMvp;

  /// No description provided for @pasDeVotePourLeMvp.
  ///
  /// In fr, this message translates to:
  /// **'Pas de vote pour le MVP'**
  String get pasDeVotePourLeMvp;

  /// No description provided for @utilisateurIntrouvable.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur introuvable'**
  String get utilisateurIntrouvable;

  /// No description provided for @voirTousLesXCommentaires.
  ///
  /// In fr, this message translates to:
  /// **'Voir tous les {length} commentaires'**
  String voirTousLesXCommentaires(String length);

  /// No description provided for @voirTousLesCommentaires.
  ///
  /// In fr, this message translates to:
  /// **'Voir tous les commentaires'**
  String get voirTousLesCommentaires;

  /// No description provided for @recents.
  ///
  /// In fr, this message translates to:
  /// **'Récents'**
  String get recents;

  /// No description provided for @rechercherUnEmojiParNomOuCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un emoji par nom ou catégorie…'**
  String get rechercherUnEmojiParNomOuCategorie;

  /// No description provided for @infosMatch.
  ///
  /// In fr, this message translates to:
  /// **'Infos match'**
  String get infosMatch;

  /// No description provided for @noteDuMatch.
  ///
  /// In fr, this message translates to:
  /// **'Note du match'**
  String get noteDuMatch;

  /// No description provided for @xVoteX.
  ///
  /// In fr, this message translates to:
  /// **'{noteCount} vote{value2}'**
  String xVoteX(String noteCount, String value2);

  /// No description provided for @moyenne.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne'**
  String get moyenne;

  /// No description provided for @min.
  ///
  /// In fr, this message translates to:
  /// **'Min'**
  String get min;

  /// No description provided for @max.
  ///
  /// In fr, this message translates to:
  /// **'Max'**
  String get max;

  /// No description provided for @effacerMaNote.
  ///
  /// In fr, this message translates to:
  /// **'Effacer ma note'**
  String get effacerMaNote;

  /// No description provided for @note2.
  ///
  /// In fr, this message translates to:
  /// **'Noté'**
  String get note2;

  /// No description provided for @mvpDuMatch.
  ///
  /// In fr, this message translates to:
  /// **'MVP du match'**
  String get mvpDuMatch;

  /// No description provided for @aucunMvpElu.
  ///
  /// In fr, this message translates to:
  /// **'Aucun MVP élu'**
  String get aucunMvpElu;

  /// No description provided for @soisLePremierAVoter.
  ///
  /// In fr, this message translates to:
  /// **'Sois le premier à voter !'**
  String get soisLePremierAVoter;

  /// No description provided for @votreVote.
  ///
  /// In fr, this message translates to:
  /// **'Votre vote'**
  String get votreVote;

  /// No description provided for @changer.
  ///
  /// In fr, this message translates to:
  /// **'Changer'**
  String get changer;

  /// No description provided for @voter.
  ///
  /// In fr, this message translates to:
  /// **'Voter'**
  String get voter;

  /// No description provided for @aucunJoueurSelectionne.
  ///
  /// In fr, this message translates to:
  /// **'Aucun joueur sélectionné'**
  String get aucunJoueurSelectionne;

  /// No description provided for @selectionnezUnJoueurPourVoter.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez un joueur pour voter'**
  String get selectionnezUnJoueurPourVoter;

  /// No description provided for @vider.
  ///
  /// In fr, this message translates to:
  /// **'Vider'**
  String get vider;

  /// No description provided for @vote.
  ///
  /// In fr, this message translates to:
  /// **'Voté'**
  String get vote;

  /// No description provided for @aucunMatchEnregistre.
  ///
  /// In fr, this message translates to:
  /// **'Aucun match enregistré'**
  String get aucunMatchEnregistre;

  /// No description provided for @aucuneNotification.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification'**
  String get aucuneNotification;

  /// No description provided for @buts.
  ///
  /// In fr, this message translates to:
  /// **'Buts'**
  String get buts;

  /// No description provided for @voirPlus.
  ///
  /// In fr, this message translates to:
  /// **'Voir plus'**
  String get voirPlus;

  /// No description provided for @derniersMatchsAjoutes.
  ///
  /// In fr, this message translates to:
  /// **'Derniers matchs ajoutés'**
  String get derniersMatchsAjoutes;

  /// No description provided for @matchs2.
  ///
  /// In fr, this message translates to:
  /// **'matchs'**
  String get matchs2;

  /// No description provided for @buts2.
  ///
  /// In fr, this message translates to:
  /// **'buts'**
  String get buts2;

  /// No description provided for @rechercherUnMatchUneEquipeUnJoueur.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un match, une équipe, un joueur…'**
  String get rechercherUnMatchUneEquipeUnJoueur;

  /// No description provided for @aucuneDonneeDisponible.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée disponible'**
  String get aucuneDonneeDisponible;

  /// No description provided for @comparerAvecUnAmi.
  ///
  /// In fr, this message translates to:
  /// **'Comparer avec un ami'**
  String get comparerAvecUnAmi;

  /// No description provided for @aucunAmiAAfficher.
  ///
  /// In fr, this message translates to:
  /// **'Aucun ami à afficher'**
  String get aucunAmiAAfficher;

  /// No description provided for @baseSurXMatchsRegardes.
  ///
  /// In fr, this message translates to:
  /// **'Basé sur {watchedMatchesCount} matchs regardés'**
  String baseSurXMatchsRegardes(String watchedMatchesCount);

  /// No description provided for @comparer.
  ///
  /// In fr, this message translates to:
  /// **'Comparer'**
  String get comparer;

  /// No description provided for @mvps.
  ///
  /// In fr, this message translates to:
  /// **'MVPs'**
  String get mvps;

  /// No description provided for @appuieSurUnPointPourVoirLeJoueur.
  ///
  /// In fr, this message translates to:
  /// **'Appuie sur un point pour voir le joueur'**
  String get appuieSurUnPointPourVoirLeJoueur;

  /// No description provided for @matchsRegardes.
  ///
  /// In fr, this message translates to:
  /// **'matchs regardés'**
  String get matchsRegardes;

  /// No description provided for @janvier.
  ///
  /// In fr, this message translates to:
  /// **'Janvier'**
  String get janvier;

  /// No description provided for @fevrier.
  ///
  /// In fr, this message translates to:
  /// **'Février'**
  String get fevrier;

  /// No description provided for @mars.
  ///
  /// In fr, this message translates to:
  /// **'Mars'**
  String get mars;

  /// No description provided for @avril.
  ///
  /// In fr, this message translates to:
  /// **'Avril'**
  String get avril;

  /// No description provided for @mai.
  ///
  /// In fr, this message translates to:
  /// **'Mai'**
  String get mai;

  /// No description provided for @juin.
  ///
  /// In fr, this message translates to:
  /// **'Juin'**
  String get juin;

  /// No description provided for @juillet.
  ///
  /// In fr, this message translates to:
  /// **'Juillet'**
  String get juillet;

  /// No description provided for @aout.
  ///
  /// In fr, this message translates to:
  /// **'Août'**
  String get aout;

  /// No description provided for @septembre.
  ///
  /// In fr, this message translates to:
  /// **'Septembre'**
  String get septembre;

  /// No description provided for @octobre.
  ///
  /// In fr, this message translates to:
  /// **'Octobre'**
  String get octobre;

  /// No description provided for @novembre.
  ///
  /// In fr, this message translates to:
  /// **'Novembre'**
  String get novembre;

  /// No description provided for @decembre.
  ///
  /// In fr, this message translates to:
  /// **'Décembre'**
  String get decembre;

  /// No description provided for @jan.
  ///
  /// In fr, this message translates to:
  /// **'Jan'**
  String get jan;

  /// No description provided for @fev.
  ///
  /// In fr, this message translates to:
  /// **'Fév'**
  String get fev;

  /// No description provided for @mar.
  ///
  /// In fr, this message translates to:
  /// **'Mar'**
  String get mar;

  /// No description provided for @avr.
  ///
  /// In fr, this message translates to:
  /// **'Avr'**
  String get avr;

  /// No description provided for @juil.
  ///
  /// In fr, this message translates to:
  /// **'Juil'**
  String get juil;

  /// No description provided for @sep.
  ///
  /// In fr, this message translates to:
  /// **'Sep'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In fr, this message translates to:
  /// **'Oct'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In fr, this message translates to:
  /// **'Nov'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In fr, this message translates to:
  /// **'Déc'**
  String get dec;

  /// No description provided for @erreurLorsDuChargementDesStatistiques.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement des statistiques.\n{value1}'**
  String erreurLorsDuChargementDesStatistiques(String value1);

  /// No description provided for @erreurLorsDuCalculDesStatistiques.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du calcul des statistiques'**
  String get erreurLorsDuCalculDesStatistiques;

  /// No description provided for @competitionsLesPlusSuivies.
  ///
  /// In fr, this message translates to:
  /// **'Compétitions les plus suivies'**
  String get competitionsLesPlusSuivies;

  /// No description provided for @aucuneCompetition.
  ///
  /// In fr, this message translates to:
  /// **'Aucune compétition'**
  String get aucuneCompetition;

  /// No description provided for @competitionsDifferentesVues.
  ///
  /// In fr, this message translates to:
  /// **'Compétitions différentes vues'**
  String get competitionsDifferentesVues;

  /// No description provided for @butsParCompetition.
  ///
  /// In fr, this message translates to:
  /// **'Buts par compétition'**
  String get butsParCompetition;

  /// No description provided for @aucuneDonnee.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée'**
  String get aucuneDonnee;

  /// No description provided for @moyButsMatch.
  ///
  /// In fr, this message translates to:
  /// **'Moy. buts / match'**
  String get moyButsMatch;

  /// No description provided for @repartitionParCompetition.
  ///
  /// In fr, this message translates to:
  /// **'Répartition par compétition'**
  String get repartitionParCompetition;

  /// No description provided for @typesDeCompetitions.
  ///
  /// In fr, this message translates to:
  /// **'Types de compétitions'**
  String get typesDeCompetitions;

  /// No description provided for @equipesDifferentesVues.
  ///
  /// In fr, this message translates to:
  /// **'Équipes différentes vues'**
  String get equipesDifferentesVues;

  /// No description provided for @equipesLesPlusVues.
  ///
  /// In fr, this message translates to:
  /// **'Équipes les plus vues'**
  String get equipesLesPlusVues;

  /// No description provided for @aucuneEquipe.
  ///
  /// In fr, this message translates to:
  /// **'Aucune équipe'**
  String get aucuneEquipe;

  /// No description provided for @equipesLesPlusVuesGagner.
  ///
  /// In fr, this message translates to:
  /// **'Équipes les plus vues gagner'**
  String get equipesLesPlusVuesGagner;

  /// No description provided for @equipesLesPlusVuesPerdre.
  ///
  /// In fr, this message translates to:
  /// **'Équipes les plus vues perdre'**
  String get equipesLesPlusVuesPerdre;

  /// No description provided for @pourcentageDeVictoiresMin3MatchsVus.
  ///
  /// In fr, this message translates to:
  /// **'Pourcentage de victoires (min. 3 matchs vus)'**
  String get pourcentageDeVictoiresMin3MatchsVus;

  /// No description provided for @pourcentageVictoires.
  ///
  /// In fr, this message translates to:
  /// **'% Victoires'**
  String get pourcentageVictoires;

  /// No description provided for @butsVus.
  ///
  /// In fr, this message translates to:
  /// **'Buts vus'**
  String get butsVus;

  /// No description provided for @joueursLesPlusVusMarquer.
  ///
  /// In fr, this message translates to:
  /// **'Joueurs les plus vus marquer'**
  String get joueursLesPlusVusMarquer;

  /// No description provided for @aucunButeur.
  ///
  /// In fr, this message translates to:
  /// **'Aucun buteur'**
  String get aucunButeur;

  /// No description provided for @buteursDifferents.
  ///
  /// In fr, this message translates to:
  /// **'Buteurs différents'**
  String get buteursDifferents;

  /// No description provided for @moyDesNotesDonnees.
  ///
  /// In fr, this message translates to:
  /// **'Moy. des notes données'**
  String get moyDesNotesDonnees;

  /// No description provided for @mvpLesPlusVotes.
  ///
  /// In fr, this message translates to:
  /// **'MVP les plus votés'**
  String get mvpLesPlusVotes;

  /// No description provided for @aucunMvp.
  ///
  /// In fr, this message translates to:
  /// **'Aucun MVP'**
  String get aucunMvp;

  /// No description provided for @matchsLesMieuxNotes.
  ///
  /// In fr, this message translates to:
  /// **'Matchs les mieux notés'**
  String get matchsLesMieuxNotes;

  /// No description provided for @aucunMatch.
  ///
  /// In fr, this message translates to:
  /// **'Aucun match'**
  String get aucunMatch;

  /// No description provided for @matchsLesCommentes.
  ///
  /// In fr, this message translates to:
  /// **'Matchs les + commentés'**
  String get matchsLesCommentes;

  /// No description provided for @matchsLesReactions.
  ///
  /// In fr, this message translates to:
  /// **'Matchs les + réactions'**
  String get matchsLesReactions;

  /// No description provided for @joursAvecLePlusDeMatchsVus.
  ///
  /// In fr, this message translates to:
  /// **'Jours avec le plus de matchs vus'**
  String get joursAvecLePlusDeMatchsVus;

  /// No description provided for @typesDeVisionnage.
  ///
  /// In fr, this message translates to:
  /// **'Types de visionnage'**
  String get typesDeVisionnage;

  /// No description provided for @nombreDeMatchsVusParMois.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de matchs vus par mois'**
  String get nombreDeMatchsVusParMois;

  /// No description provided for @buteursLesPlusVus.
  ///
  /// In fr, this message translates to:
  /// **'Buteurs les plus vus'**
  String get buteursLesPlusVus;

  /// No description provided for @aucunJoueur.
  ///
  /// In fr, this message translates to:
  /// **'Aucun joueur'**
  String get aucunJoueur;

  /// No description provided for @passesDecisives.
  ///
  /// In fr, this message translates to:
  /// **'Passes décisives'**
  String get passesDecisives;

  /// No description provided for @gA.
  ///
  /// In fr, this message translates to:
  /// **'G+A'**
  String get gA;

  /// No description provided for @titularisations.
  ///
  /// In fr, this message translates to:
  /// **'Titularisations'**
  String get titularisations;

  /// No description provided for @recordDeButsSurUnMatch.
  ///
  /// In fr, this message translates to:
  /// **'Record de buts sur un match'**
  String get recordDeButsSurUnMatch;

  /// No description provided for @nombreDeButsVotesMvp.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de buts / votes MVP'**
  String get nombreDeButsVotesMvp;

  /// No description provided for @plusGrosScore.
  ///
  /// In fr, this message translates to:
  /// **'Plus gros score'**
  String get plusGrosScore;

  /// No description provided for @plusGrosEcart.
  ///
  /// In fr, this message translates to:
  /// **'Plus gros écart'**
  String get plusGrosEcart;

  /// No description provided for @moyenneDifferenceButsMatch.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne différence buts / match'**
  String get moyenneDifferenceButsMatch;

  /// No description provided for @resultatsDomicileNulExterieur.
  ///
  /// In fr, this message translates to:
  /// **'Résultats (domicile / nul / extérieur)'**
  String get resultatsDomicileNulExterieur;

  /// No description provided for @clubsVsInternationaux.
  ///
  /// In fr, this message translates to:
  /// **'Clubs vs Internationaux'**
  String get clubsVsInternationaux;

  /// No description provided for @supprimerLeCommentaire.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le commentaire'**
  String get supprimerLeCommentaire;

  /// No description provided for @voulezVousSupprimerVotreCommentaire.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous supprimer votre commentaire ?'**
  String get voulezVousSupprimerVotreCommentaire;

  /// No description provided for @monCommentaire.
  ///
  /// In fr, this message translates to:
  /// **'Mon commentaire'**
  String get monCommentaire;

  /// No description provided for @ajouterUnCommentaire.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un commentaire'**
  String get ajouterUnCommentaire;

  /// No description provided for @publier.
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get publier;

  /// No description provided for @commenter.
  ///
  /// In fr, this message translates to:
  /// **'Commenter'**
  String get commenter;

  /// No description provided for @quAstuPenseDeCeMatch.
  ///
  /// In fr, this message translates to:
  /// **'Qu\'as-tu pensé de ce match ?'**
  String get quAstuPenseDeCeMatch;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
