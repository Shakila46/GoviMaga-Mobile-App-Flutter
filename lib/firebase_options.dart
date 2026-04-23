import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  // Get API keys from .env file
  static String get androidApiKey => dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '';
  static String get iosApiKey => dotenv.env['FIREBASE_IOS_API_KEY'] ?? '';
  static String get webApiKey => dotenv.env['FIREBASE_WEB_API_KEY'] ?? '';

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
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: androidApiKey,
    appId: '1:988783189852:android:183fe343a82ed9f611ab99',
    messagingSenderId: '988783189852',
    projectId: 'govimaga-862b8',
    storageBucket: 'govimaga-862b8.firebasestorage.app',
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: iosApiKey,
    appId: '1:988783189852:ios:9d02bf12a6e8210911ab99',
    messagingSenderId: '988783189852',
    projectId: 'govimaga-862b8',
    storageBucket: 'govimaga-862b8.firebasestorage.app',
    iosBundleId: 'com.example.done',
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: iosApiKey,
    appId: '1:988783189852:ios:9d02bf12a6e8210911ab99',
    messagingSenderId: '988783189852',
    projectId: 'govimaga-862b8',
    storageBucket: 'govimaga-862b8.firebasestorage.app',
    iosBundleId: 'com.example.done',
  );

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: webApiKey,
    appId: '1:988783189852:web:76a360db2f83146e11ab99',
    messagingSenderId: '988783189852',
    projectId: 'govimaga-862b8',
    authDomain: 'govimaga-862b8.firebaseapp.com',
    storageBucket: 'govimaga-862b8.firebasestorage.app',
    measurementId: 'G-ZRYPR3TYN2',
  );

  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: webApiKey,
    appId: '1:988783189852:web:c692204ee0dcfb7011ab99',
    messagingSenderId: '988783189852',
    projectId: 'govimaga-862b8',
    authDomain: 'govimaga-862b8.firebaseapp.com',
    storageBucket: 'govimaga-862b8.firebasestorage.app',
    measurementId: 'G-348DGRZP55',
  );
}