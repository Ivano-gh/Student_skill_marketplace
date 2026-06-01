import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  String? _email;
  String? _username;
  bool _initialized = false;

  AuthProvider() {
    _loadSession();
  }

  bool get isLoggedIn => _accessToken != null && _accessToken!.isNotEmpty;
  String? get accessToken => _accessToken;
  String get email => _email ?? '';
  String get username => _username ?? '';
  String? get refreshToken => _refreshToken;
  bool get initialized => _initialized;

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    _email = prefs.getString('user_email');
    _username = prefs.getString('username');
    _initialized = true;
    notifyListeners();
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    String? email,
    String? username,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _email = email;
    _username = username;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    if (email != null) {
      await prefs.setString('user_email', email);
    }
    if (username != null) {
      await prefs.setString('username', username);
    }

    notifyListeners();
  }

  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    _email = null;
    _username = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_email');
    await prefs.remove('username');

    notifyListeners();
  }
}
