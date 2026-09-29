import 'package:flutter/foundation.dart';

import '../database/db_helper.dart';
import '../models/settings_model.dart';

/// Persists and exposes app preferences backed by the SQLite `settings` table.
///
/// Uses [ValueNotifier]s so the whole app (including theme) can react to
/// changes without a state-management dependency.
class SettingsService {
  SettingsService._();

  /// Singleton instance.
  static final SettingsService instance = SettingsService._();

  /// Dark mode toggle.
  final ValueNotifier<bool> darkMode = ValueNotifier<bool>(false);

  /// Notifications toggle.
  final ValueNotifier<bool> notifications = ValueNotifier<bool>(true);

  /// Selected language.
  final ValueNotifier<String> language = ValueNotifier<String>('English');

  bool _loaded = false;

  /// Whether settings have been loaded from the database.
  bool get isLoaded => _loaded;

  /// Loads settings from the database (keeping defaults on any failure).
  Future<void> load() async {
    try {
      final AppSettings settings = await DbHelper.instance.getSettings();
      darkMode.value = settings.darkMode;
      notifications.value = settings.notifications;
      language.value = settings.language;
    } catch (_) {
      // Keep defaults when the database is not available.
    } finally {
      _loaded = true;
    }
  }

  Future<void> setDarkMode(bool value) async {
    darkMode.value = value;
    await _persist();
  }

  Future<void> setNotifications(bool value) async {
    notifications.value = value;
    await _persist();
  }

  Future<void> setLanguage(String value) async {
    language.value = value;
    await _persist();
  }

  Future<void> _persist() async {
    try {
      await DbHelper.instance.saveSetting(
        darkMode: darkMode.value,
        notifications: notifications.value,
        language: language.value,
      );
    } catch (_) {
      // Best effort persistence - settings remain active in memory.
    }
  }

  /// Resets settings to defaults and clears all local data.
  Future<void> clearAllData() async {
    await DbHelper.instance.clearLocalData();
    darkMode.value = false;
    notifications.value = true;
    language.value = 'English';
    _persist();
  }
}