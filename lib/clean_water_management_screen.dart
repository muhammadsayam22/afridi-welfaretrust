import 'package:flutter/material.dart';

import 'widgets/management_config.dart';
import 'widgets/management_screen.dart';

/// Clean water management configuration (clean_water table).
const ManagementConfig cleanWaterManagementConfig = ManagementConfig(
  table: 'clean_water',
  title: 'Clean Water Management',
  icon: Icons.water_drop_rounded,
  emptyIcon: Icons.water_drop_outlined,
  recordNoun: 'project',
  statuses: ['Planned', 'In Progress', 'Completed', 'On Hold'],
  fields: [
    ManagementField(
      key: 'title',
      label: 'Project Name',
      icon: Icons.workspaces_rounded,
      required: true,
      searchable: true,
      hint: 'Enter project name',
    ),
    ManagementField(
      key: 'location',
      label: 'Location',
      icon: Icons.location_on_rounded,
      required: true,
      summary: true,
      searchable: true,
      hint: 'Enter project location',
    ),
    ManagementField(
      key: 'water_type',
      label: 'Water Project Type',
      icon: Icons.water_rounded,
      summary: true,
      searchable: true,
      hint: 'e.g. Water well, hand pump, tank',
    ),
    ManagementField(
      key: 'beneficiaries',
      label: 'No. of Beneficiaries',
      icon: Icons.groups_rounded,
      type: ManagementFieldType.number,
      summary: true,
      searchable: true,
      hint: 'e.g. 120',
    ),
    ManagementField(
      key: 'estimated_cost',
      label: 'Estimated Cost',
      icon: Icons.payments_rounded,
      type: ManagementFieldType.number,
      summary: true,
      searchable: true,
      hint: 'e.g. 75000',
    ),
    ManagementField(
      key: 'status',
      label: 'Status',
      icon: Icons.verified_rounded,
      type: ManagementFieldType.choice,
      required: true,
    ),
    ManagementField(
      key: 'start_date',
      label: 'Start Date',
      icon: Icons.event_rounded,
      type: ManagementFieldType.date,
      summary: true,
    ),
    ManagementField(
      key: 'completion_date',
      label: 'Completion Date',
      icon: Icons.event_available_rounded,
      type: ManagementFieldType.date,
      hint: 'Leave empty while the project is running',
    ),
    ManagementField(
      key: 'description',
      label: 'Description',
      icon: Icons.notes_rounded,
      type: ManagementFieldType.multiline,
      hint: 'Extra notes about this project',
    ),
  ],
);

/// Clean water management screen - add, view, edit, search and delete
/// clean water project records stored in the local SQLite database.
class CleanWaterManagementScreen extends StatelessWidget {
  const CleanWaterManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementScreen(config: cleanWaterManagementConfig);
  }
}
