# SyncSphere – University Events (frontend UI)

UI only, built from the Figma screenshots. Data is placeholder data in
`lib/data/mock_data.dart`. There is no backend, Firebase, or auth in this
project; buttons that would save data show a "not wired up yet" message.

## Run

```bash
flutter pub get
flutter run                                    # choose a device/emulator
flutter run -d chrome                          # run in the browser
```

## Check and test

```bash
dart format lib test
flutter analyze
flutter test
```

## Try the screens

- Sign In -> goes to the **student** app. Sign Up -> pick a role -> "Go to
  Home": Student gets the student app; Coordinator/Admin get the admin app.
- Student > Profile > **Volunteer Hours** opens the volunteer dashboard and
  assignment details using demo data (`lib/dev/demo_volunteer_backend.dart`).

## Layout

- `lib/app` theme, colours, routes
- `lib/ui` shared widgets (buttons, fields, chips, nav, cards)
- `lib/features/*` screens (onboarding, auth, student, admin, common)
- `lib/features/volunteer` the volunteer module (contracts, state, UI)
- `lib/dev` demo-only stand-in for the real repositories
