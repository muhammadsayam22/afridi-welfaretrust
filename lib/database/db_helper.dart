import 'package:sqflite/sqflite.dart';

import '../models/contact_model.dart';
import '../models/donation_model.dart';
import '../models/gallery_model.dart';
import '../models/project_model.dart';
import '../models/settings_model.dart';
import '../models/volunteer_model.dart';
import 'db_factory.dart';
import 'database_seed.dart';

/// SQLite database helper for the Afridi Welfare Trust app.
///
/// Tables: users, donations, volunteers, contacts, settings, projects,
/// education, food, medical, clean_water, gallery.
/// All CRUD methods are safe to call and never throw user-facing errors.
class DbHelper {
  DbHelper._();

  /// Singleton instance.
  static final DbHelper instance = DbHelper._();

  Database? _db;
  bool _offline = false;

  /// Whether the SQLite database is currently usable.
  bool get isOffline => _offline;

  /// Forces the database to open once at startup so it is ready before the
  /// UI renders. Also runs table creation and one-time seeding.
  Future<bool> initializeDatabase() async {
    final db = await database;
    return db != null;
  }

  /// Closes the open database handle so the next access re-opens it from disk.
  /// Used by tests to simulate an app restart.
  Future<void> closeDatabase() async {
    try {
      await _db?.close();
    } catch (_) {
      // Ignore close failures.
    } finally {
      _db = null;
    }
  }

  /// Opens (and lazily creates) the database and returns the handle.
  ///
  /// Transient failures (for example a temporarily locked database file)
  /// are retried a few times before the helper falls back to offline mode,
  /// so a short lock never disables the database for the whole session.
  Future<Database?> get database async {
    if (_db != null) return _db;
    if (_offline) return null;

    for (var attempt = 0; attempt < 3; attempt++) {
      Database? db;
      try {
        db = await openAppDatabase();
        await _createTables(db);
        await _addVolunteerColumns(db);
        await _addDonationColumns(db);
        await _addManagementColumns(db);
        await _seedIfEmpty(db);
        _db = db;
        return db;
      } catch (_) {
        try {
          await db?.close();
        } catch (_) {
          // Ignore close failures while recovering.
        }

        if (attempt == 2) {
          _offline = true;
          return null;
        }

        // Brief back-off so a concurrent opener can release its lock.
        await Future<void>.delayed(Duration(milliseconds: 150 * (attempt + 1)));
      }
    }

    _offline = true;
    return null;
  }

  /// Inserts demo seed data for the category tables only when they are empty
  /// so records are never duplicated on every app start.
  Future<void> _seedIfEmpty(Database db) async {
    try {
      final educationCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) as c FROM education'),
      );
      if (educationCount == 0) {
        for (final item in DatabaseSeed.getEducationSeeds()) {
          await db.insert('education', item.toMap());
        }
      }

