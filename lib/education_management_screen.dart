import 'package:flutter/material.dart';

import 'widgets/management_config.dart';
import 'widgets/management_screen.dart';

/// Education management configuration (education table).
const ManagementConfig educationManagementConfig = ManagementConfig(
  table: 'education',
  title: 'Education Management',
  icon: Icons.school_rounded,
  emptyIcon: Icons.school_outlined,
  recordNoun: 'student',
  statuses: ['Active', 'Completed', 'On Hold', 'Dropped Out'],
  fields: [
    ManagementField(
      key: 'title',
      label: 'Student Name',
      icon: Icons.person_rounded,
      required: true,
      searchable: true,
      hint: 'Enter student / beneficiary name',
    ),
    ManagementField(
      key: 'guardian_name',
      label: 'Father / Guardian',
      icon: Icons.supervisor_account_rounded,
      searchable: true,
      hint: 'Enter father or guardian name',
    ),
    ManagementField(
      key: 'class_level',
      label: 'Class / Level',
      icon: Icons.menu_book_rounded,
      summary: true,
      searchable: true,
      hint: 'e.g. Class 5 / Matric',
    ),
    ManagementField(
      key: 'institute',
      label: 'School / Institute',
      icon: Icons.school_rounded,
      summary: true,
      searchable: true,
      hint: 'Enter school or institute name',
    ),
    ManagementField(
      key: 'contact',
      label: 'Contact Number',
      icon: Icons.phone_rounded,
      keyboardType: TextInputType.phone,
      summary: true,
      searchable: true,
      hint: 'Enter contact number',
    ),
    ManagementField(
      key: 'area',
      label: 'Area / Address',
      icon: Icons.location_on_rounded,
      summary: true,
      searchable: true,
      hint: 'Enter area or address',
    ),
    ManagementField(
      key: 'status',
      label: 'Status',
      icon: Icons.verified_rounded,
      type: ManagementFieldType.choice,
      required: true,
    ),
    ManagementField(
      key: 'record_date',
      label: 'Date',
      icon: Icons.event_rounded,
      type: ManagementFieldType.date,
      summary: true,
    ),
    ManagementField(
      key: 'description',
      label: 'Description',
      icon: Icons.notes_rounded,
      type: ManagementFieldType.multiline,
      hint: 'Extra notes about this student',
    ),
  ],
);

/// Education management screen - add, view, edit, search and delete
/// education records stored in the local SQLite database.
class EducationManagementScreen extends StatelessWidget {
  const EducationManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementScreen(config: educationManagementConfig);
  }
}
