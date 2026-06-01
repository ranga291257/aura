import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Birth year is stored only in the OS secure vault (Keychain / EncryptedSharedPreferences).
/// It is never written to SharedPreferences or included in profile JSON exports.
class BirthYearVault {
  static const _key = 'aura_birth_year';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<void> save(int year) async {
    await _storage.write(key: _key, value: year.toString());
  }

  static Future<int?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  static Future<void> delete() async {
    await _storage.delete(key: _key);
  }
}
