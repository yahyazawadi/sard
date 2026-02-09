// lib/custom/hive_setup.dart
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/entry_model.dart'; // Your CycleEntry & adapter

class HiveSetup {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CycleEntryAdapter());
  }

  static Future<Uint8List> getEncryptionKey() async {
    const secureStorage = FlutterSecureStorage();
    String? keyString = await secureStorage.read(key: 'hive_key');

    if (keyString == null) {
      // Generate a random 32-byte key (AES-256)
      keyString = base64Url.encode(
        List<int>.generate(32, (i) => DateTime.now().microsecond % 256),
      );
      await secureStorage.write(key: 'hive_key', value: keyString);
    }

    return base64Url.decode(keyString);
  }

  static Future<Map<String, dynamic>> openBoxes(Uint8List encryptionKey) async {
    final cyclesBox = await Hive.openBox<CycleEntry>(
      'cycles',
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    final settingsBox = await Hive.openBox(
      'settings',
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    return {'cyclesBox': cyclesBox, 'settingsBox': settingsBox};
  }

  static Future<void> openCyclesBox(Uint8List encryptionKey) async {}
}
