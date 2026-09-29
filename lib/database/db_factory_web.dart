import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' as ffi_web;

/// Opens the app database on the web using sql.js compiled to wasm.
///
/// The `sqlite3.wasm` binary is served from the `web/` folder. We use the
/// no-web-worker factory so no extra shared-worker javascript file is needed.
Future<Database> openAppDatabase() async {
  return ffi_web.databaseFactoryFfiWebNoWebWorker
      .openDatabase('afridi_welfare_trust.db');
}