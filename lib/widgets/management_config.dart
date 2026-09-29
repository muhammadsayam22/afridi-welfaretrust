import 'package:flutter/material.dart';

/// How a management field is rendered and validated.
enum ManagementFieldType {
  /// Regular single line text.
  text,

  /// Multi line description style text.
  multiline,

  /// Numeric text (validated as a number).
  number,

  /// Date value stored as `yyyy-MM-dd` with a date picker.
  date,

  /// Dropdown backed by a fixed list of options (e.g. status).
  choice,
}

/// Describes one column of a management table for forms, cards and the
/// details view. The [key] is the exact SQLite column name.
class ManagementField {
  const ManagementField({
    required this.key,
    required this.label,
    required this.icon,
    this.type = ManagementFieldType.text,
    this.required = false,
    this.summary = false,
    this.searchable = false,
    this.options = const <String>[],
    this.hint = '',
    this.keyboardType,
    this.color,
  });

  /// SQLite column name.
  final String key;

  /// Human readable label shown in forms, cards and details.
  final String label;

  /// Icon used next to the label.
  final IconData icon;

  /// Field kind (drives validation + widget choice).
  final ManagementFieldType type;

  /// Whether the field must be filled before saving.
  final bool required;

  /// Whether the value is shown on the record card.
  final bool summary;

  /// Whether the value participates in the search box.
  final bool searchable;

  /// Options for [ManagementFieldType.choice] fields.
  final List<String> options;

  /// Optional placeholder text.
  final String hint;

  /// Optional keyboard type override.
  final TextInputType? keyboardType;

  /// Optional accent color (used by the primary/status fields).
  final Color? color;
}

/// Everything a [ManagementScreen] needs to manage one database table.
class ManagementConfig {
  const ManagementConfig({
    required this.table,
    required this.title,
    required this.icon,
    required this.fields,
    required this.statuses,
    this.emptyIcon = Icons.inbox_outlined,
    this.recordNoun = 'record',
    this.statusText = 'Status',
  });

  /// Whitelisted SQLite table backing this screen.
  final String table;

  /// App bar title.
  final String title;

  /// Icon used by the app bar and empty state.
  final IconData icon;

  /// Ordered list of columns (the first entry is the record name).
  final List<ManagementField> fields;

  /// Options of the `status` field.
  final List<String> statuses;

  /// Icon for the empty state.
  final IconData emptyIcon;

  /// Noun used in messages ("record", "student", ...).
  final String recordNoun;

  /// Label of the status filter/dropdown.
  final String statusText;

  /// The record name column (always the first configured field).
  ManagementField get primaryField => fields.first;

  /// The status field when the table has one.
  ManagementField? get statusField {
    for (final field in fields) {
      if (field.key == 'status') return field;
    }
    return null;
  }

  /// Columns the search box matches against.
  List<String> get searchColumns => [
        for (final field in fields)
          if (field.searchable) field.key,
      ];

  /// Columns displayed on the record card.
  List<ManagementField> get summaryFields => [
        for (final field in fields)
          if (field.summary) field,
      ];

  /// Looks up a field by column name.
  ManagementField? fieldOrNull(String key) {
    for (final field in fields) {
      if (field.key == key) return field;
    }
    return null;
  }

  /// Options of a choice field, always containing [current] so existing
  /// values of older rows stay selectable.
  List<String> optionsWithCurrent(List<String> options, String? current) {
    final value = current?.trim() ?? '';
    if (value.isEmpty || options.contains(value)) return options;
    return [...options, value];
  }

  /// Resolves the option list of a choice field. The `status` column is
  /// driven by [statuses] so both stay in sync automatically.
  List<String> optionsFor(ManagementField field) {
    if (field.key == 'status' && field.options.isEmpty) return statuses;
    return field.options;
  }

  /// Options of [field] including its current database value.
  List<String> selectableOptionsFor(ManagementField field, String? current) =>
      optionsWithCurrent(optionsFor(field), current);

  /// Extracts the record name from a database row.
  String titleOf(Map<String, Object?> row) {
    final value = (row[primaryField.key] as String?) ?? '';
    return value.trim().isEmpty ? 'Untitled' : value.trim();
  }

  /// Extracts the status from a database row.
  String statusOf(Map<String, Object?> row) {
    final value = (row['status'] as String?) ?? '';
    return value.trim();
  }

  /// Extracts a display value from a database row.
  String valueOf(Map<String, Object?> row, String key) {
    final value = row[key];
    if (value == null) return '';
    return value.toString().trim();
  }
}
