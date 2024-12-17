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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCpHlM9pKKxfDJwQVQVvIh3sKvnLP3Sz5U',
    appId: '1:949096798811:web:c0eb99ece16ae7c0e0bd7e',
    messagingSenderId: '949096798811',
    projectId: 'travel-buddy-app-e8e39',
    authDomain: 'travel-buddy-app-e8e39.firebaseapp.com',
    storageBucket: 'travel-buddy-app-e8e39.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAsQfWVX-O4ieRchovoEv4gI58ZwmXgbRM',
    appId: '1:949096798811:android:7380168e7df80795e0bd7e',
    messagingSenderId: '949096798811',
    projectId: 'travel-buddy-app-e8e39',
    storageBucket: 'travel-buddy-app-e8e39.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDzeYb-RGT-wmvYNOjwZa5wRH0uym7UvRA',
    appId: '1:949096798811:ios:aba968db24a753fde0bd7e',
    messagingSenderId: '949096798811',
    projectId: 'travel-buddy-app-e8e39',
    storageBucket: 'travel-buddy-app-e8e39.firebasestorage.app',
    iosBundleId: 'com.example.travelBuddyApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDzeYb-RGT-wmvYNOjwZa5wRH0uym7UvRA',
    appId: '1:949096798811:ios:aba968db24a753fde0bd7e',
    messagingSenderId: '949096798811',
    projectId: 'travel-buddy-app-e8e39',
    storageBucket: 'travel-buddy-app-e8e39.firebasestorage.app',
    iosBundleId: 'com.example.travelBuddyApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCpHlM9pKKxfDJwQVQVvIh3sKvnLP3Sz5U',
    appId: '1:949096798811:web:b4c5471fee80fcb3e0bd7e',
    messagingSenderId: '949096798811',
    projectId: 'travel-buddy-app-e8e39',
    authDomain: 'travel-buddy-app-e8e39.firebaseapp.com',
    storageBucket: 'travel-buddy-app-e8e39.firebasestorage.app',
  );
}
