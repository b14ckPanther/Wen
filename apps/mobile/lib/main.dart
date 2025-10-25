import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/settings/application/settings_controller.dart';
import 'features/settings/data/settings_repository.dart';

const bool kUseFirebaseEmulator = bool.fromEnvironment(
  'USE_FIREBASE_EMULATOR',
  defaultValue: false,
);
const String kFirebaseEmulatorHost = String.fromEnvironment(
  'FIREBASE_EMULATOR_HOST',
  defaultValue: 'localhost',
);
const int kFirestoreEmulatorPort = int.fromEnvironment(
  'FIREBASE_FIRESTORE_PORT',
  defaultValue: 8080,
);
const int kAuthEmulatorPort = int.fromEnvironment(
  'FIREBASE_AUTH_PORT',
  defaultValue: 9099,
);
const int kStorageEmulatorPort = int.fromEnvironment(
  'FIREBASE_STORAGE_PORT',
  defaultValue: 9199,
);

Future<void> _configureEmulators() async {
  if (!kUseFirebaseEmulator) return;

  FirebaseFirestore.instance.useFirestoreEmulator(
    kFirebaseEmulatorHost,
    kFirestoreEmulatorPort,
  );
  await FirebaseAuth.instance.useAuthEmulator(
    kFirebaseEmulatorHost,
    kAuthEmulatorPort,
  );
  FirebaseStorage.instance.useStorageEmulator(
    kFirebaseEmulatorHost,
    kStorageEmulatorPort,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _configureEmulators();
  final prefs = await SharedPreferences.getInstance();
  final settingsRepository = SettingsRepository(prefs);
  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepository),
      ],
      child: const WenApp(),
    ),
  );
}
