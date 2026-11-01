const { applicationDefault, initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

const [email, role, clubId] = process.argv.slice(2);
const allowedRoles = new Set(['student', 'coordinator', 'admin']);

if (!email || !allowedRoles.has(role)) {
  console.error('Usage: npm run set-role -- <email> <student|coordinator|admin> [clubId]');
  process.exitCode = 1;
} else {
  initializeApp({ credential: applicationDefault() });
  const auth = getAuth();
  const db = getFirestore();

  auth.getUserByEmail(email)
    .then(async (user) => {
      const profile = {
        role,
        updatedAt: FieldValue.serverTimestamp(),
      };
      if (role === 'coordinator' && clubId) {
        const club = await db.collection('clubs').doc(clubId).get();
        if (!club.exists) {
          throw new Error(`Club '${clubId}' does not exist. Seed or create it first.`);
        }
        profile.clubId = clubId;
        profile.clubName = club.data().name;
      }
      const current = user.customClaims || {};
      await auth.setCustomUserClaims(user.uid, { ...current, role });
      await db.collection('users').doc(user.uid).set({
        ...profile,
      }, { merge: true });
      console.log(`Granted ${role} access to ${email}. Have the user sign out and back in.`);
    })
    .catch((error) => {
      console.error(`Could not grant role: ${error.message}`);
      process.exitCode = 1;
    });
}
