import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/formats.dart';
import 'management_common.dart';
import 'management_config.dart';

/// Full record details dialog showing every column of a management row
/// with its human readable label plus the record creation date.
class ManagementDetailsDialog extends StatelessWidget {
  const ManagementDetailsDialog({
    super.key,
    required this.config,
    required this.row,
    this.onEdit,
  });

  final ManagementConfig config;
  final Map<String, Object?> row;

  /// Optional callback that closes the dialog and opens the edit form.
  final VoidCallback? onEdit;

  static Future<void> show(
    BuildContext context, {
    required ManagementConfig config,
    required Map<String, Object?> row,
    VoidCallback? onEdit,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) =>
          ManagementDetailsDialog(config: config, row: row, onEdit: onEdit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = config.statusOf(row);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(config.icon, color: AppColors.primary),
              const SizedBox(width: 10),
              const Expanded(child: Text('Record Details')),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            config.titleOf(row),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          if (status.isNotEmpty) ...[
            const SizedBox(height: 6),
            statusPill(status),
          ],
        ],
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final field in config.fields) ...[
                _DetailRow(
                  icon: field.icon,
                  label: field.label,
                  value: _valueFor(field),
                ),
              ],
              const Divider(height: 22),
              _DetailRow(
                icon: Icons.schedule_rounded,
                label: 'Created At',
                value: formatDateTimeLabel(config.valueOf(row, 'created_at')),
                last: true,
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (onEdit != null)
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text(
              'Edit',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _valueFor(ManagementField field) {
    final value = config.valueOf(row, field.key);
    if (value.isEmpty) return '-';

    if (field.key == 'estimated_cost' || field.key == 'assistance') {
      final numeric = double.tryParse(value);
      if (numeric != null && _looksLikeAmount(field.key, value)) {
        return formatMoneyLabel(value);
      }
    }
    if (field.type == ManagementFieldType.date) {
      return formatDateLabel(value);
    }
    return value;
  }

  bool _looksLikeAmount(String key, String value) {
    if (key == 'estimated_cost') return true;
    // Assistance may be "Rs. 5,000" or free text - only format pure numbers.
    return RegExp(r'^\d+(\.\d+)?$').hasMatch(value.trim());
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
