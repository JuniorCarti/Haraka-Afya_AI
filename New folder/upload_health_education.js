const admin = require('firebase-admin');
const fs = require('fs');

// Initialize Firebase Admin SDK
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Load health education data
const data = JSON.parse(fs.readFileSync('./data.json', 'utf8')).health_education;

async function importHealthEducation() {
  // Upload today's tips
  await db.collection('health_education').doc('today_tips').set({
    tips: data.today_tips,
  });
  console.log('✅ Today\'s tips uploaded');

  // Upload categories
  await db.collection('health_education').doc('categories').set({
    categories: data.categories,
  });
  console.log('✅ Categories uploaded');

  // Upload articles to subcollection: articles/list/{articleId}
  const articlesRef = db.collection('health_education').doc('articles').collection('list');

  for (const article of data.articles) {
    await articlesRef.doc(article.id).set(article);
    console.log(`✅ Uploaded article: ${article.title}`);
  }

  console.log('🎉 All health education data uploaded successfully.');
}

importHealthEducation().catch(console.error);
