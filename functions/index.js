const {setGlobalOptions} = require("firebase-functions/v2");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const fetch = require("node-fetch");
const {onRequest} = require("firebase-functions/v2/https");
const {
  sendNotification,
  sendNotificationToUser,
  NOTIF_TYPES,
} = require("./notifications");

exports.sendNotification = sendNotification;

admin.initializeApp();
setGlobalOptions({maxInstances: 10});
const db = admin.firestore();
const API_FOOTBALL_TOKEN = process.env.API_FOOTBALL_TOKEN;

exports.getFootballData = onRequest(async (req, res) => {
  const {endpoint, params} = req.body;

  const data = await getDataFromApi(endpoint, params);

  res.json({response: data});
});

// exports.sendTestNotification = onSchedule(
//     {
//       schedule: "* * * * *",
//       timeZone: "Europe/Paris",
//     },
//     async () => {
//       const message = {
//         notification: {
//           title: "Match terminé !",
//           body: `Le match TEST TEST est terminé` +
//                   ` ! Viens vite donner ta note et ` +
//                   `voter pour le meilleur joueur !`,
//         },
//         data: {
//           type: "result",
//           matchId: "1419344",
//         },
//         token: "dFtZjtZRTSilkTZR2g8Ytg:APA91bFZE_U7_BHHExwm2Po7e" +
//                   "PGZnDUVAqsaNSvxOJjmx3iBHP5NnNmDt6B1OBx5NT4h0ikn7nDMu22_s"+
//                   "Uyd0W2I4AtKysS2TLiezCs9YVLGM5h4SjXvKXk",
//       };
//       try {
//         const response = await admin.messaging().send(message);
//         console.log(`Notif envoyée à alex: `, response);
//       } catch (error) {
//         console.error("Erreur : ", error);
//       }

//       return null;
//     });

async function getTeamColors(teamId, season) {
  const cinqDerniersMatchs = await getDataFromApi("fixtures", {
    team: teamId,
    season: season,
    last: "5",
  });

  if (!cinqDerniersMatchs || cinqDerniersMatchs.length === 0) {
    console.log(`⚠️ Pas de matchs pour les couleurs de l'équipe ${teamId}`);
    return {principale: null, secondaire: null};
  }

  const couleursPrincipale = {};
  const couleursSecondaire = {};

  for (const match of cinqDerniersMatchs) {
    const matchId = match.fixture.id.toString();
    const lineup = await getDataFromApi("fixtures/lineups", {
      team: teamId,
      fixture: matchId,
    });

    if (!lineup || lineup.length === 0) continue;

    const primary = lineup[0]?.team?.colors?.player?.primary || null;
    const secondary = lineup[0]?.team?.colors?.player?.number || null;

    if (primary) {
      couleursPrincipale[primary] = (couleursPrincipale[primary] || 0) + 1;
    }
    if (secondary) {
      couleursSecondaire[secondary] = (couleursSecondaire[secondary] || 0) + 1;
    }
  }

  const principale =
    Object.keys(couleursPrincipale).length > 0 ?
      Object.entries(couleursPrincipale).reduce((a, b) =>
          a[1] > b[1] ? a : b,
      )[0] :
      null;

  const secondaire =
    Object.keys(couleursSecondaire).length > 0 ?
      Object.entries(couleursSecondaire).reduce((a, b) =>
          a[1] > b[1] ? a : b,
      )[0] :
      null;

  return {principale, secondaire};
}

async function ensureEquipeExists(teamId, season) {
  const doc = await db.collection("equipes").doc(teamId).get();
  if (doc.exists) return true;

  console.log(`🔍 Équipe ${teamId} absente, création en cours...`);

  const apiData = await getDataFromApi("teams", {id: teamId});
  if (!apiData || apiData.length === 0) {
    console.log(`❌ Équipe ${teamId} introuvable via l'API, match ignoré`);
    return false;
  }

  const team = apiData[0].team;
  const couleurs = await getTeamColors(teamId, season.toString());

  await db
      .collection("equipes")
      .doc(teamId)
      .set({
        id: teamId,
        nom: team.name || "",
        code: team.code || "",
        logoPath: team.logo || "",
        couleurPrincipale: couleurs.principale,
        couleurSecondaire: couleurs.secondaire,
        national: team.national ?? false,
      });

  console.log(`✅ Équipe créée : ${team.name} (${teamId})`);
  return true;
}

// Fonction pour appeler l'API football
async function getDataFromApi(endpoint, params = {}) {
  const stringParams = Object.keys(params).length ?
    "?" +
      Object.entries(params)
          .map(([k, v]) => `${k}=${v}`)
          .join("&") :
    "";

  const url = `https://v3.football.api-sports.io/${endpoint}${stringParams}`;

  const response = await fetch(url, {
    headers: {
      "X-RapidAPI-Key": API_FOOTBALL_TOKEN || "",
      "X-RapidAPI-Host": "v3.football.api-sports.io",
    },
  });

  if (!response.ok) {
    throw new Error(`Erreur API : ${response.status} ${response.statusText}`);
  }

  const jsonData = await response.json();

  if (jsonData?.errors && Object.keys(jsonData.errors).length > 0) {
    if (jsonData.errors.rateLimit) {
      // console.log("Rate limit hit, retrying in 1 min");
      // await new Promise((res) => setTimeout(res, 60 * 1000));
      // return getDataFromApi(endpoint, params);
      // on ignore car ça va être relancé dans 1min automatiquement
    }
  }

  return jsonData.response || [];
}

