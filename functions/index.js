const { setGlobalOptions } = require("firebase-functions/v2");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();

setGlobalOptions({ maxInstances: 10 });

// Fonction qui tourne toutes les minutes
exports.testFunction = onSchedule("* * * * *", async (event) => {
  const db = admin.firestore();

  await db.collection("test").add({
    message: "Hello from backend 🚀",
    timestamp: new Date(),
  });

  console.log("Function executed");
});
