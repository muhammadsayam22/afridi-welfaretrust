/// Database table definitions for Afridi Welfare Trust
class DatabaseTables {
  static const String donations = '''CREATE TABLE IF NOT EXISTS donations (
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
  )''';

  static const String volunteers = '''CREATE TABLE IF NOT EXISTS volunteers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    city TEXT,
    area TEXT,
    availability TEXT,
    message TEXT,
    created_at TEXT NOT NULL
  )''';

  static const String contacts = '''CREATE TABLE IF NOT EXISTS contacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    subject TEXT,
    message TEXT NOT NULL,
    created_at TEXT NOT NULL
  )''';

  static const String projects = '''CREATE TABLE IF NOT EXISTS projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    image TEXT,
    category TEXT,
    status TEXT,
    created_at TEXT NOT NULL
  )''';

  static const String education = '''CREATE TABLE IF NOT EXISTS education (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    image TEXT,
    record_type TEXT DEFAULT 'program',
    guardian_name TEXT,
    class_level TEXT,
    institute TEXT,
    contact TEXT,
    area TEXT,
    status TEXT,
    record_date TEXT,
    created_at TEXT NOT NULL
  )''';

  static const String food = '''CREATE TABLE IF NOT EXISTS food (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    image TEXT,
    record_type TEXT DEFAULT 'program',
    family_members TEXT,
    package_type TEXT,
    quantity TEXT,
    contact TEXT,
    area TEXT,
    distribution_date TEXT,
    status TEXT,
    created_at TEXT NOT NULL
  )''';

  static const String medical = '''CREATE TABLE IF NOT EXISTS medical (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    image TEXT,
    record_type TEXT DEFAULT 'program',
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
  )''';

  static const String cleanWater = '''CREATE TABLE IF NOT EXISTS clean_water (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    image TEXT,
    record_type TEXT DEFAULT 'program',
    location TEXT,
    water_type TEXT,
    beneficiaries TEXT,
    estimated_cost TEXT,
    status TEXT,
    start_date TEXT,
    completion_date TEXT,
    created_at TEXT NOT NULL
  )''';

  static const String gallery = '''CREATE TABLE IF NOT EXISTS gallery (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    file_path TEXT NOT NULL,
    media_type TEXT NOT NULL DEFAULT 'photo',
    created_at TEXT NOT NULL
  )''';
}
