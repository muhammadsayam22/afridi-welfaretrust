import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shows the destructive-action confirmation used before any record or
/// media is removed from the database.
///
/// Returns `true` only when the user confirms the deletion.
Future<bool> confirmDelete(
  BuildContext context, {
  String title = 'Delete Item',
  String message = 'Are you sure you want to delete this item?',
  String confirmLabel = 'Delete',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title),
      content: Text('$message\n\nThis cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmLabel,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  return confirmed == true;
}

/// Standard snackbar used across the management screens.
void showAppMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Colored status pill used by every management card and detail view.
Widget statusPill(String status, {Color? fallbackColor}) {
  final value = status.trim().isEmpty ? 'Not set' : status.trim();
  final color = fallbackColor ?? _statusColor(value);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    ),
  );
}

Color _statusColor(String status) {
  final lower = status.toLowerCase();

  if (lower.contains('complete') ||
      lower.contains('verified') ||
      lower.contains('distributed') ||
      lower.contains('recovered')) {
    return const Color(0xFF2E7D32);
  }
  if (lower.contains('cancel') ||
      lower.contains('reject') ||
      lower.contains('drop')) {
    return const Color(0xFFC62828);
  }
  if (lower.contains('progress') ||
      lower.contains('treatment') ||
      lower.contains('active') ||
      lower.contains('scheduled')) {
    return AppColors.primary;
  }
  return const Color(0xFFEF6C00);
}
