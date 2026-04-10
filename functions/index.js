const {setGlobalOptions} = require("firebase-functions/v2");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const fetch = require("node-fetch");
const {onRequest} = require("firebase-functions/v2/https");

admin.initializeApp();
setGlobalOptions({maxInstances: 10});
const db = admin.firestore();
const API_FOOTBALL_TOKEN = process.env.API_FOOTBALL_TOKEN;

exports.getFootballData = onRequest(async (req, res) => {
  const {endpoint, params} = req.body;

  const data = await getDataFromApi(endpoint, params);

  res.json({response: data});
});

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

function getMatchStatusFromCode(code) {
  switch (code) {
    case "FT":
    case "AET":
    case "PEN":
      return "finished"; // MatchStatus.finished
    case "1H":
    case "HT":
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

        const today = Math.floor(Date.now() / 1000);
        const twoWeeksLater = today + 14 * 24 * 60 * 60;
        for (const comp of competitions) {
          console.log(comp);
        }

        for (const leagueId of competitions) {
          const data = await getDataFromApi("fixtures", {
            league: leagueId,
            from: new Date(today * 1000).toISOString().split("T")[0],
            to: new Date(twoWeeksLater * 1000).toISOString().split("T")[0],
            season: 2025,
          });

          console.log(
              data.length + " matchs récupérés pour compétition " + leagueId,
          );

          for (const matchData of data) {
            const id = matchData.fixture.id.toString();
            const matchDocRef = db.collection("matchs").doc(id);

            const matchDoc = await matchDocRef.get();

            const apiDate = new Date(matchData.fixture.timestamp * 1000);

            let shouldUpdate = !matchDoc.exists;

            if (matchDoc.exists) {
              const dbDate = matchDoc.data().date.toDate();

              shouldUpdate = apiDate.getTime() !== dbDate.getTime();
            }

            if (shouldUpdate) {
            // On récupère toutes les infos disponibles

              const matchObj = {
                id,
                status: getMatchStatusFromCode(matchData.fixture.status.short),
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
      const minTime = new Date(now.getTime() + 5 * 60 * 1000);
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

            const teamIdDom = doc.equipeDomicileId;
            const teamIdExt = doc.equipeExterieurId;

            const mapPlayer = (playerObj, isFromStartXI = true) => {
              if (!playerObj?.player?.id) return null;

              return {
                joueurId: playerObj.player.id.toString(),
                number: playerObj.player.number || null,
                pos: playerObj.player.pos || null,
                grid: playerObj.player.grid || null,
                hasPlayed: isFromStartXI,
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
              })),
              ...joueursExt.map((j) => ({
                id: j.joueurId,
                equipeId: teamIdExt,
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
                playerDocs.filter((doc) => doc.exists).map((doc) => doc.id),
            );

            const playersToCreate = uniquePlayers.filter(
                (p) => !existingIds.has(p.id),
            );

            console.log("👤 Joueurs à créer :", playersToCreate.length);

            for (const playerInfo of playersToCreate) {
              try {
                const joueurId = playerInfo.id;
                const equipeId = playerInfo.equipeId;

                const apiData = await getDataFromApi("players/profiles", {
                  player: joueurId,
                });

                if (!apiData || apiData.length === 0) continue;

                const player = apiData[0]?.player;
                if (!player) continue;

                const joueurObj = {
                  id: joueurId,
                  prenom: player.firstname || "",
                  nom: player.lastname || "",
                  fullName: (player.name || "").replaceAll("&apos;", "'"),
                  equipeId: equipeId,
                  dateNaissance: player.birth?.date || null,
                  nationalite: player.nationality || null,
                  picture: player.photo || null,
                  createdAt: new Date(),
                };

                await db.collection("joueurs").doc(joueurId).set(joueurObj);

                console.log("👤 Joueur créé :", joueurId);
              } catch (err) {
                console.error("🔥 Erreur création joueur :", playerInfo.id, err);
              }
            }

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
      schedule: "*/2 * * * *",
      timeZone: "Europe/Paris",
    },
    async () => {
      console.log("⚡ Mise à jour des matchs en live...");

      try {
        let nbMatchsUpdated = 0;
        const mustCallApi = await checkMustCallApi();
        if (mustCallApi == true) {
          console.log("Il faut appeler l'API");
          const live = await getDataFromApi("fixtures",
              {live: "1-135-137-140-143-2-3-39-4-45-48-" +
              "526-528-529-547-556-61-62-66-78-81-848"});

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
              const newStatus = getMatchStatusFromCode(
                  matchData.fixture.status.short,
              );
              const newMinute = matchData.fixture.status.elapsed ?? null;
              const newExtra = matchData.fixture.status.extra ?? null;

              const hasScoreChanged =
              data.scoreEquipeDomicile !== newScoreHome ||
              data.scoreEquipeExterieur !== newScoreAway;

              const hasStatusChanged = data.status !== newStatus;
              const hasMinuteChanged = data.liveMinute !== newMinute;

              nbMatchsUpdated++;

              if (hasScoreChanged || hasStatusChanged) {
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

              const finalStatus = getMatchStatusFromCode(
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
                    butsEquipeDomicile,
                    butsEquipeExterieur,
                    joueursEquipeDomicile: Object.values(mapDomicile),
                    joueursEquipeExterieur: Object.values(mapExterieur),
                  });
            } catch (error) {
              console.error("🔥 Erreur finalisation :", matchId, error);
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
