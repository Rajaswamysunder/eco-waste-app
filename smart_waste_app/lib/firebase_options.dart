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
        return android;
      case TargetPlatform.linux:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA2bAhlVffQknarfJMk6HUJXLp3CgLFRQY',
    appId: '1:1091497896164:android:4e9634ca13da3cbc8c64f1',
    messagingSenderId: '1091497896164',
    projectId: 'smart-waste-collection-2d413',
    storageBucket: 'smart-waste-collection-2d413.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA2bAhlVffQknarfJMk6HUJXLp3CgLFRQY',
    appId: '1:1091497896164:android:4e9634ca13da3cbc8c64f1',
    messagingSenderId: '1091497896164',
    projectId: 'smart-waste-collection-2d413',
    storageBucket: 'smart-waste-collection-2d413.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyACrzi0Ib3GHlOc8lwzcfcPw2mQfCC650I',
    appId: '1:1091497896164:ios:a8f2689e734e9b618c64f1',
    messagingSenderId: '1091497896164',
    projectId: 'smart-waste-collection-2d413',
    storageBucket: 'smart-waste-collection-2d413.firebasestorage.app',
    iosBundleId: 'com.rajaswamy.smartWasteApp2026',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyACrzi0Ib3GHlOc8lwzcfcPw2mQfCC650I',
    appId: '1:1091497896164:ios:a8f2689e734e9b618c64f1',
    messagingSenderId: '1091497896164',
    projectId: 'smart-waste-collection-2d413',
    storageBucket: 'smart-waste-collection-2d413.firebasestorage.app',
    iosBundleId: 'com.rajaswamy.smartWasteApp2026',
  );
}
