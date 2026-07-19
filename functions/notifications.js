const admin = require("firebase-admin");
const functions = require("firebase-functions");

const NOTIF_TYPES = {
  FRIEND_REQUEST: "friendRequest",
  FRIEND_REQUEST_ACCEPTED: "friendRequestAccepted",
  WATCH_TOGETHER_INVITED: "watchTogetherInvited",
  REACTION: "reaction",
  COMMENT: "comment",
  FAVORITE_TEAM_MATCH_END: "favoriteTeamMatch",
  WEEKLY_RECAP: "weeklyRecap",
  CDM_RECAP: "cdmRecap",
  SEASON_RECAP: "seasonRecap",
};

function buildNotificationContent(type, payload) {
  switch (type) {
    case NOTIF_TYPES.FRIEND_REQUEST:
      return {
        title: "Nouvelle demande d'ami",
        body: `${payload.fromUserName} vous a envoyé une demande d'ami`,
      };
    case NOTIF_TYPES.FRIEND_REQUEST_ACCEPTED:
      return {
        title: "Demande acceptée",
        body: `${payload.fromUserName} a accepté ta demande d'ami`,
      };
    case NOTIF_TYPES.WATCH_TOGETHER_INVITED:
      return {
        title: "Invitation à regarder ensemble",
        body: `${payload.fromUserName} t'invite ` +
        `à regarder ${payload.matchName} ensemble`,
      };
    case NOTIF_TYPES.REACTION:
      return {
        title: "Nouvelle réaction",
        body:
        `${payload.fromUserName} a réagi à ton match ${payload.matchName}`,
      };
    case NOTIF_TYPES.COMMENT:
      return {
        title: "Nouveau commentaire",
        body:
        `${payload.fromUserName} a commenté ton match ${payload.matchName}`,
      };
    case NOTIF_TYPES.FAVORITE_TEAM_MATCH_END:
      return {
        title: "Match terminé !",
        body:
          `${payload.matchName} est terminé ! ` +
          `Viens donner ta note et voter pour le meilleur joueur !`,
      };
    case NOTIF_TYPES.WEEKLY_RECAP:
      return {
        title: "Ton récap de la semaine est disponible 📊",
        body: `Viens découvrir tes statistiques de visionnage de la semaine !`,
      };
    case NOTIF_TYPES.CDM_RECAP:
      return {
        title: "🏆 Le récap de ta Coupe du Monde est disponible !",
        body: "Ça y est, la Coupe du Monde est terminée. " +
        "Découvre le récap de la CdM 2026 avec ScoreScope !",
      };
    case NOTIF_TYPES.SEASON_RECAP:
      return {
        title: "🏆 Le récap de ta saison est disponible !",
        body: "La saison est terminée. " +
        "Découvre le récap de la saison 2026 avec ScoreScope !",
      };
    default:
      return null;
  }
}

async function sendNotificationToUser(toUserId, type, payload) {
  const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(toUserId)
      .get();

  if (!userDoc.exists) return;
  const userData = userDoc.data();

  const options = userData.options ?? {};
  if (options.allNotifications === false) return;
  if (options[type] === false) return;

  const notificationToken = userData.notificationToken;
  if (!notificationToken) return;

  const content = buildNotificationContent(type, payload);
  if (!content) return;

  try {
    await admin.messaging().send({
      token: notificationToken,
      notification: {
        title: content.title,
        body: content.body,
      },
      data: {
        type: type,
        ...Object.fromEntries(
            Object.entries(payload).map(([k, v]) => [k, String(v)]),
        ),
      },
    });
  } catch (error) {
    if (
      error.errorInfo?.code === "messaging/registration-token-not-registered" ||
      error.errorInfo?.code === "messaging/invalid-registration-token"
    ) {
      console.warn(`🧹 Token invalide pour ${toUserId}, suppression...`);
      await admin.firestore().collection("users").doc(toUserId).update({
        notificationToken: admin.firestore.FieldValue.delete(),
      });
    } else {
      throw error;
    }
  }
}

exports.sendNotification = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Non authentifié");
  }

  const {toUserId, type, payload} = request.data;

  if (!Object.values(NOTIF_TYPES).includes(type)) {
    throw new functions.https.HttpsError("invalid-argument", "Type invalide");
  }

  await sendNotificationToUser(toUserId, type, payload);
  return {success: true};
});

module.exports.sendNotificationToUser = sendNotificationToUser;
module.exports.NOTIF_TYPES = NOTIF_TYPES;
