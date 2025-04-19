import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  static const int defaultIntValue = -999;
  static const double defaultDoubleValue = -999.00;
  static const String _expiryKey = "token_expiry";

  static Future<bool> saveStringPreference(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.setString(key, value);
    } catch (e) {
      debugPrint('$e?');
      return Future.value(false);
    }
  }

  static Future<bool> saveIntPreference(String key, int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.setInt(key, value);
    } catch (e) {
      debugPrint('$e?');
      return Future.value(false);
    }
  }

  static Future<bool> saveBoolPreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.setBool(key, value);
    } catch (e) {
      debugPrint('$e?');
      return Future.value(false);
    }
  }

  static Future<bool?> saveDoublePreference(String? key, double? value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.setDouble(key!, value!);
    } catch (e) {
      debugPrint('$e?');
      return Future.value(false);
    }
  }

  static Future<String?> getStringPreference(String? key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key!) != null ? prefs.getString(key) : "";
    } catch (e) {
      debugPrint('$e?');
      return Future.value("");
    }
  }

  static Future<int?> getIntPreference(String? key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(key!) != null ? prefs.getInt(key) : defaultIntValue;
    } catch (e) {
      debugPrint('$e');
      return Future.value(defaultIntValue);
    }
  }

  static Future<bool?> getBoolPreference(String? key)  async{
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key!) != null ? prefs.getBool(key) : false;
    } catch (e) {
      debugPrint('$e');
      return Future.value(false);
    }
  }

  static Future<double?> getDoublePreference(String? key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(key!) != null
          ? prefs.getDouble(key)
          : defaultDoubleValue;
    } catch (e) {
      debugPrint('$e');
      return Future.value(defaultDoubleValue);
    }
  }

  static Future<bool> removePreference(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.remove(key);
    } catch (e) {
      debugPrint('$e');
      return Future.value(false);
    }
  }

  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  static Future<void> saveRefreshToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('refreshToken', token);
  }

  static Future<String?> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  /// Save token expiry timestamp (in milliseconds)
  static Future<void> saveTokenExpiry(int expiryTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_expiryKey, expiryTime);
  }

  /// Retrieve token expiry timestamp
  static Future<int?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_expiryKey);
  }

}