function getStatusFromCode(code) {
  switch (code) {
    case "FT":
    case "AET":
    case "PEN":
      return "finished"; // MatchStatus.finished
    case "HT":
      return "halftime"; // MatchStatus.halftime
    case "1H":
    case "2H":
    case "ET":
    case "BT":
    case "P":
    case "SUSP":
    case "INT":
    case "LIVE":
      return "live"; // MatchStatus.live
    case "PST":
      return "postponed"; // MatchStatus.postponed
    case "CANC":
    case "ABD":
    case "AWD":
    case "WO":
      return "cancelled"; // jamais stocké en base → suppression
    case "NS":
    case "TBD":
    default:
      return "scheduled"; // MatchStatus.scheduled
  }
}

async function checkMustCallApi() {
  const todayStart = new Date();
  todayStart.setHours(0, 0, 0, 0);

  const todayEnd = new Date();
  todayEnd.setHours(23, 59, 59, 999);

  const snapshot = await db
      .collection("matchs")
      .where("date", ">=", todayStart)
      .where("date", "<=", todayEnd)
      .get();
  const now = new Date();

  const hasRelevantMatch = snapshot.docs.some((doc) => {
    const data = doc.data();

    const matchTime = data.date.toDate();
    const diffMinutes = (now - matchTime) / 60000;

    return (
      data.status !== "finished" &&
      diffMinutes >= -45 && // 45 min avant
      diffMinutes <= 180 // 3h après
    );
  });
  return hasRelevantMatch;
}

// Récupérer les matchs des 2 prochaines semaines tous les jours à minuit
exports.fetchNextTwoWeeksMatches = onSchedule(
    {
      schedule: "1 0 * * *",
      timeZone: "Europe/Paris",
    },
    async () => {
      console.log("Récupération des matchs des 2 prochaines semaines...");

      try {
      // Récupérer toutes les compétitions depuis Firestore
        const competitionsSnap = await db.collection("competitions").get();
        const competitions = competitionsSnap.docs.map((doc) => doc.id);

        const seasons = [2025, 2026];

        const today = Math.floor(Date.now() / 1000);
        const twoWeeksLater = today + 14 * 24 * 60 * 60;
        for (const comp of competitions) {
          console.log(comp);
        }

        for (const season of seasons) {
          for (const leagueId of competitions) {
            const data = await getDataFromApi("fixtures", {
              league: leagueId,
              from: new Date(today * 1000).toISOString().split("T")[0],
              to: new Date(twoWeeksLater * 1000).toISOString().split("T")[0],
              season: season,
            });

            console.log(
                data.length + " matchs récupérés pour compétition " + leagueId,
            );

            for (const matchData of data) {
              const id = matchData.fixture.id.toString();
              const matchDocRef = db.collection("matchs").doc(id);

              const matchDoc = await matchDocRef.get();

              const apiDate = new Date(matchData.fixture.timestamp * 1000);

              const homeId = matchData.teams.home.id.toString();
              const awayId = matchData.teams.away.id.toString();

              // On s'assure que les deux équipes existent (les crée si besoin)
              const [homeOk, awayOk] = await Promise.all([
                ensureEquipeExists(homeId, matchData.league.season),
                ensureEquipeExists(awayId, matchData.league.season),
              ]);

              if (!homeOk || !awayOk) {
                console.log(`⚠️ Match ${id} ignoré (équipe manquante)`);
                continue;
              }

              const apiStatus = getStatusFromCode(
                  matchData.fixture.status.short);

              // Match annulé/abandonné → on supprime s'il existait et on passe
              if (apiStatus === "cancelled" || apiStatus === "postponed") {
                if (matchDoc.exists) {
                  await matchDocRef.delete();
                  console.log(`🗑️ Match ${id} supprimé ` +
                    `(${matchData.fixture.status.short})`);
                }
                continue;
              }

              let shouldUpdate = !matchDoc.exists;

              if (matchDoc.exists) {
                const dbDate = matchDoc.data().date.toDate();

                shouldUpdate = apiDate.getTime() !== dbDate.getTime();
              }

              if (shouldUpdate) {
              // On récupère toutes les infos disponibles

                let prolongations = false;

                if (matchData.fixture?.status?.short == "AET") {
                  prolongations = true;
                }

                const matchObj = {
                  id,
                  status: getStatusFromCode(matchData.fixture.status.short),
                  liveMinute: matchData.fixture.status.elapsed || null,
                  extraTime: matchData.fixture.status.extra || null,
                  saison: matchData.league?.season || null,
                  competitionId: leagueId,
                  equipeDomicileId: matchData.teams.home.id.toString(),
                  equipeExterieurId: matchData.teams.away.id.toString(),
                  date: apiDate,
                  refereeName: matchData.fixture.referee || null,
                  stadiumName: matchData.fixture.venue?.name || null,
                  scoreEquipeDomicile: matchData.goals.home ?? 0,
                  scoreEquipeExterieur: matchData.goals.away ?? 0,
                  penaltyEquipeDomicile: matchData.score?.penalty?.home ?? 0,
                  penaltyEquipeExterieur: matchData.score?.penalty?.away ?? 0,
                  prolongations: prolongations,
                  butsEquipeDomicile: [],
                  butsEquipeExterieur: [],
                  joueursEquipeDomicile: [],
                  joueursEquipeExterieur: [],
                  mvpVotes: {},
                  notes: {},
                };

                await matchDocRef.set(matchObj);

                console.log(
                shouldUpdate && matchDoc.exists ?
                  "Match mis à jour :" :
                  "Match ajouté :",
                id,
                " compétition : ",
                leagueId,
                );
              }
            }
          }
        }

        console.log("Récupération terminée ✅");
      } catch (err) {
        console.error("Erreur fetchNextTwoWeeksMatches :", err);
      }
    },
);

