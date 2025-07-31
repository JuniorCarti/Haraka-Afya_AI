const admin = require("firebase-admin");
const fs = require("fs");

// Load service account credentials
const serviceAccount = require("./serviceAccountKey.json");

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Load hospitals data
const hospitalsData = JSON.parse(fs.readFileSync("hospitals.json", "utf8"));

// Upload each hospital document
async function uploadHospitals() {
  const batch = db.batch();

  hospitalsData.hospitals.forEach((hospital) => {
    const docRef = db.collection("hospitals").doc(); // Auto-generated ID
    batch.set(docRef, hospital);
  });

  try {
    await batch.commit();
    console.log("✅ Successfully uploaded hospitals to Firestore.");
  } catch (error) {
    console.error("❌ Error uploading hospitals:", error);
  }
}

uploadHospitals();
