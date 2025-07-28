const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const categories = [
  "Awareness",
  "Diagnosis",
  "Treatment",
  "Prevention",
  "Palliative Care",
  "Survivorship"
];

db.collection("medical_dictionary")
  .doc("categories")
  .set({ categories })
  .then(() => console.log("✅ Categories document added"))
  .catch(console.error);