exports.fetchLineups = onSchedule(
    {
      schedule: "*/5 * * * *",
      timeZone: "Europe/Paris",
    },
    async () => {
      console.log("⏳ Vérification des lineups...");

      const now = new Date();
      const minTime = new Date(now.getTime() - 2 * 3600 * 1000);
      const maxTime = new Date(now.getTime() + 45 * 60 * 1000);

      try {
      // 🔹 1. Récupérer les matchs dans la fenêtre
        const snapshot = await db
            .collection("matchs")
            .where("date", ">=", minTime)
            .where("date", "<=", maxTime)
            .get();

        const matchs = snapshot.docs.filter((doc) => {
          const data = doc.data();

          const noHomePlayers =
          !data.joueursEquipeDomicile ||
          data.joueursEquipeDomicile.length === 0;

          const noAwayPlayers =
          !data.joueursEquipeExterieur ||
          data.joueursEquipeExterieur.length === 0;

          return noHomePlayers && noAwayPlayers;
        });

        console.log("Matchs à traiter :", matchs.length);

        for (const doc of matchs) {
          const matchId = doc.id;

          try {
            console.log("🔎 Match :", matchId);

            const lineup = await getDataFromApi("fixtures/lineups", {
              fixture: matchId,
            });

            if (!lineup || lineup.length < 2) {
              console.log("❌ Pas encore de lineup pour", matchId);
              continue;
            }

            const equipeDom = lineup[0];
            const equipeExt = lineup[1];

            const data = doc.data();

            const teamIdDom = data.equipeDomicileId;
            const teamIdExt = data.equipeExterieurId;

            const [teamDomDoc, teamExtDoc] = await Promise.all([
              db.collection("equipes").doc(teamIdDom).get(),
              db.collection("equipes").doc(teamIdExt).get(),
            ]);

            const teamDomData = teamDomDoc.data();
            const teamExtData = teamExtDoc.data();

            const isNationalDom = teamDomData?.national === true;
            const isNationalExt = teamExtData?.national === true;

            const mapPlayer = (playerObj, isFromStartXI = true) => {
              if (!playerObj?.player?.id) return null;

              return {
                joueurId: playerObj.player.id.toString(),
                number: playerObj.player.number || null,
                pos: playerObj.player.pos || null,
                grid: playerObj.player.grid || null,
                hasPlayed: isFromStartXI,
                isStarter: isFromStartXI,
              };
            };

            const joueursDom = [
              ...(equipeDom.startXI || []).map((p) => mapPlayer(p, true)),
              ...(equipeDom.substitutes || []).map((p) => mapPlayer(p, false)),
            ].filter(Boolean);

            const joueursExt = [
              ...(equipeExt.startXI || []).map((p) => mapPlayer(p, true)),
              ...(equipeExt.substitutes || []).map((p) => mapPlayer(p, false)),
            ].filter(Boolean);

            if (joueursDom.length === 0 || joueursExt.length === 0) {
              console.log("⚠️ Lineup vide pour", matchId);
              continue;
            }

            console.log("✅ Lineup trouvé pour", matchId);

            const allPlayers = [
              ...joueursDom.map((j) => ({
                id: j.joueurId,
                equipeId: teamIdDom,
                isNational: isNationalDom,
              })),
              ...joueursExt.map((j) => ({
                id: j.joueurId,
                equipeId: teamIdExt,
                isNational: isNationalExt,
              })),
            ];

            const uniquePlayers = [
              ...new Map(allPlayers.map((p) => [p.id, p])).values(),
            ];

            const playerDocs = await Promise.all(
                uniquePlayers.map((p) =>
                  db.collection("joueurs").doc(p.id).get(),
                ),
            );

            const existingIds = new Set(
                playerDocs
                    .filter((doc) => doc.exists)
                    .map((doc) => doc.id),
            );

            const batch = db.batch();
            let hasUpdates = false;

            for (let i = 0; i < uniquePlayers.length; i++) {
              const playerInfo = uniquePlayers[i];
              const playerDoc = playerDocs[i];

              if (!playerDoc.exists) continue;

              const joueurData = playerDoc.data();

              const updates = {};

              if (playerInfo.isNational) {
                const currentNationalId =
                  joueurData?.equipeNationaleId?.toString();

                const currentEquipeId =
                  joueurData?.equipeId?.toString();

                const newNationalId =
                  playerInfo.equipeId?.toString();

                if (
                  newNationalId &&
                  currentNationalId !== newNationalId
                ) {
                  updates.equipeNationaleId = newNationalId;

                  console.log(
                      `🌍 Joueur ${playerInfo.id} : sélection mise à jour ` +
                    `${currentNationalId} → ${newNationalId}`,
                  );
                }

                // 🔹 Fallback obligatoire si equipeId absent
                if (newNationalId && currentEquipeId !== newNationalId) {
                  updates.equipeId = newNationalId;
                  console.log(
                      `Joueur ${playerInfo.id} : fallback → ${newNationalId}`,
                  );
                }
              } else {
                const currentClubId =
                joueurData?.equipeId?.toString();

                const newClubId =
                playerInfo.equipeId?.toString();

                if (
                  newClubId &&
                currentClubId !== newClubId
                ) {
                  updates.equipeId = newClubId;

                  console.log(
                      `🏟️ Joueur ${playerInfo.id} : club mis à jour ` +
                  `${currentClubId} → ${newClubId}`,
                  );
                }
              }

              if (Object.keys(updates).length > 0) {
                batch.update(
                    db.collection("joueurs").doc(playerInfo.id),
                    updates,
                );

                hasUpdates = true;
              }
            }

            if (hasUpdates) {
              await batch.commit();
              console.log("🔄 Équipes joueurs mises à jour");
            }

            // 🔹 Joueurs à créer
            const playersToCreate = uniquePlayers.filter(
                (p) => !existingIds.has(p.id),
            );

            console.log("👤 Joueurs à créer :", playersToCreate.length);

            for (const playerInfo of playersToCreate) {
              try {
                const joueurId = playerInfo.id;
                const equipeId = playerInfo.equipeId;
                const isNational = playerInfo.isNational;

                const apiData = await getDataFromApi(
                    "players/profiles",
                    {
                      player: joueurId,
                    },
                );

                if (!apiData || apiData.length === 0) continue;

                const player = apiData[0]?.player;
                if (!player) continue;

                const joueurObj = {
                  id: joueurId,
                  prenom: player.firstname || "",
                  nom: player.lastname || "",
                  fullName: (player.name || "").replaceAll("&apos;", "'"),
                  equipeId: equipeId,
                  equipeNationaleId: isNational ? equipeId : null,
                  dateNaissance: player.birth?.date || null,
                  nationalite: player.nationality || null,
                  picture: player.photo || null,
                };

                await db.collection("joueurs").doc(joueurId).set(joueurObj);

                console.log("👤 Joueur créé :", joueurId);
              } catch (err) {
                console.error("🔥 Erreur création joueur :", playerInfo.id, err);
              }
            }

            // 🔹 Mise à jour du match
            await db.collection("matchs").doc(matchId).update({
              joueursEquipeDomicile: joueursDom,
              joueursEquipeExterieur: joueursExt,
            });

            console.log("💾 Match mis à jour :", matchId);
          } catch (error) {
            console.error("🔥 Erreur pour match", matchId, error);
          }
        }

        console.log("✅ Vérification terminée");
      } catch (error) {
        console.error("🔥 Erreur globale :", error);
      }
    },
);

