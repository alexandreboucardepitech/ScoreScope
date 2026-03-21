const {setGlobalOptions} = require("firebase-functions/v2");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

admin.initializeApp();
setGlobalOptions({maxInstances: 10});
const db = admin.firestore();
const API_FOOTBALL_TOKEN = process.env.API_FOOTBALL_TOKEN;

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
      console.log("Rate limit hit, retrying in 1 min");
      await new Promise((res) => setTimeout(res, 60 * 1000));
      return getDataFromApi(endpoint, params);
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

// Récupérer les matchs des 2 prochaines semainestous les jours à minuit
exports.fetchNextTwoWeeksMatches = onSchedule(
    {
      schedule: "0 0 * * *",
      timeZone: "Europe/Paris",
    },
    async () => {
      console.log("Récupération des matchs des 2 prochaines semaines...");

      try {
      // Récupérer toutes les compétitions depuis Firestore
        const competitionsSnap = await db.collection("competitions").get();
        const competitions = competitionsSnap.docs.map((doc) => doc.id);

        const today = Math.floor(Date.now() / 1000); // timestamp en secondes
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
            if (!matchDoc.exists) {
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
                date: new Date(matchData.fixture.timestamp * 1000)
                    .toISOString(),
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
              console.log("Match ajouté :", id, " compétition : ", leagueId);
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

      console.log("Fenêtre :", minTime, "→", maxTime);

      try {
      // 🔹 1. Récupérer les matchs dans la fenêtre
        const snapshot = await db
            .collection("matchs")
            .where("date", ">=", minTime)
            .where("date", "<=", maxTime)
            .get();

        console.log("Matchs trouvés :", snapshot.size);

        // 🔹 2. Filtrer côté JS (null OU tableau vide)
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

        // 🔹 3. Traiter chaque match
        for (const doc of matchs) {
          const matchId = doc.id;

          console.log("🔎 Match :", matchId);

          try {
            const lineup = await getDataFromApi("fixtures/lineups", {
              fixture: matchId,
            });

            if (!lineup || lineup.length < 2) {
              console.log("❌ Pas encore de lineup pour", matchId);
              continue;
            }

            const equipeDomicile = lineup[0];
            const equipeExterieur = lineup[1];

            const mapPlayer = (playerObj, isFromStartXI = true) => {
              if (!playerObj?.player?.id) {
                return null; // on skip
              }

              return {
                joueurId: playerObj.player.id.toString(),
                number: playerObj.player.number || null,
                pos: playerObj.player.pos || null,
                grid: playerObj.player.grid || null,
                hasPlayed: isFromStartXI,
              };
            };

            const joueursDomicile = [
              ...(equipeDomicile.startXI || []).map((p) => mapPlayer(p, true)),
              ...(equipeDomicile.substitutes || []).map((p) =>
                mapPlayer(p, false),
              ),
            ].filter(Boolean);

            const joueursExterieur = [
              ...(equipeExterieur.startXI || []).map((p) => mapPlayer(p, true)),
              ...(equipeExterieur.substitutes || []).map((p) =>
                mapPlayer(p, false),
              ),
            ].filter(Boolean);

            if (joueursDomicile.length === 0 || joueursExterieur.length === 0) {
              console.log("⚠️ Lineup vide pour", matchId);
              continue;
            }

            console.log("✅ Lineup trouvé pour", matchId);

            // 🔹 4. Mise à jour Firestore
            await db.collection("matchs").doc(doc.id).update({
              joueursEquipeDomicile: joueursDomicile,
              joueursEquipeExterieur: joueursExterieur,
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
