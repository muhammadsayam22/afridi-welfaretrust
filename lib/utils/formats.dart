/// Date / money formatting helpers shared by the management screens.
library;

/// Returns today's date as a `yyyy-MM-dd` key.
String todayDateKey() {
  final now = DateTime.now();
  return _dateKey(now);
}

/// Converts a [DateTime] into a `yyyy-MM-dd` key.
String dateKeyOf(DateTime date) => _dateKey(date);

String _dateKey(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)}';
}

/// Whether [value] looks like a `yyyy-MM-dd` date.
bool isDateKey(String value) {
  if (value.isEmpty) return false;
  final match = RegExp(r'^\d{4}-\d{2}-\d{2}$').firstMatch(value.trim());
  if (match == null) return false;
  return DateTime.tryParse(value.trim()) != null;
}

/// Formats a stored date/ISO value for display (`12 Mar 2026`).
String formatDateLabel(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return '-';

  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;

  return '${parsed.day} ${_month(parsed.month)} ${parsed.year}';
}

/// Formats a stored ISO timestamp for display (`12 Mar 2026, 3:45 PM`).
String formatDateTimeLabel(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return '-';

  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;

  final hour12 = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
  final period = parsed.hour < 12 ? 'AM' : 'PM';
  String two(int n) => n.toString().padLeft(2, '0');

  return '${formatDateLabel(raw)}, $hour12:${two(parsed.minute)} $period';
}

/// Formats a number as `Rs. 12,500`.
String formatMoneyLabel(String? value) {
  final parsed = double.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    final raw = value?.trim() ?? '';
    return raw.isEmpty ? '-' : raw;
  }

  final whole = parsed.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
    buffer.write(whole[i]);
  }
  return 'Rs. $buffer';
}

String _month(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return months[month - 1];
}