exports.updateLiveMatches = onSchedule(
    {
      schedule: "* * * * *",
      timeZone: "Europe/Paris",
    },
    async () => {
      console.log("⚡ Mise à jour des matchs en live...");

      try {
        let nbMatchsUpdated = 0;
        const mustCallApi = await checkMustCallApi();
        if (mustCallApi == true) {
          console.log("Il faut appeler l'API");
          const live = await getDataFromApi("fixtures", {
            live:
            "1-10-135-137-140-143-2-3-39-4-45-48-" +
            "526-528-529-547-556-61-62-66-78-81-848",
          });

          const liveIds = live.map((m) => m.fixture.id.toString());

          console.log("Matchs live API :", live.length);

          for (const matchData of live) {
            const matchId = matchData.fixture.id.toString();

            try {
              const docRef = db.collection("matchs").doc(matchId);
              const doc = await docRef.get();

              if (!doc.exists) continue;

              const data = doc.data();

              const newScoreHome = matchData.goals.home ?? 0;
              const newScoreAway = matchData.goals.away ?? 0;

              const newPenaltyHome = matchData.score?.penalty?.home ?? 0;
              const newPenaltyAway = matchData.score?.penalty?.away ?? 0;

              const newProlongations =
                matchData.fixture?.status?.short == "AET" ||
                data.liveMinute > 90;

              const newStatus = getStatusFromCode(
                  matchData.fixture.status.short,
              );
              const newMinute = matchData.fixture.status.elapsed ?? null;
              const newExtra = matchData.fixture.status.extra ?? null;

              const hasScoreChanged =
              data.scoreEquipeDomicile !== newScoreHome ||
              data.scoreEquipeExterieur !== newScoreAway ||
              data.penaltyEquipeDomicile !== newPenaltyHome ||
              data.penaltyEquipeExterieur !== newPenaltyAway;

              const hasStatusChanged = data.status !== newStatus;
              const hasMinuteChanged = data.liveMinute !== newMinute;

              nbMatchsUpdated++;

              if (
                hasScoreChanged ||
              hasStatusChanged ||
              data.butsEquipeDomicile.length != data.scoreEquipeDomicile ||
              data.butsEquipeExterieur.length != data.scoreEquipeExterieur
              ) {
                console.log("🔄 Update match :", matchId);

                let butsEquipeDomicile = data.butsEquipeDomicile || [];
                let butsEquipeExterieur = data.butsEquipeExterieur || [];
                let joueursDomicile = data.joueursEquipeDomicile || [];
                let joueursExterieur = data.joueursEquipeExterieur || [];

                const events = await getDataFromApi("fixtures/events", {
                  fixture: matchId,
                });

                if (events && events.length > 0) {
                  butsEquipeDomicile = [];
                  butsEquipeExterieur = [];

                  const mapDomicile = Object.fromEntries(
                      joueursDomicile.map((j) => [j.joueurId, j]),
                  );

                  const mapExterieur = Object.fromEntries(
                      joueursExterieur.map((j) => [j.joueurId, j]),
                  );

                  for (const event of events) {
                    if (event.comments === "Penalty Shootout") continue;

                    const eventType = event.type;

                    if (eventType === "subst") {
                      const joueurEntrantId = event.assist?.id?.toString();
                      if (!joueurEntrantId) continue;

                      if (mapDomicile[joueurEntrantId]) {
                        mapDomicile[joueurEntrantId].hasPlayed = true;
                      } else if (mapExterieur[joueurEntrantId]) {
                        mapExterieur[joueurEntrantId].hasPlayed = true;
                      }
                    }

                    if (eventType === "Var") {
                      const detail = event.detail || "";

                      if (detail.includes("Goal Disallowed")) {
                        const playerId = event.player?.id?.toString();
                        const teamId = event.team?.id?.toString();
                        const minute = event.time?.elapsed?.toString();

                        if (!playerId || !teamId) continue;

                        console.log("🚫 But annulé (VAR) :", playerId);

                        const butVar = (goalsArray) => {
                          return goalsArray.filter((goal) => {
                            if (goal.buteurId !== playerId) return true;

                            if (goal.minute === minute) {
                              console.log("🚫 But annulé (VAR) :", playerId);
                              return false;
                            }
                            return true;
                          });
                        };

                        if (teamId === data.equipeDomicileId) {
                          butsEquipeDomicile = butVar(butsEquipeDomicile);
                        } else if (teamId === data.equipeExterieurId) {
                          butsEquipeExterieur = butVar(butsEquipeExterieur);
                        }
                      }
                    }

                    if (eventType === "Goal") {
                      const buteurId = event.player?.id?.toString();
                      const passeurId = event.assist?.id?.toString() || null;
                      let minute = event.time?.elapsed?.toString();
                      const extra = event.time?.extra?.toString();
                      const teamId = event.team?.id?.toString();

                      if (!buteurId || !minute || !teamId) continue;

                      if (extra != null && extra !== "") {
                        minute = minute + "+" + extra.toString();
                      }

                      let typeBut = "normal";
                      let missed = false;

                      switch (event.detail) {
                        case "Normal Goal":
                          typeBut = "normal";
                          break;
                        case "Own Goal":
                          typeBut = "owngoal";
                          break;
                        case "Penalty":
                          typeBut = "penalty";
                          break;
                        case "Missed Penalty":
                          missed = true;
                          break;
                      }

                      if (missed) continue;

                      const but = {
                        buteurId,
                        minute,
                        passeurId,
                        typeBut,
                      };

                      if (teamId === data.equipeDomicileId) {
                        butsEquipeDomicile.push(but);
                      } else if (teamId === data.equipeExterieurId) {
                        butsEquipeExterieur.push(but);
                      }
                    }
                  }

                  joueursDomicile = Object.values(mapDomicile);
                  joueursExterieur = Object.values(mapExterieur);
                }

                const newDate = matchData.fixture?.timestamp ?
                new Date(matchData.fixture.timestamp * 1000) :
                data.date;

                await docRef.update({
                  date: newDate,
                  scoreEquipeDomicile: newScoreHome,
                  scoreEquipeExterieur: newScoreAway,
                  penaltyEquipeDomicile: newPenaltyHome,
                  penaltyEquipeExterieur: newPenaltyAway,
                  prolongations: newProlongations,
                  status: newStatus,
                  liveMinute: newMinute,
                  extraTime: newExtra,
                  butsEquipeDomicile: butsEquipeDomicile,
                  butsEquipeExterieur: butsEquipeExterieur,
                  joueursEquipeDomicile: joueursDomicile,
                  joueursEquipeExterieur: joueursExterieur,
                });

                console.log("✅ Match mis à jour :", matchId);
              } else if (hasMinuteChanged) {
                await docRef.update({
                  liveMinute: newMinute,
                  extraTime: newExtra,
                });
              }
            } catch (error) {
              console.error("🔥 Erreur match :", matchId, error);
            }
          }

          const threeHoursAgo = new Date(Date.now() - 3 * 60 * 60 * 1000);

          const now = new Date();

          const snapshot = await db
              .collection("matchs")
              .where("date", ">=", threeHoursAgo)
              .where("date", "<=", now)
              .get();

          for (const doc of snapshot.docs) {
            const data = doc.data();
            const matchId = doc.id;

            if (data.status === "finished") continue;

            if (liveIds.includes(matchId)) continue;

            try {
              const result = await getDataFromApi("fixtures", {
                id: matchId,
              });

              if (!result || result.length === 0) continue;

              const matchData = result[0];

              const finalStatus = getStatusFromCode(
                  matchData.fixture.status.short,
              );

              // si toujours pas fini → skip (sécurité API)
              if (finalStatus !== "finished") continue;

              console.log("🏁 Match terminé :", matchId);

              // 🔹 Récupérer les events COMPLETS une dernière fois
              const events = await getDataFromApi("fixtures/events", {
                fixture: matchId,
              });

              // 🔹 Repartir des données existantes
              const butsEquipeDomicile = [];
              const butsEquipeExterieur = [];

              const joueursDomicile = data.joueursEquipeDomicile || [];
              const joueursExterieur = data.joueursEquipeExterieur || [];

              // map joueurs pour update hasPlayed
              const mapDomicile = Object.fromEntries(
                  joueursDomicile.map((j) => [j.joueurId, j]),
              );

              const mapExterieur = Object.fromEntries(
                  joueursExterieur.map((j) => [j.joueurId, j]),
              );

              // 🔹 Rebuild complet comme en live
              for (const event of events) {
                if (event.comments === "Penalty Shootout") continue;

                const eventType = event.type;

                // SUB
                if (eventType === "subst") {
                  const joueurEntrantId = event.assist?.id?.toString();
                  if (!joueurEntrantId) continue;

                  if (mapDomicile[joueurEntrantId]) {
                    mapDomicile[joueurEntrantId].hasPlayed = true;
                  } else if (mapExterieur[joueurEntrantId]) {
                    mapExterieur[joueurEntrantId].hasPlayed = true;
                  }
                }

                // GOAL
                if (eventType === "Goal") {
                  const buteurId = event.player?.id?.toString();
                  const passeurId = event.assist?.id?.toString() || null;
                  const minute = event.time?.elapsed?.toString();
                  const teamId = event.team?.id?.toString();

                  if (!buteurId || !minute || !teamId) continue;

                  let typeBut = "normal";
                  let missed = false;

                  switch (event.detail) {
                    case "Normal Goal":
                      typeBut = "normal";
                      break;
                    case "Own Goal":
                      typeBut = "owngoal";
                      break;
                    case "Penalty":
                      typeBut = "penalty";
                      break;
                    case "Missed Penalty":
                      missed = true;
                      break;
                  }

                  if (missed) continue;

                  const but = {
                    buteurId,
                    minute,
                    passeurId,
                    typeBut,
                  };

                  if (teamId === data.equipeDomicileId) {
                    butsEquipeDomicile.push(but);
                  } else if (teamId === data.equipeExterieurId) {
                    butsEquipeExterieur.push(but);
                  }
                }
              }

              const prolongations = matchData.fixture?.status?.short == "AET";

              // 🔹 Update final COMPLET
              await db
                  .collection("matchs")
                  .doc(matchId)
                  .update({
                    status: finalStatus,
                    liveMinute: matchData.fixture.status.elapsed ?? null,
                    extraTime: matchData.fixture.status.extra ?? null,
                    scoreEquipeDomicile: matchData.goals.home ?? 0,
                    scoreEquipeExterieur: matchData.goals.away ?? 0,
                    penaltyEquipeDomicile: matchData.score?.penalty?.home ?? 0,
                    penaltyEquipeExterieur: matchData.score?.penalty?.away ?? 0,
                    prolongations: prolongations,
                    butsEquipeDomicile,
                    butsEquipeExterieur,
                    joueursEquipeDomicile: Object.values(mapDomicile),
                    joueursEquipeExterieur: Object.values(mapExterieur),
                  });

              let allUsersToNotify;

              if (data.competitionId === "1") {
                // Coupe du Monde — notifier tout le monde
                const allUsersSnapshot = await db
                    .collection("users")
                    .where("notificationToken", "!=", null)
                    .get();

                allUsersToNotify = allUsersSnapshot.docs
                    .map((doc) => ({...doc.data(), uid: doc.id}))
                    .filter(
                        (user) =>
                          user.notificationToken != null &&
        user.options?.allNotifications !== false,
                    );
              } else {
                const usersSnapshot = await db
                    .collection("users")
                    .where("equipesPrefereesId", "array-contains-any", [
                      data.equipeDomicileId,
                      data.equipeExterieurId,
                    ])
                    .get();

                const usersToNotify = usersSnapshot.docs
                    .map((doc) => ({...doc.data(), uid: doc.id}))
                    .filter(
                        (user) =>
                          user.notificationToken != null &&
                  user.options?.favoriteTeamMatch === true &&
                  user.options?.allNotifications !== false,
                    );

                const now = new Date();
                const yesterday = new Date(now);
                yesterday.setDate(yesterday.getDate() - 1);
                yesterday.setHours(0, 0, 0, 0); // minuit hier

                const matchNotifsSnapshot = await db
                    .collectionGroup("matchUserData")
                    .where("notifications", "==", true)
                    .where("matchId", "==", matchId)
                    .get();

                const matchNotifUserIds = matchNotifsSnapshot.docs.map(
                    (doc) => doc.ref.parent.parent.id,
                );

                const existingUids = new Set(usersToNotify.map((u) => u.uid));
                const extraUids = matchNotifUserIds.filter(
                    (uid) => !existingUids.has(uid),
                );

                const extraUsersSnapshots = await Promise.all(
                    extraUids.map((uid) => db.collection("users").
                        doc(uid).get()),
                );

                const extraUsers = extraUsersSnapshots
                    .filter((doc) => doc.exists)
                    .map((doc) => ({...doc.data(), uid: doc.id}))
                    .filter(
                        (user) =>
                          user.notificationToken != null &&
                  user.options?.allNotifications !== false,
                    );

                allUsersToNotify = [...usersToNotify, ...extraUsers];
              }
              console.log(allUsersToNotify.length, "utilisateurs à notifier");

              let successCount = 0;
              let errorCount = 0;

              for (const user of allUsersToNotify) {
                try {
                  await sendNotificationToUser(user.uid,
                      NOTIF_TYPES.FAVORITE_TEAM_MATCH_END, {
                        matchName:
                  `${matchData.teams.home.name} - ${matchData.teams.away.name}`,
                        matchId: matchId,
                      },
                  );
                  successCount++;
                } catch (error) {
                  errorCount++;
                  console.error(`🔥 Erreur notif user ${user.uid}:`,
                      error.errorInfo?.code ?? error.message);
                }
              }

              console.log(`📊 Notifs — ✅ ${successCount} envoyées | ` +
                `❌ ${errorCount} erreurs`);
            } catch (error) {
              console.error("🔥 Erreur finalisation : ", matchId, error);
            }
          }
        } else {
          console.log("❌ Aucun match en cours, pas besoin de vérifier");
        }

        console.log(
            "✅ Mise à jour terminée, matchs analysés : ",
            nbMatchsUpdated,
        );
      } catch (error) {
        console.error("🔥 Erreur globale :", error);
      }
    // console.log("en pause : limite quotidienne atteinte");
    },
);

