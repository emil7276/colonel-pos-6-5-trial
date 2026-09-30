import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._();
  ThemeController._();

  ThemeMode _mode = ThemeMode.system;
  String? _username;

  ThemeMode get mode => _mode;
  String? get username => _username;

  String _key(String username) => 'cp_theme_mode_$username';

  Future<void> loadForUser(String username) async {
    _username = username;
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key(username)) ?? 'system';
    _mode = _fromString(value);
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();

    final username = _username;
    if (username == null || username.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(username), _toString(mode));
  }

  void resetToSystem() {
    _username = null;
    _mode = ThemeMode.system;
    notifyListeners();
  }

  ThemeMode _fromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
