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
    apiKey: 'AIzaSyAc0kG1uCdTdLtZrXSGYtBlhJ18PUxwwlY',
    appId: '1:988783189852:web:76a360db2f83146e11ab99',
    messagingSenderId: '988783189852',
    projectId: 'govimaga-862b8',
    authDomain: 'govimaga-862b8.firebaseapp.com',
    storageBucket: 'govimaga-862b8.firebasestorage.app',
    measurementId: 'G-ZRYPR3TYN2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDkbBikykFcOo-pJkWVQKDac6qKoyMQvnc',
    appId: '1:988783189852:android:183fe343a82ed9f611ab99',
    messagingSenderId: '988783189852',
    projectId: 'govimaga-862b8',
    storageBucket: 'govimaga-862b8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAo6U7uAkvrYOBSjeqrR8JZWUL93wRsI1A',
    appId: '1:988783189852:ios:9d02bf12a6e8210911ab99',
    messagingSenderId: '988783189852',
    projectId: 'govimaga-862b8',
    storageBucket: 'govimaga-862b8.firebasestorage.app',
    iosBundleId: 'com.example.done',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAo6U7uAkvrYOBSjeqrR8JZWUL93wRsI1A',
    appId: '1:988783189852:ios:9d02bf12a6e8210911ab99',
    messagingSenderId: '988783189852',
    projectId: 'govimaga-862b8',
    storageBucket: 'govimaga-862b8.firebasestorage.app',
    iosBundleId: 'com.example.done',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAc0kG1uCdTdLtZrXSGYtBlhJ18PUxwwlY',
    appId: '1:988783189852:web:c692204ee0dcfb7011ab99',
    messagingSenderId: '988783189852',
    projectId: 'govimaga-862b8',
    authDomain: 'govimaga-862b8.firebaseapp.com',
    storageBucket: 'govimaga-862b8.firebasestorage.app',
    measurementId: 'G-348DGRZP55',
  );
}
