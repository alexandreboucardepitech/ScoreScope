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

// Récupérer les matchs des 2 prochaines semainestous les jours à minuit
exports.fetchNextTwoWeeksMatches = onSchedule(
    {
      schedule: "46 9 * * *",
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
                status: matchData.fixture.status.short,
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
                butsEquipeDomicileId: [],
                butsEquipeExterieurId: [],
                joueursEquipeDomicileId: [],
                joueursEquipeExterieurId: [],
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
