import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  const AppStorage(this._preferences);

  final SharedPreferences _preferences;

  List<Map<String, dynamic>> readJsonList(String key) {
    final rawValue = _preferences.getString(key);
    if (rawValue == null || rawValue.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    final decoded = jsonDecode(rawValue);
    if (decoded is! List) {
      return const <Map<String, dynamic>>[];
    }

    return [
      for (final item in decoded)
        if (item is Map) Map<String, dynamic>.from(item),
    ];
  }

  Future<void> writeJsonList(String key, List<Map<String, dynamic>> value) {
    return _preferences.setString(key, jsonEncode(value));
  }

  String? readString(String key) {
    final rawValue = _preferences.getString(key);
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }
    return rawValue;
  }

  Future<void> writeString(String key, String value) {
    return _preferences.setString(key, value);
  }

  bool? readBool(String key) {
    return _preferences.getBool(key);
  }

  Future<void> writeBool(String key, bool value) {
    return _preferences.setBool(key, value);
  }
}
