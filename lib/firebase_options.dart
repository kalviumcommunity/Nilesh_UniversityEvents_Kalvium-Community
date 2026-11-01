import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static bool get isConfigured {
    final appId = kIsWeb
        ? _web.appId
        : switch (defaultTargetPlatform) {
            TargetPlatform.android || TargetPlatform.fuchsia => _android.appId,
            TargetPlatform.iOS || TargetPlatform.macOS => _ios.appId,
            TargetPlatform.windows || TargetPlatform.linux => _web.appId,
          };
    return appId.isNotEmpty;
  }

  static FirebaseOptions get currentPlatform {
    final options = switch (defaultTargetPlatform) {
      TargetPlatform.android => _android,
      TargetPlatform.iOS => _ios,
      TargetPlatform.macOS => _ios,
      TargetPlatform.windows => _web,
      TargetPlatform.linux => _web,
      TargetPlatform.fuchsia => _android,
    };
    if (kIsWeb) return _web;
    return options;
  }

  static const _web = FirebaseOptions(
    apiKey: 'AIzaSyAfdkXwVNfxwj5M9sLN4vhqoVgpPWxCV8o',
    appId: '1:34501657726:web:02df25da69d38d12be842f',
    messagingSenderId: '34501657726',
    projectId: 'syncsphere-912df',
    authDomain: 'syncsphere-912df.firebaseapp.com',
    storageBucket: 'syncsphere-912df.firebasestorage.app',
    measurementId: 'G-CT36F1CT4H',
  );

  static const _android = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '34501657726',
    projectId: 'syncsphere-912df',
  );

  static const _ios = FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '34501657726',
    projectId: 'syncsphere-912df',
    iosBundleId: String.fromEnvironment(
      'FIREBASE_IOS_BUNDLE_ID',
      defaultValue: 'com.syncsphere.universityEvents',
    ),
  );
}
