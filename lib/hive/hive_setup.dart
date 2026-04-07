import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveSetup {
  static Future<void> initialize() async {
    await Hive.initFlutter();
  }

  static Future<Uint8List> getEncryptionKey() async {
    const secureStorage = FlutterSecureStorage();
    String? keyString = await secureStorage.read(key: 'hive_key');

    if (keyString == null) {
      final key = Hive.generateSecureKey();
      keyString = base64Url.encode(key);
      await secureStorage.write(key: 'hive_key', value: keyString);
      print('✅ New secure Hive key generated');
    }

    return base64Url.decode(keyString);
  }

  static Future<void> openSettingsBox(Uint8List encryptionKey) async {
    await Hive.openBox(
      'settings',
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }
}
