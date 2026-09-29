/// Conditional export selecting the correct SQLite factory per platform.
///
/// - Web           -> `db_factory_web.dart` (sql.js / wasm)
/// - IO (Android, iOS, Windows, Linux, macOS, VM tests) -> `db_factory_io.dart`
library;

export 'db_factory_stub.dart'
    if (dart.library.html) 'db_factory_web.dart'
    if (dart.library.io) 'db_factory_io.dart';