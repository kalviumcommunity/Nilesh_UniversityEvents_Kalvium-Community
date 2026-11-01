import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!DefaultFirebaseOptions.isConfigured) {
    runApp(const _FirebaseSetupRequiredApp());
    return;
  }
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const SyncSphereApp());
  } on FirebaseException catch (error) {
    runApp(_FirebaseInitializationErrorApp(message: error.message));
  }
}

class _FirebaseSetupRequiredApp extends StatelessWidget {
  const _FirebaseSetupRequiredApp();

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Firebase is not configured. Follow the Firebase setup steps in README.md, then run the app again.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
}

class _FirebaseInitializationErrorApp extends StatelessWidget {
  const _FirebaseInitializationErrorApp({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not initialize Firebase${message == null ? '.' : ': $message'}',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
}
