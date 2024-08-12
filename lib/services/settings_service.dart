import 'dart:async';
import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';

class SettingsService {
  // Singleton instance
  static SettingsService? _instance;

  // Variables
  final FirebaseRemoteConfig remoteConfig;
  Map<String, dynamic> _settingsMap = {};

  // Constructor
  SettingsService._() : remoteConfig = FirebaseRemoteConfig.instance;

  // Factory for singleton
  factory SettingsService() {
    return _instance ??= SettingsService._();
  }

  // Settings
  Map<String, dynamic> getSettings({bool reload = false}) {
    if (reload) {
      _settingsMap = jsonDecode(remoteConfig.getString('settings'));
    }
    return _settingsMap;
  }

  dynamic get(String name) {
    if (_settingsMap.containsKey(name)) {
      return _settingsMap[name];
    }
    return null;
  }

  int? getInt(String name) {
    if (_settingsMap.containsKey(name)) {
      try {
        return int.parse(_settingsMap[name]);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String? getString(String name) {
    if (_settingsMap.containsKey(name)) {
      try {
        return _settingsMap[name] as String;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  double? getDouble(String name) {
    if (_settingsMap.containsKey(name)) {
      try {
        return double.parse(_settingsMap[name]);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  List<dynamic>? getList(String name) {
    if (_settingsMap.containsKey(name)) {
      try {
        return _settingsMap[name] as List<dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  bool? getBool(String name) {
    if (_settingsMap.containsKey(name)) {
      try {
        return _settingsMap[name] as bool;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> _setConfigSettings() async {
    remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 12),
      ),
    );
  }

  Future<void> _setDefaults() async {
    remoteConfig.setDefaults(
      const {
        'settings': '{}',
      },
    );
  }

  Future<void> fetchAndActivate() async {
    await remoteConfig.fetchAndActivate();
  }

  Future<void> initialize({bool fetch = false}) async {
    // Set config
    await _setConfigSettings();

    // Set defaults
    await _setDefaults();

    // Fetch from server and activate
    // Wait only if fethcing for the first launch
    if (fetch == true) {
      try {
        await fetchAndActivate();
      } catch (e) {
        // Ignore fetch errors
      }
    } else {
      fetchAndActivate();
    }

    // Load setttings
    getSettings(reload: true);
  }
}