exports.cleanupStaleMatches = onSchedule(
    {
      schedule: "45 0 * * *",
      timeZone: "Europe/Paris",
    },
    async () => {
      console.log("🧹 Nettoyage des matchs stale...");

      try {
        const now = new Date();
        const threeDaysAgo = new Date(now.getTime() - 3 * 24 * 60 * 60 * 1000);

        const snapshot = await db
            .collection("matchs")
            .where("status", "==", "scheduled")
            .where("date", ">=", threeDaysAgo)
            .where("date", "<", now)
            .get();

        console.log(`📋 ${snapshot.docs.length} matchs stale à traiter`);

        for (const doc of snapshot.docs) {
          const matchId = doc.id;
          const data = doc.data();

          try {
            const result = await getDataFromApi("fixtures", {id: matchId});

            // Aucune donnée API → suppression
            if (!result || result.length === 0) {
              await db.collection("matchs").doc(matchId).delete();
              console.log(`🗑️ Match ${matchId} ` +
                `supprimé (introuvable sur l'API)`);
              continue;
            }

            const matchData = result[0];
            const statusCode = matchData.fixture.status.short;
            const finalStatus = getStatusFromCode(statusCode);

            // Annulé, reporté ou toujours scheduled → suppression
            if (
              finalStatus === "cancelled" ||
              finalStatus === "postponed" ||
              finalStatus === "scheduled"
            ) {
              await db.collection("matchs").doc(matchId).delete();
              console.log(`🗑️ Match ${matchId} supprimé (${statusCode})`);
              continue;
            }

            // Toujours en live → on laisse updateLiveMatches gérer
            if (finalStatus === "live" || finalStatus === "halftime") {
              console.log(`⏳ Match ${matchId} encore en cours, ignoré`);
              continue;
            }

            // Match terminé → update complet
            console.log(`🏁 Match stale terminé, mise à jour : ${matchId}`);

            const events = await getDataFromApi("fixtures/events", {
              fixture: matchId,
            });

            const butsEquipeDomicile = [];
            const butsEquipeExterieur = [];

            const joueursDomicile = data.joueursEquipeDomicile || [];
            const joueursExterieur = data.joueursEquipeExterieur || [];

            const mapDomicile = Object.fromEntries(
                joueursDomicile.map((j) => [j.joueurId, j]),
            );
            const mapExterieur = Object.fromEntries(
                joueursExterieur.map((j) => [j.joueurId, j]),
            );

            for (const event of events || []) {
              if (event.comments === "Penalty Shootout") continue;

              const eventType = event.type;

              if (eventType === "subst") {
                const joueurEntrantId = event.assist?.id?.toString();
                if (!joueurEntrantId) continue;
                if (mapDomicile[joueurEntrantId]) {
                  mapDomicile[joueurEntrantId].hasPlayed = true;
                } else if (mapExterieur[joueurEntrantId]) {
                  mapExterieur[joueurEntrantId].hasPlayed = true;
                }
              }

              if (eventType === "Var") {
                const detail = event.detail || "";
                if (detail.includes("Goal Disallowed")) {
                  const playerId = event.player?.id?.toString();
                  const teamId = event.team?.id?.toString();
                  const minute = event.time?.elapsed?.toString();
                  if (!playerId || !teamId) continue;

                  const removeDisallowed = (goalsArray) =>
                    goalsArray.filter((goal) =>
                      goal.buteurId !== playerId || goal.minute !== minute,
                    );

                  if (teamId === data.equipeDomicileId) {
                    butsEquipeDomicile.splice(
                        0, butsEquipeDomicile.length,
                        ...removeDisallowed(butsEquipeDomicile),
                    );
                  } else if (teamId === data.equipeExterieurId) {
                    butsEquipeExterieur.splice(
                        0, butsEquipeExterieur.length,
                        ...removeDisallowed(butsEquipeExterieur),
                    );
                  }
                }
              }

              if (eventType === "Goal") {
                const buteurId = event.player?.id?.toString();
                const passeurId = event.assist?.id?.toString() || null;
                let minute = event.time?.elapsed?.toString();
                const extra = event.time?.extra?.toString();
                const teamId = event.team?.id?.toString();

                if (!buteurId || !minute || !teamId) continue;

                if (extra != null && extra !== "") {
                  minute = minute + "+" + extra.toString();
                }

                let typeBut = "normal";
                let missed = false;

                switch (event.detail) {
                  case "Normal Goal": typeBut = "normal"; break;
                  case "Own Goal": typeBut = "owngoal"; break;
                  case "Penalty": typeBut = "penalty"; break;
                  case "Missed Penalty": missed = true; break;
                }

                if (missed) continue;

                const but = {buteurId, minute, passeurId, typeBut};

                if (teamId === data.equipeDomicileId) {
                  butsEquipeDomicile.push(but);
                } else if (teamId === data.equipeExterieurId) {
                  butsEquipeExterieur.push(but);
                }
              }
            }

            const prolongations = statusCode === "AET" || statusCode === "PEN";

            await db.collection("matchs").doc(matchId).update({
              status: finalStatus,
              liveMinute: matchData.fixture.status.elapsed ?? null,
              extraTime: matchData.fixture.status.extra ?? null,
              scoreEquipeDomicile: matchData.goals.home ?? 0,
              scoreEquipeExterieur: matchData.goals.away ?? 0,
              penaltyEquipeDomicile: matchData.score?.penalty?.home ?? null,
              penaltyEquipeExterieur: matchData.score?.penalty?.away ?? null,
              prolongations,
              butsEquipeDomicile,
              butsEquipeExterieur,
              joueursEquipeDomicile: Object.values(mapDomicile),
              joueursEquipeExterieur: Object.values(mapExterieur),
            });

            console.log(`✅ Match stale mis à jour : ${matchId}`);
          } catch (error) {
            console.error(`🔥 Erreur cleanup match ${matchId}:`, error);
          }
        }

        console.log("✅ Nettoyage terminé");
      } catch (error) {
        console.error("🔥 Erreur globale cleanupStaleMatches :", error);
      }
    },
);

