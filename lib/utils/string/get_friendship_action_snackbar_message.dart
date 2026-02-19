String getFriendshipActionSnackbarMessage(String action) {
  switch (action) {
    case 'send':
      return "Demande d'ami envoyée avec succès!";
    case 'cancel':
      return "Demande d'ami annulée avec succès!";
    case 'accept':
      return "Demande acceptée !";
    case 'remove':
      return "Ami retiré avec succès!";
    case 'block':
      return "Utilisateur bloqué avec succès!";
    case 'unblock':
      return "Utilisateur débloqué avec succès!";
    default:
      return "Action effectuée avec succès!";
  }
}
