import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'secure_storage_key.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> setString({required String key, String? value}) async {
    return _storage.write(key: key, value: value);
  }

  Future<String?> getString({
    required String key,
  }) async {
    return _storage.read(key: key);
  }

  Future<void> remove({required String key}) async {
    return _storage.delete(key: key);
  }
}