exports.sendWeeklyRecapNotifications = onSchedule(
    {
      schedule: "0 7 * * 1", // tous les lundis à 7h00
      timeZone: "Europe/Paris",
    },
    async () => {
      console.log("📊 Envoi des notifications weekly recap...");

      try {
        const usersSnapshot = await db.collection("users").get();

        const usersToNotify = usersSnapshot.docs
            .map((doc) => ({...doc.data(), uid: doc.id}))
            .filter(
                (user) =>
                  user.notificationToken != null &&
            user.options?.allNotifications !== false &&
            user.options?.weeklyRecap !== false,
            );

        console.log(
            usersToNotify.length,
            "utilisateurs à notifier pour le récap hebdo",
        );

        for (const user of usersToNotify) {
          try {
            await sendNotificationToUser(
                user.uid,
                NOTIF_TYPES.WEEKLY_RECAP,
                {},
            );

            console.log("✅ Weekly recap envoyée à :", user.uid);
          } catch (error) {
            console.error("🔥 Erreur notif weekly recap :", user.uid, error);
          }
        }

        console.log("✅ Weekly recap terminé");
      } catch (error) {
        console.error("🔥 Erreur globale weekly recap :", error);
      }
    },
);

exports.sendCdmRecapNotification = onSchedule(
    {
      schedule: "15 23 19 7 *", // 19 juillet à 23h15
      timeZone: "Europe/Paris",
    },
    async () => {
      console.log("🏆 Envoi des notifications récap CdM 2026...");

      try {
        const usersSnapshot = await db.collection("users").get();

        const usersToNotify = usersSnapshot.docs
            .map((doc) => ({...doc.data(), uid: doc.id}))
            .filter(
                (user) =>
                  user.notificationToken != null &&
                  user.options?.allNotifications !== false,
            );

        console.log(
            usersToNotify.length,
            "utilisateurs à notifier pour le récap CdM",
        );

        for (const user of usersToNotify) {
          try {
            await sendNotificationToUser(
                user.uid,
                NOTIF_TYPES.CDM_RECAP,
                {},
            );
            console.log("✅ récap CdM envoyée à :", user.uid);
          } catch (error) {
            console.error("🔥 Erreur notif CdM recap :", user.uid, error);
          }
        }

        console.log("✅ CdM recap terminé");
      } catch (error) {
        console.error("🔥 Erreur globale CdM recap :", error);
      }
    },
);

