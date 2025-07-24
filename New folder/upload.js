const admin = require('firebase-admin');
const fs = require('fs');

// Make sure serviceAccountKey.json is in the same folder
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Load the cancer categories JSON
const data = JSON.parse(fs.readFileSync('./cancer_categories.json', 'utf8'));

async function importData() {
  for (const category of data.categories) {
    const docRef = db.collection('cancer_categories').doc(category.name);
    await docRef.set({
      symptoms: category.symptoms,
    });
    console.log(`Uploaded: ${category.name}`);
  }

  console.log('✅ All cancer categories uploaded successfully.');
}

importData().catch(console.error);