      final foodCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) as c FROM food'),
      );
      if (foodCount == 0) {
        for (final item in DatabaseSeed.getFoodSeeds()) {
          await db.insert('food', item.toMap());
        }
      }

      final medicalCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) as c FROM medical'),
      );
      if (medicalCount == 0) {
        for (final item in DatabaseSeed.getMedicalSeeds()) {
          await db.insert('medical', item.toMap());
        }
      }

      final waterCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) as c FROM clean_water'),
      );
      if (waterCount == 0) {
        for (final item in DatabaseSeed.getCleanWaterSeeds()) {
          await db.insert('clean_water', item.toMap());
        }
      }
    } catch (_) {
      // Seeding is best-effort and never blocks the app.
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        email TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS donations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        donor_name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        amount REAL NOT NULL,
        category TEXT,
        payment_method TEXT,
        transaction_id TEXT,
        message TEXT,
        donation_date TEXT,
        status TEXT DEFAULT 'Pending',
        receipt_number TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS volunteers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        city TEXT,
        area TEXT,
        availability TEXT,
        message TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        subject TEXT,
        message TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        id INTEGER PRIMARY KEY,
        dark_mode INTEGER DEFAULT 0,
        notifications INTEGER DEFAULT 1,
        language TEXT DEFAULT "English"
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        image TEXT,
        category TEXT,
        status TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS education (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        image TEXT,
        record_type TEXT DEFAULT '$kProgramRecordType',
        guardian_name TEXT,
        class_level TEXT,
        institute TEXT,
        contact TEXT,
        area TEXT,
        status TEXT,
        record_date TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS food (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        image TEXT,
        record_type TEXT DEFAULT '$kProgramRecordType',
        family_members TEXT,
        package_type TEXT,
        quantity TEXT,
        contact TEXT,
        area TEXT,
        distribution_date TEXT,
        status TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS medical (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        image TEXT,
        record_type TEXT DEFAULT '$kProgramRecordType',
        age TEXT,
        contact TEXT,
        medical_issue TEXT,
        treatment TEXT,
        doctor TEXT,
        area TEXT,
        assistance TEXT,
        record_date TEXT,
        status TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS clean_water (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        image TEXT,
        record_type TEXT DEFAULT '$kProgramRecordType',
        location TEXT,
        water_type TEXT,
        beneficiaries TEXT,
        estimated_cost TEXT,
        status TEXT,
        start_date TEXT,
        completion_date TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS gallery (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        file_path TEXT NOT NULL,
        media_type TEXT NOT NULL DEFAULT '${GalleryMediaTypes.photo}',
        created_at TEXT NOT NULL
      )
    ''');
  }

  /// Tables that hold the management records created from the
  /// Education / Food / Medical / Clean Water management screens together
  /// with the columns those screens add on top of the original category
  /// schema (`title`, `description`, `image`, `created_at`).
  static const Map<String, List<String>> _managementColumns = {
    'education': [
      'record_type',
      'guardian_name',
      'class_level',
      'institute',
      'contact',
      'area',
      'status',
      'record_date',
    ],
    'food': [
      'record_type',
      'family_members',
      'package_type',
      'quantity',
      'contact',
      'area',
      'distribution_date',
      'status',
    ],
    'medical': [
      'record_type',
      'age',
      'contact',
      'medical_issue',
      'treatment',
      'doctor',
      'area',
      'assistance',
      'record_date',
      'status',
    ],
    'clean_water': [
      'record_type',
      'location',
      'water_type',
      'beneficiaries',
      'estimated_cost',
      'status',
      'start_date',
      'completion_date',
    ],
  };

  /// Tables that may be written to through the generic management CRUD
  /// helpers. Used as a whitelist so a table name can never be injected
  /// into a raw SQL statement.
  static const Set<String> managementTables = {
    'education',
    'food',
    'medical',
    'clean_water',
  };

  /// Adds the management columns to the category tables of existing
  /// installations. This is a safe additive migration: nothing is dropped,
  /// no existing row is deleted and older rows simply gain the new columns
  /// (with `record_type` back-filled to `program` so the public category
  /// pages keep showing exactly the same content as before).
  Future<void> _addManagementColumns(Database db) async {
    for (final entry in _managementColumns.entries) {
      try {
        final rows = await db.rawQuery('PRAGMA table_info(${entry.key})');
        final existing = rows.map((row) => row['name'] as String?).toSet();

        for (final column in entry.value) {
          if (existing.contains(column)) continue;
          if (column == 'record_type') {
            await db.execute(
                "ALTER TABLE ${entry.key} ADD COLUMN record_type TEXT "
                "DEFAULT '$kProgramRecordType'");
          } else {
            await db.execute(
                'ALTER TABLE ${entry.key} ADD COLUMN $column TEXT');
          }
        }

        // Older rows are always public category entries.
        await db.execute(
            "UPDATE ${entry.key} SET record_type = '$kProgramRecordType' "
            'WHERE record_type IS NULL');
      } catch (_) {
        // Best-effort migration - never blocks the app.
      }
    }
  }

  /// Returns the current column names of [table] (empty for unknown tables).
  Future<Set<String>> _tableColumns(Database db, String table) async {
    if (!managementTables.contains(table) && table != 'gallery') {
      return <String>{};
    }
    try {
      final rows = await db.rawQuery('PRAGMA table_info($table)');
      return rows.map((row) => row['name'] as String?).whereType<String>().toSet();
    } catch (_) {
      return <String>{};
    }
  }

  /// Adds the `city` and `availability` columns to an existing `volunteers`
  /// table if they are missing. This is a safe additive migration that never
  /// touches existing rows, so older databases simply gain the new columns.
  Future<void> _addVolunteerColumns(Database db) async {
    try {
      final rows = await db.rawQuery('PRAGMA table_info(volunteers)');
      final columns =
          rows.map((row) => row['name'] as String?).toSet();

      if (!columns.contains('city')) {
        await db.execute('ALTER TABLE volunteers ADD COLUMN city TEXT');
      }
      if (!columns.contains('availability')) {
        await db.execute(
            'ALTER TABLE volunteers ADD COLUMN availability TEXT');
      }
    } catch (_) {
      // Best-effort migration - never blocks the app.
    }
  }

  /// Adds the donation management columns (`category`, `transaction_id`,
  /// `donation_date`, `status`, `receipt_number`) to an existing
  /// `donations` table if they are missing. This is a safe additive
  /// migration that never touches existing rows - older databases simply
  /// gain the new columns while their existing records are back-filled with
  /// sensible defaults (Pending status, a generated receipt number and the
  /// created date as the donation date).
  Future<void> _addDonationColumns(Database db) async {
    try {
      final rows = await db.rawQuery('PRAGMA table_info(donations)');
      final columns =
          rows.map((row) => row['name'] as String?).toSet();

      if (!columns.contains('category')) {
        await db.execute('ALTER TABLE donations ADD COLUMN category TEXT');
      }
      if (!columns.contains('transaction_id')) {
        await db.execute(
            'ALTER TABLE donations ADD COLUMN transaction_id TEXT');
      }
      if (!columns.contains('donation_date')) {
        await db.execute('ALTER TABLE donations ADD COLUMN donation_date TEXT');
      }
      if (!columns.contains('status')) {
        await db.execute(
            "ALTER TABLE donations ADD COLUMN status TEXT DEFAULT 'Pending'");
      }
      if (!columns.contains('receipt_number')) {
        await db.execute(
            'ALTER TABLE donations ADD COLUMN receipt_number TEXT');
      }

      // Back-fill older rows with safe defaults.
      await db.rawUpdate(
          "UPDATE donations SET donation_date = substr(created_at, 1, 10) "
          "WHERE donation_date IS NULL OR donation_date = ''");
      await db.rawUpdate(
          "UPDATE donations SET status = 'Pending' "
          "WHERE status IS NULL OR status = ''");
      await db.rawUpdate(
          "UPDATE donations SET category = purpose "
          "WHERE (category IS NULL OR category = '') "
          "AND purpose IS NOT NULL AND purpose != ''");

      final missingReceipts = await db.query(
        'donations',
        columns: ['id'],
        where: "receipt_number IS NULL OR receipt_number = ''",
      );
      for (final row in missingReceipts) {
        final id = row['id'];
        if (id == null) continue;
        final receipt = await _nextReceiptNumber(db);
        await db.rawUpdate(
          'UPDATE donations SET receipt_number = ? WHERE id = ?',
          [receipt, id],
        );
      }
    } catch (_) {
      // Best-effort migration - never blocks the app.
    }
  }

  /// Builds the next unique receipt number (e.g. `AWT-DON-000001`) by
  /// scanning the highest numbered receipt already in the table. Called
  /// inside a transaction so parallel saves can never produce duplicates.
  Future<String> _nextReceiptNumber(DatabaseExecutor db) async {
    const prefix = 'AWT-DON-';
    var maxNumber = 0;
    final rows = await db.rawQuery(
      'SELECT receipt_number FROM donations '
      'WHERE receipt_number IS NOT NULL AND receipt_number != ?',
      [''],
    );
    for (final row in rows) {
      final value = (row['receipt_number'] as String?) ?? '';
      if (value.startsWith(prefix)) {
        final number = int.tryParse(value.substring(prefix.length));
        if (number != null && number > maxNumber) maxNumber = number;
      }
    }
    return '$prefix${(maxNumber + 1).toString().padLeft(6, '0')}';
  }

  // ==============================================================
  // DONATIONS
  // ==============================================================

  /// Inserts a donation and returns the new row id (null when offline).
  ///
  /// Always writes a unique receipt number (auto-generated when none is
  /// supplied) and defaults the status to `Pending` and the donation date to
  /// today when either is empty. The whole insert runs inside a transaction
  /// so receipt numbers can never be duplicated.
  Future<int?> insertDonation(Donation donation) async {
    final db = await database;
    if (db == null) return null;
    return db.transaction((txn) async {
      final data = Map<String, Object?>.from(donation.toMap());
      data.remove('id');

      var status = (data['status'] as String? ?? '').trim();
      if (status.isEmpty) status = DonationConstants.statusPending;
      data['status'] = status;

      var receiptNumber = (data['receipt_number'] as String? ?? '').trim();
      if (receiptNumber.isEmpty) {
        receiptNumber = await _nextReceiptNumber(txn);
      }
      data['receipt_number'] = receiptNumber;

      var donationDate = (data['donation_date'] as String? ?? '').trim();
      if (donationDate.isEmpty) {
        donationDate = _dateOnly(DateTime.now());
      }
      data['donation_date'] = donationDate;

      return txn.insert('donations', data);
    });
  }

  /// Returns donations newest first with optional search and filter terms.
  ///
  /// [search] matches donor name, phone, receipt number or transaction ID.
  /// [status] and [category] filter by exact value. [dateFrom] / [dateTo]
  /// are `yyyy-MM-dd` strings used to bound the donation date.
  Future<List<Donation>> getDonations({
    String? search,
    String? status,
    String? category,
    String? dateFrom,
    String? dateTo,
  }) async {
    final db = await database;
    if (db == null) return [];

    final conditions = <String>[];
    final args = <Object?>[];

    final query = search?.trim() ?? '';
    if (query.isNotEmpty) {
      final like = '%$query%';
      conditions.add(
          '(donor_name LIKE ? OR phone LIKE ? OR receipt_number LIKE ? '
          'OR transaction_id LIKE ?)');
      args.addAll([like, like, like, like]);
    }
    if (status != null && status.isNotEmpty) {
      conditions.add('status = ?');
      args.add(status);
    }
    if (category != null && category.isNotEmpty) {
      conditions.add('category = ?');
      args.add(category);
    }
    if (dateFrom != null && dateFrom.isNotEmpty) {
      conditions.add('donation_date >= ?');
      args.add(dateFrom);
    }
    if (dateTo != null && dateTo.isNotEmpty) {
      conditions.add('donation_date <= ?');
      args.add(dateTo);
    }

    final rows = await db.query(
      'donations',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'id DESC',
    );
    return rows.map(Donation.fromMap).toList();
  }

  /// Changes only the status of an existing donation row in place so no
  /// duplicate record is ever created.
  Future<int?> updateDonationStatus(int id, String status) async {
    final db = await database;
    if (db == null) return null;
    return db.update(
      'donations',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Calculates donation totals directly from the database.
  Future<DonationStats> donationStats() async {
    final db = await database;
    if (db == null) return const DonationStats.empty();

    try {
      final total = await db.rawQuery(
        'SELECT COUNT(*) AS count, COALESCE(SUM(amount), 0) AS total '
        'FROM donations',
      );
      final statusCounts = await db.rawQuery(
        'SELECT status, COUNT(*) AS count FROM donations GROUP BY status',
      );

      int countFor(String status) {
        for (final row in statusCounts) {
          if ((row['status'] as String? ?? '') == status) {
            return (row['count'] as int?) ?? 0;
          }
        }
        return 0;
      }

      final first = total.isEmpty ? null : total.first;
      return DonationStats(
        totalDonations: (first?['count'] as int?) ?? 0,
        totalAmount: ((first?['total'] as num?) ?? 0).toDouble(),
        pendingCount: countFor(DonationConstants.statusPending),
        verifiedCount: countFor(DonationConstants.statusVerified),
        rejectedCount: countFor(DonationConstants.statusRejected),
      );
    } catch (_) {
      return const DonationStats.empty();
    }
  }

  /// Converts a date to the `yyyy-MM-dd` key used for the donation date.
  String _dateOnly(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  /// Updates an existing donation and returns the number of rows changed.
  Future<int?> updateDonation(Donation donation) async {
    final db = await database;
    if (db == null || donation.id == null) return null;
    return db.update(
      'donations',
      donation.toMap(),
      where: 'id = ?',
      whereArgs: [donation.id],
    );
  }

  /// Deletes a donation by id and returns the number of rows removed.
  Future<int?> deleteDonation(int id) async {
    final db = await database;
    if (db == null) return null;
    return db.delete(
      'donations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> donationCount() async {
    final db = await database;
    if (db == null) return 0;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM donations');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==============================================================
  // VOLUNTEERS
  // ==============================================================

  /// Inserts a volunteer and returns the new row id (null when offline).
  Future<int?> insertVolunteer(Volunteer volunteer) async {
    final db = await database;
    if (db == null) return null;
    return db.insert('volunteers', volunteer.toMap());
  }

  Future<List<Volunteer>> getVolunteers() async {
    final db = await database;
    if (db == null) return [];
    final rows = await db.query(
      'volunteers',
      orderBy: 'id DESC',
    );
    return rows.map(Volunteer.fromMap).toList();
  }

  /// Updates an existing volunteer and returns the number of rows changed.
  Future<int?> updateVolunteer(Volunteer volunteer) async {
    final db = await database;
    if (db == null || volunteer.id == null) return null;
    return db.update(
      'volunteers',
      volunteer.toMap(),
      where: 'id = ?',
      whereArgs: [volunteer.id],
    );
  }

  /// Deletes a volunteer by id and returns the number of rows removed.
  Future<int?> deleteVolunteer(int id) async {
    final db = await database;
    if (db == null) return null;
    return db.delete(
      'volunteers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> volunteerCount() async {
    final db = await database;
    if (db == null) return 0;
    final result =
        await db.rawQuery('SELECT COUNT(*) as c FROM volunteers');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==============================================================
  // CONTACTS
  // ==============================================================

  /// Inserts a contact message and returns the new row id (null when offline).
  Future<int?> insertContact(ContactMessage contact) async {
    final db = await database;
    if (db == null) return null;
    return db.insert('contacts', contact.toMap());
  }

  Future<List<ContactMessage>> getContacts() async {
    final db = await database;
    if (db == null) return [];
    final rows = await db.query(
      'contacts',
      orderBy: 'id DESC',
    );
    return rows.map(ContactMessage.fromMap).toList();
  }

  /// Deletes a contact message by id and returns the number of rows removed.
  Future<int?> deleteContact(int id) async {
    final db = await database;
    if (db == null) return null;
    return db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> contactCount() async {
    final db = await database;
    if (db == null) return 0;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM contacts');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==============================================================
  // PROJECTS
  // ==============================================================

  /// Inserts a project and returns the new row id (null when offline).
  Future<int?> insertProject(Project project) async {
    final db = await database;
    if (db == null) return null;
    return db.insert('projects', project.toMap());
  }

  /// Returns all projects ordered newest first.
  Future<List<Project>> getProjects() async {
    final db = await database;
    if (db == null) return [];
    final rows = await db.query(
      'projects',
      orderBy: 'id DESC',
    );
    return rows.map(Project.fromMap).toList();
  }

  /// Returns projects filtered by category (e.g. 'Education').
  Future<List<Project>> getProjectsByCategory(String category) async {
    final db = await database;
    if (db == null) return [];
    final rows = await db.query(
      'projects',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'id DESC',
    );
    return rows.map(Project.fromMap).toList();
  }

  /// Updates an existing project and returns the number of rows changed.
  Future<int?> updateProject(Project project) async {
    final db = await database;
    if (db == null || project.id == null) return null;
    return db.update(
      'projects',
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  /// Deletes a project by id and returns the number of rows removed.
  Future<int?> deleteProject(int id) async {
    final db = await database;
    if (db == null) return null;
    return db.delete(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==============================================================
  // CATEGORY TABLES (education / food / medical / clean_water)
  // ==============================================================

  /// Public category rows shown on the Education category page. Records
  /// created through the Education Management screen are filtered out so
  /// both views stay independent.
  Future<List<Education>> getEducationProjects() async {
    final db = await database;
    if (db == null) return [];
    final rows = await db.query(
      'education',
      where: 'record_type IS NULL OR record_type != ?',
      whereArgs: [kManagementRecordType],
      orderBy: 'id DESC',
    );
    return rows.map(Education.fromMap).toList();
  }

  Future<List<Food>> getFoodProjects() async {
    final db = await database;
    if (db == null) return [];
    final rows = await db.query(
      'food',
      where: 'record_type IS NULL OR record_type != ?',
      whereArgs: [kManagementRecordType],
      orderBy: 'id DESC',
    );
    return rows.map(Food.fromMap).toList();
  }

  Future<List<Medical>> getMedicalProjects() async {
    final db = await database;
    if (db == null) return [];
    final rows = await db.query(
      'medical',
      where: 'record_type IS NULL OR record_type != ?',
      whereArgs: [kManagementRecordType],
      orderBy: 'id DESC',
    );
    return rows.map(Medical.fromMap).toList();
  }

  Future<List<CleanWater>> getCleanWaterProjects() async {
    final db = await database;
    if (db == null) return [];
    final rows = await db.query(
      'clean_water',
      where: 'record_type IS NULL OR record_type != ?',
      whereArgs: [kManagementRecordType],
      orderBy: 'id DESC',
    );
    return rows.map(CleanWater.fromMap).toList();
  }

  Future<int> projectCount(String table) async {
    final db = await database;
    if (db == null) return 0;
    final result =
        await db.rawQuery('SELECT COUNT(*) as c FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==============================================================
  // MANAGEMENT RECORDS (education / food / medical / clean_water)
  // ==============================================================

  /// Returns management rows of [table] newest first.
  ///
  /// Only rows created through the management screens are returned - the
  /// public category "program" rows are never included. [search] matches the
  /// columns listed in [searchColumns] (unknown columns are ignored) and
  /// [status] filters by exact status value.
  Future<List<Map<String, Object?>>> getManagementRecords(
    String table, {
    String search = '',
    String? status,
    List<String> searchColumns = const [],
  }) async {
    if (!managementTables.contains(table)) return const [];

    final db = await database;
    if (db == null) return const [];

    final conditions = <String>['record_type = ?'];
    final args = <Object?>[kManagementRecordType];

    final query = search.trim();
    if (query.isNotEmpty && searchColumns.isNotEmpty) {
      final columns = await _tableColumns(db, table);
      final usable = searchColumns.where(columns.contains).toList();
      if (usable.isNotEmpty) {
        final like = '%$query%';
        conditions.add('(${usable.map((c) => '$c LIKE ?').join(' OR ')})');
        args.addAll(List<Object?>.filled(usable.length, like));
      }
    }

    if (status != null && status.trim().isNotEmpty) {
      conditions.add('status = ?');
      args.add(status.trim());
    }

    try {
      final rows = await db.query(
        table,
        where: conditions.join(' AND '),
        whereArgs: args,
        orderBy: 'id DESC',
      );
      return rows;
    } catch (_) {
      return const [];
    }
  }

  /// Inserts a management record and returns the new row id (null offline).
  ///
  /// The row is always marked as a management record and receives a
  /// `created_at` timestamp when none is supplied. Unknown columns are
  /// dropped so a bad field can never break the insert.
  Future<int?> insertManagementRecord(
    String table,
    Map<String, Object?> values,
  ) async {
    if (!managementTables.contains(table)) return null;

    final db = await database;
    if (db == null) return null;

    try {
      final columns = await _tableColumns(db, table);
      final data = <String, Object?>{};
      values.forEach((key, value) {
        if (columns.contains(key) && key != 'id') data[key] = value;
      });

      data['record_type'] = kManagementRecordType;
      final createdAt = (data['created_at'] as String?) ?? '';
      if (createdAt.trim().isEmpty) {
        data['created_at'] = DateTime.now().toIso8601String();
      }

      return await db.insert(table, data);
    } catch (_) {
      return null;
    }
  }

  /// Updates an existing management record and returns the rows changed.
  Future<int?> updateManagementRecord(
    String table,
    int id,
    Map<String, Object?> values,
  ) async {
    if (!managementTables.contains(table)) return null;

    final db = await database;
    if (db == null) return null;

    try {
      final columns = await _tableColumns(db, table);
      final data = <String, Object?>{};
      values.forEach((key, value) {
        if (columns.contains(key) && key != 'id' && key != 'created_at') {
          data[key] = value;
        }
      });
      if (data.isEmpty) return 0;

      return await db.update(
        table,
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (_) {
      return null;
    }
  }

  /// Deletes a management record by id and returns the rows removed.
  Future<int?> deleteManagementRecord(String table, int id) async {
    if (!managementTables.contains(table)) return null;

    final db = await database;
    if (db == null) return null;

    try {
      return await db.delete(
        table,
        where: 'id = ? AND record_type = ?',
        whereArgs: [id, kManagementRecordType],
      );
    } catch (_) {
      return null;
    }
  }

  /// Number of management records stored for [table].
  Future<int> managementRecordCount(String table) async {
    if (!managementTables.contains(table)) return 0;

    final db = await database;
    if (db == null) return 0;
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as c FROM $table WHERE record_type = ?',
        [kManagementRecordType],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // ==============================================================
  // GALLERY
  // ==============================================================

  /// Inserts a gallery media entry and returns the new row id.
  Future<int?> insertGallery(GalleryItem item) async {
    final db = await database;
    if (db == null) return null;

    try {
      final data = Map<String, Object?>.from(item.toMap());
      data.remove('id');
      var createdAt = (data['created_at'] as String?) ?? '';
      if (createdAt.trim().isEmpty) {
        createdAt = DateTime.now().toIso8601String();
      }
      data['created_at'] = createdAt;
      return await db.insert('gallery', data);
    } catch (_) {
      return null;
    }
  }

  /// Returns gallery media newest first with optional search + type filter.
  Future<List<GalleryItem>> getGalleryItems({
    String search = '',
    String? mediaType,
  }) async {
    final db = await database;
    if (db == null) return [];

    final conditions = <String>[];
    final args = <Object?>[];

    final query = search.trim();
    if (query.isNotEmpty) {
      conditions.add('title LIKE ?');
      args.add('%$query%');
    }
    if (mediaType != null && mediaType.trim().isNotEmpty) {
      conditions.add('media_type = ?');
      args.add(mediaType.trim());
    }

    try {
      final rows = await db.query(
        'gallery',
        where: conditions.isEmpty ? null : conditions.join(' AND '),
        whereArgs: args.isEmpty ? null : args,
        orderBy: 'id DESC',
      );
      return rows.map(GalleryItem.fromMap).toList();
    } catch (_) {
      return [];
    }
  }

  /// Deletes a gallery entry by id (the media file itself is removed by
  /// the gallery screen through the storage helper).
  Future<int?> deleteGalleryItem(int id) async {
    final db = await database;
    if (db == null) return null;

    try {
      return await db.delete(
        'gallery',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (_) {
      return null;
    }
  }

  /// Number of photos + videos stored in the gallery.
  Future<int> galleryCount() async {
    final db = await database;
    if (db == null) return 0;
    try {
      final result = await db.rawQuery('SELECT COUNT(*) as c FROM gallery');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // ==============================================================
  // SETTINGS
  // ==============================================================

  /// Returns the active settings (creating the default row on first use).
  Future<AppSettings> getSettings() async {
    const defaults = AppSettings(
      darkMode: false,
      notifications: true,
      language: 'English',
    );
    final db = await database;
    if (db == null) return defaults;

    try {
      final rows = await db.query(
        'settings',
        where: 'id = ?',
        whereArgs: [1],
        limit: 1,
      );
      if (rows.isNotEmpty) return AppSettings.fromMap(rows.first);

      await db.insert('settings', defaults.toMap());
      return defaults;
    } catch (_) {
      return defaults;
    }
  }

  /// Saves settings into the SQLite database.
  Future<void> saveSetting({
    required bool darkMode,
    required bool notifications,
    required String language,
  }) async {
    final db = await database;
    if (db == null) return;
    try {
      await db.insert(
        'settings',
        AppSettings(
          id: 1,
          darkMode: darkMode,
          notifications: notifications,
          language: language,
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Ignore - settings still work for the current session.
    }
  }

  /// Updates an existing settings row (alias for [saveSetting]).
  Future<void> updateSetting({
    required bool darkMode,
    required bool notifications,
    required String language,
  }) =>
      saveSetting(
        darkMode: darkMode,
        notifications: notifications,
        language: language,
      );

  // ==============================================================
  // MAINTENANCE
  // ==============================================================

  /// Deletes all local user data (donations, volunteers, contacts and
  /// settings reset to defaults).
  Future<void> clearLocalData() async {
    final db = await database;
    if (db == null) return;
    await db.execute('DELETE FROM donations');
    await db.execute('DELETE FROM volunteers');
    await db.execute('DELETE FROM contacts');
    await db.execute('DELETE FROM users');
    await db.execute('DELETE FROM settings');
    await db.insert(
      'settings',
      const AppSettings(
        darkMode: false,
        notifications: true,
        language: 'English',
      ).toMap(),
    );
  }
}