import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

/// Resolves the SQLite file name.
///
/// The app always uses `afridi_welfare_trust.db`. During `flutter test` each
/// test file runs in its own isolate; sharing a single file between suites
/// running in parallel produces `database is locked` errors, so tests get a
/// unique file per isolate instead. The value is computed once per isolate so
/// that closing and reopening the database (simulating an app restart) still
/// uses the same file.
final String _databaseFileName = _resolveDatabaseFileName();

String _resolveDatabaseFileName() {
  const String appName = 'afridi_welfare_trust.db';

  if (Platform.environment['FLUTTER_TEST'] != 'true') return appName;

  final stamp = DateTime.now().microsecondsSinceEpoch;
  return 'afridi_welfare_trust_test_${pid}_$stamp.db';
}

/// Opens the app database on IO platforms.
///
/// Android / iOS / macOS use the native `sqflite` plugin while Windows and
/// Linux desktop builds use `sqflite_common_ffi` (bundled sqlite3 via
/// `sqlite3_flutter_libs`).
Future<sqflite.Database> openAppDatabase() async {
  final dbName = _databaseFileName;

  if (Platform.isWindows || Platform.isLinux) {
    ffi.sqfliteFfiInit();
    final factory = ffi.databaseFactoryFfiNoIsolate;
    final dir = await factory.getDatabasesPath();
    return factory.openDatabase(p.join(dir, dbName));
  }

  final dir = await sqflite.getDatabasesPath();
  return sqflite.openDatabase(p.join(dir, dbName));
}
