import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _userInfoKey = 'user_info';
  static const String _accessTokenKey = 'access_token';

  // Save user information
  static Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userInfoKey, json.encode(userInfo));
  }

  // Retrieve user information
  static Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userInfoString = prefs.getString(_userInfoKey);
    if (userInfoString == null) return null;
    return json.decode(userInfoString) as Map<String, dynamic>;
  }

  // Save access token
  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  // Retrieve access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Clear all stored data
  static Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userInfoKey);
    await prefs.remove(_accessTokenKey);
  }
}