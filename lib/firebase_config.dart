import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseConfig {
  static Future<FirebaseOptions> get currentPlatform async {
    if (kIsWeb) {
      throw UnsupportedError('Not configured for web.');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _android;
      case TargetPlatform.iOS:
        return _ios;
      default:
        throw UnsupportedError('This platform is not supported.');
    }
  }

  // Chaves Android
  static final FirebaseOptions _android = FirebaseOptions(
    apiKey: dotenv.env['ANDROID_API_KEY']!,
    appId: dotenv.env['ANDROID_APP_ID']!,
    messagingSenderId: dotenv.env['SENDER_ID']!,
    projectId: dotenv.env['PROJECT_ID']!,
    storageBucket: dotenv.env['STORAGE_BUCKET']!,
  );

  // Chaves iOS
  static final FirebaseOptions _ios = FirebaseOptions(
    apiKey: dotenv.env['IOS_API_KEY']!,
    appId: dotenv.env['IOS_APP_ID']!,
    messagingSenderId: dotenv.env['SENDER_ID']!,
    projectId: dotenv.env['PROJECT_ID']!,
    storageBucket: dotenv.env['STORAGE_BUCKET']!,
    iosBundleId: dotenv.env['BUNDLE_ID']!,
  );
}
