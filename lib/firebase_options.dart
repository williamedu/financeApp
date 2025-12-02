import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Configuración WEB
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAD3UUBtBo1qGO1WXFXoF4avFRM8R3YFRo',
    appId: '1:96687141554:web:ffeff99cdeba2675404fab',
    messagingSenderId: '96687141554',
    projectId: 'financeflow-72f8d',
    authDomain: 'financeflow-72f8d.firebaseapp.com',
    storageBucket: 'financeflow-72f8d.firebasestorage.app',
  );

  // Configuración ANDROID (lo haremos después si quieres)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'ANDROID_API_KEY',
    appId: 'ANDROID_APP_ID',
    messagingSenderId: 'MESSAGING_SENDER_ID',
    projectId: 'PROJECT_ID',
    storageBucket: 'PROJECT_ID.appspot.com',
  );

  // Configuración iOS (lo haremos después si quieres)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'IOS_API_KEY',
    appId: 'IOS_APP_ID',
    messagingSenderId: 'MESSAGING_SENDER_ID',
    projectId: 'PROJECT_ID',
    storageBucket: 'PROJECT_ID.appspot.com',
    iosClientId: 'IOS_CLIENT_ID',
    iosBundleId: 'com.example.financeApp',
  );
}
