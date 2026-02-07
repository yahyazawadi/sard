// lib/core/hive_init.dart - Complete encrypted Hive setup
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'package:tracker/models/entry_model.dart';

const _storage = FlutterSecureStorage();
const _keyName = 'hive_enc_key';

Future<void> initEncryptedHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(CycleEntryAdapter());
  String? keyBase64 = await _storage.read(key: _keyName);
  if (keyBase64 == null) {
    final newKey = Hive.generateSecureKey();
    // this is the part that makes the random password
    keyBase64 = base64UrlEncode(newKey);
    await _storage.write(key: _keyName, value: keyBase64);
    print('New encryption key created and saved securely');
  }

  final encryptionKey = base64Url.decode(keyBase64);

  // Open main data boxes (encrypted)
  await Hive.openBox('cycles', encryptionCipher: HiveAesCipher(encryptionKey));
  await Hive.openBox(
    'settings',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );

  print('Encrypted Hive boxes opened: cycles, settings');
}
