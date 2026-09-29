import 'package:sqflite_common/sqlite_api.dart';

/// Fallback used only when neither `dart.library.html` nor
/// `dart.library.io` is available (which should never happen in practice).
Future<Database> openAppDatabase() {
  throw UnsupportedError('Unsupported platform for database factory');
}