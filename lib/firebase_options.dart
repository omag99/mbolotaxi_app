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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCwpAYXZZAkNRhrVZ_KK2qeIMsZ701RR5Q", // REMPLACE !
    appId: "1:235335858292:web:a7199be49501306c20f921",
    messagingSenderId: "235335858292", // REMPLACE !
    projectId: "mbolotaxi-799cf",
    authDomain: "mbolotaxi-799cf.firebaseapp.com",
    storageBucket: "mbolotaxi-799cf.appspot.com", // REMPLACE !
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCwpAYXZZAkNRhrVZ_KK2qeIMsZ701RR5Q", // REMPLACE !
    appId: "1:235335858292:android:6cdbaf99ed536cd220f921",
    messagingSenderId: "235335858292", // REMPLACE !
    projectId: "mbolotaxi-799cf",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyCwpAYXZZAkNRhrVZ_KK2qeIMsZ701RR5Q", // REMPLACE !
    appId: "1:235335858292:ios:893150dee82e6af120f921",
    messagingSenderId: "235335858292", // REMPLACE !
    projectId: "mbolotaxi-799cf",
    iosClientId: "423423423423-sdfsdffsdfsdffsdfsd.apps.googleusercontent.com", // REMPLACE !
    iosBundleId: "com.example.mbolotaxiApp",
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "AIzaSyCwpAYXZZAkNRhrVZ_KK2qeIMsZ701RR5Q", // REMPLACE !
    appId: "1:235335858292:macos:a7199be49501306c20f921",  // EXAMPLE - Change if different
    messagingSenderId: "235335858292", // REMPLACE !
    projectId: "mbolotaxi-799cf",
    iosClientId: "423423423423-sdfsdffsdfsdffsdfsd.apps.googleusercontent.com", // REMPLACE !
    iosBundleId: "com.example.mbolotaxiApp",  //  Change if different
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: "AIzaSyCwpAYXZZAkNRhrVZ_KK2qeIMsZ701RR5Q", // REMPLACE !
    appId: "1:235335858292:windows:a7199be49501306c20f921",  // REMPLACE !
    messagingSenderId: "235335858292", // REMPLACE !
    projectId: "mbolotaxi-799cf",
  );
}