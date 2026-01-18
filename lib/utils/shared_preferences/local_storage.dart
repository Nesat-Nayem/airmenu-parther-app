import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  Future<String?> getString({required String localStorageKey}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(localStorageKey);
  }

  Future<bool> setString(
      {required String localStorageKey, required String value}) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(localStorageKey, value);
  }

  Future<bool?> getBool(String localStorageKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(localStorageKey);
  }

  Future<bool> setBool(
    String localStorageKey,
    bool value,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(localStorageKey, value);
  }

  Future<bool> remove({required String localStorageKey}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(localStorageKey);
  }
}
