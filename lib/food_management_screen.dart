import 'package:flutter/material.dart';

import 'widgets/management_config.dart';
import 'widgets/management_screen.dart';

/// Food management configuration (food table).
const ManagementConfig foodManagementConfig = ManagementConfig(
  table: 'food',
  title: 'Food Management',
  icon: Icons.restaurant_rounded,
  emptyIcon: Icons.restaurant_outlined,
  recordNoun: 'beneficiary',
  statuses: ['Pending', 'Scheduled', 'Distributed', 'Cancelled'],
  fields: [
    ManagementField(
      key: 'title',
      label: 'Beneficiary Name',
      icon: Icons.person_rounded,
      required: true,
      searchable: true,
      hint: 'Enter beneficiary name',
    ),
    ManagementField(
      key: 'family_members',
      label: 'Family Members',
      icon: Icons.groups_rounded,
      type: ManagementFieldType.number,
      summary: true,
      searchable: true,
      hint: 'e.g. 5',
    ),
    ManagementField(
      key: 'package_type',
      label: 'Food Package / Type',
      icon: Icons.inventory_2_rounded,
      summary: true,
      searchable: true,
      hint: 'e.g. Monthly ration pack',
    ),
    ManagementField(
      key: 'quantity',
      label: 'Quantity',
      icon: Icons.shopping_basket_rounded,
      summary: true,
      searchable: true,
      hint: 'e.g. 10 packs',
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
      key: 'area',
      label: 'Area / Address',
      icon: Icons.location_on_rounded,
      summary: true,
      searchable: true,
      hint: 'Enter area or address',
    ),
    ManagementField(
      key: 'distribution_date',
      label: 'Distribution Date',
      icon: Icons.calendar_month_rounded,
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
      hint: 'Extra notes about this distribution',
    ),
  ],
);

/// Food management screen - add, view, edit, search and delete food
/// distribution records stored in the local SQLite database.
class FoodManagementScreen extends StatelessWidget {
  const FoodManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementScreen(config: foodManagementConfig);
  }
}
