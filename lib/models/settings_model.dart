/// App settings model reflecting the `settings` table.
///
/// The table stores a single row (id = 1) holding the active preferences.
class AppSettings {
  final int? id;
  final bool darkMode;
  final bool notifications;
  final String language;

  const AppSettings({
    this.id,
    required this.darkMode,
    required this.notifications,
    required this.language,
  });

  factory AppSettings.fromMap(Map<String, Object?> map) {
    return AppSettings(
      id: map['id'] as int?,
      darkMode: ((map['dark_mode'] as int?) ?? 0) == 1,
      notifications: ((map['notifications'] as int?) ?? 1) == 1,
      language: (map['language'] as String?) ?? 'English',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'dark_mode': darkMode ? 1 : 0,
      'notifications': notifications ? 1 : 0,
      'language': language,
    };
  }
}