exports.updatePopulariteCompetitions = onSchedule(
    {
      schedule: "0 0 * * *",
      timeZone: "Europe/Paris",
    },
    async () => {
      try {
        const usersSnapshot = await db.collection("users").get();

        const competitionIdToCount = {};

        usersSnapshot.forEach((doc) => {
          const userData = doc.data();

          const competitionsPrefereesId =
          userData.competitionsPrefereesId || [];

          for (const competitionId of competitionsPrefereesId) {
            if (competitionIdToCount[competitionId]) {
              competitionIdToCount[competitionId]++;
            } else {
              competitionIdToCount[competitionId] = 1;
            }
          }
        });

        const competitionsSnapshot = await db.collection("competitions").get();

        const batch = db.batch();

        competitionsSnapshot.forEach((doc) => {
          const competitionData = doc.data();

          const newPopularite = competitionIdToCount[doc.id] || 0;

          const oldPopularite = competitionData.popularite;

          batch.update(doc.ref, {
            popularite: newPopularite,
          });

          console.log(
              `popularité mise à jour pour ` +
            `${competitionData.nom} : ${newPopularite} ` +
            `(ancienne : ${oldPopularite})`,
          );
        });

        await batch.commit();

        console.log("Toutes les popularités ont été mises à jour.");
      } catch (error) {
        console.error("Erreur updatePopulariteCompetitions :", error);
      }
    },
);
