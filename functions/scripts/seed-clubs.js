const { applicationDefault, initializeApp } = require('firebase-admin/app');
const { FieldValue, getFirestore } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault() });
const db = getFirestore();

const clubs = [
  { id: 'tech-club', name: 'Tech Club', type: 'Technical', icon: 'code' },
  { id: 'ai-club', name: 'AI Club', type: 'Technical', icon: 'psychology' },
  { id: 'robotics-club', name: 'Robotics Club', type: 'Technical', icon: 'robotics' },
  { id: 'design-club', name: 'Design Club', type: 'Cultural', icon: 'palette' },
  { id: 'music-society', name: 'Music Society', type: 'Cultural', icon: 'music' },
  {
    id: 'social-impact-club',
    name: 'Social Impact Club',
    type: 'Social',
    icon: 'volunteer',
  },
];

async function seedClubs() {
  const batch = db.batch();
  for (const club of clubs) {
    const ref = db.collection('clubs').doc(club.id);
    batch.set(ref, {
      name: club.name,
      type: club.type,
      icon: club.icon,
      memberCount: 0,
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
  }
  await batch.commit();
  console.log(`Seeded ${clubs.length} clubs.`);
}

seedClubs().catch((error) => {
  console.error(`Could not seed clubs: ${error.message}`);
  process.exitCode = 1;
});
