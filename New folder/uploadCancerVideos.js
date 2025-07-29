const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function updateVideoFields() {
  const snapshot = await db
    .collection('health_education')
    .doc('videos')
    .collection('list')
    .get();

  const batch = db.batch();

  snapshot.forEach((doc) => {
    const data = doc.data();
    const docRef = doc.ref;

    const updates = {};
    if (typeof data.likes !== 'number') updates.likes = 0;
    if (typeof data.dislikes !== 'number') updates.dislikes = 0;

    if (Object.keys(updates).length > 0) {
      batch.update(docRef, updates);
    }
  });

  await batch.commit();
  console.log('Video fields updated');
}

updateVideoFields();
