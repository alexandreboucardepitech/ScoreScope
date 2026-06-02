import 'package:scorescope/utils/translate/language_controller.dart';

String getFriendshipActionSnackbarMessage(String action) {
  switch (action) {
    case 'send':
      return translate.demandeDAmiEnvoyeeAvecSucces;
    case 'cancel':
      return translate.demandeDAmiAnnuleeAvecSucces;
    case 'accept':
      return translate.demandeAcceptee;
    case 'remove':
      return translate.amiRetireAvecSucces;
    case 'block':
      return translate.utilisateurBloqueAvecSucces;
    case 'unblock':
      return translate.utilisateurDebloqueAvecSucces;
    default:
      return translate.actionEffectueeAvecSucces;
  }
}
