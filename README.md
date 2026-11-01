# SyncSphere

SyncSphere is a Flutter university events app backed by Firebase Authentication,
Cloud Firestore, and callable Cloud Functions. Students can browse events and
clubs, register for events, receive notifications, and respond to volunteer
assignments. Coordinators and admins can create events, assign volunteers, and
view registration reports.

## Firebase setup

The Firebase project configured for this app is `syncsphere-912df`. Its
SyncSphere web app has been registered, and the web SDK configuration is
checked into `lib/firebase_options.dart`.

1. For web, no further Firebase app configuration is required. To add Android
   or iOS, install FlutterFire and generate native platform configuration:

   ```powershell
   dart pub global activate flutterfire_cli
   npm install --global firebase-tools
   firebase login
   ```

   ```powershell
   flutter create . --platforms=android,ios,web
   flutterfire configure --project=syncsphere-912df --platforms=android,ios,web
   ```

2. In Firebase Console > Authentication > Sign-in method, enable
   **Email/Password**. The project already has a default Firestore database.

3. Install and deploy the backend:

   ```powershell
   npm --prefix functions install
   firebase use syncsphere-912df
   firebase deploy --only firestore:rules,firestore:indexes,functions
   ```

   Cloud Functions deployment requires billing, the Cloud Functions API and
   related Google Cloud APIs enabled, and appropriate deploy permissions. Do
   not deploy from an untrusted account.

5. Seed the starter club directory:

   ```powershell
   npm --prefix functions run seed-clubs
   ```

   The seed script uses Application Default Credentials. On a trusted
   administrator workstation, authenticate with `gcloud auth application-default
   login` first. Never commit service-account credentials.

6. Create an account in the app. New accounts are always Students. To grant the
   first trusted admin role, use Application Default Credentials on a trusted
   workstation:

   ```powershell
   gcloud auth application-default login
   npm --prefix functions run set-role -- your-admin-email@example.edu admin
   ```

   Grant a coordinator role with a seeded club ID:

   ```powershell
   npm --prefix functions run set-role -- coordinator@example.edu coordinator tech-club
   ```

   The user must sign out and back in after a role change. Never allow users to
   set their own Coordinator/Admin role.

## Run and validate

```powershell
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
```

## Data and authorization model

- `users/{uid}`: account profile and display role. Custom Auth claims, not
  client-editable profile fields, authorize privileged operations.
- `events/{eventId}`: event details, publishing status, owner and registration
  count.
- `registrations/{eventId_uid}`: one registration per user and event.
- `assignments/{eventId_uid}`: volunteer assignment and response state.
- `clubs/{clubId}`: browseable club directory.
- `notifications/{notificationId}`: notifications addressed to one user.

Registration, event creation, volunteer assignment, assignment responses, and
report aggregation run through callable Cloud Functions. Firestore rules deny
direct client writes to those records. The callable functions validate the
signed-in identity and role and enforce owner scoping. The starter report does
not calculate attendance: there is no attendance/check-in workflow in the
current UI, so reports explicitly mark it as not tracked.

## Existing UI boundaries

Email/password authentication and password reset are wired. Social providers
are not offered because provider OAuth setup has not been configured. The
event cover image remains a visual placeholder; event editing/deletion, club
membership changes, certificates, and attendance tracking are not implemented
in the current frontend and therefore have no backend endpoints.
