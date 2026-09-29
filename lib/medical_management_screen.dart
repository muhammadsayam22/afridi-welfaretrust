import 'package:flutter/material.dart';

import 'widgets/management_config.dart';
import 'widgets/management_screen.dart';

/// Medical management configuration (medical table).
const ManagementConfig medicalManagementConfig = ManagementConfig(
  table: 'medical',
  title: 'Medical Management',
  icon: Icons.local_hospital_rounded,
  emptyIcon: Icons.health_and_safety_outlined,
  recordNoun: 'patient',
  statuses: ['Pending', 'Under Treatment', 'Recovered', 'Referred'],
  fields: [
    ManagementField(
      key: 'title',
      label: 'Patient Name',
      icon: Icons.person_rounded,
      required: true,
      searchable: true,
      hint: 'Enter patient name',
    ),
    ManagementField(
      key: 'age',
      label: 'Age',
      icon: Icons.cake_rounded,
      type: ManagementFieldType.number,
      summary: true,
      searchable: true,
      hint: 'e.g. 34',
    ),
    ManagementField(
      key: 'contact',
      label: 'Contact Number',
      icon: Icons.phone_rounded,
      keyboardType: TextInputType.phone,
      searchable: true,
      hint: 'Enter contact number',
    ),
    ManagementField(
      key: 'medical_issue',
      label: 'Medical Issue',
      icon: Icons.healing_rounded,
      required: true,
      summary: true,
      searchable: true,
      hint: 'Describe the medical issue',
    ),
    ManagementField(
      key: 'treatment',
      label: 'Treatment / Medicine',
      icon: Icons.medication_rounded,
      searchable: true,
      hint: 'Medicine or treatment given',
    ),
    ManagementField(
      key: 'doctor',
      label: 'Doctor / Hospital',
      icon: Icons.medical_services_rounded,
      summary: true,
      searchable: true,
      hint: 'Doctor or hospital name',
    ),
    ManagementField(
      key: 'area',
      label: 'Area / Address',
      icon: Icons.location_on_rounded,
      searchable: true,
      hint: 'Enter area or address',
    ),
    ManagementField(
      key: 'assistance',
      label: 'Assistance (Details / Amount)',
      icon: Icons.volunteer_activism_rounded,
      searchable: true,
      hint: 'e.g. Rs. 5,000 or free medicine',
    ),
    ManagementField(
      key: 'record_date',
      label: 'Date',
      icon: Icons.event_rounded,
      type: ManagementFieldType.date,
      summary: true,
    ),
    ManagementField(
      key: 'status',
      label: 'Status',
      icon: Icons.verified_rounded,
      type: ManagementFieldType.choice,
      required: true,
    ),
    ManagementField(
      key: 'description',
      label: 'Description',
      icon: Icons.notes_rounded,
      type: ManagementFieldType.multiline,
      hint: 'Extra notes about this patient',
    ),
  ],
);

/// Medical management screen - add, view, edit, search and delete medical
/// assistance records stored in the local SQLite database.
class MedicalManagementScreen extends StatelessWidget {
  const MedicalManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementScreen(config: medicalManagementConfig);
  }
}
