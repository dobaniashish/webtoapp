import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Singleton instance
  static PreferencesService? _instance;

  // Variables
  late SharedPreferences sharedPreferences;

  // Constructor
  PreferencesService._();

  // Factory for singleton
  factory PreferencesService() {
    return _instance ??= PreferencesService._();
  }

  Future<bool> setBool(String key, bool value) => sharedPreferences.setBool(key, value);

  bool? getBool(String name) => sharedPreferences.getBool(name);
  
  Future<bool> setInt(String key, int value) => sharedPreferences.setInt(key, value);

  int? getInt(String name) => sharedPreferences.getInt(name);

  Future<void> initialize() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }
}
