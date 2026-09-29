import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'database/db_helper.dart';
import 'models/donation_model.dart';
import 'theme/app_colors.dart';
import 'utils/app_routes.dart';

/// Shows the complete details of a single donation with the admin actions
/// Verify, Reject, Edit and Delete. Every change updates the existing
/// database record in place (no duplicates are ever created) and the screen
/// pops with `true` so the management list can refresh.
class DonationDetailsScreen extends StatefulWidget {
  const DonationDetailsScreen({super.key});

  @override
  State<DonationDetailsScreen> createState() => _DonationDetailsScreenState();
}

class _DonationDetailsScreenState extends State<DonationDetailsScreen> {
  Donation? _donation;
  bool _busy = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;
    if (arg is Donation) _donation = arg;
  }

  Future<void> _pop() async {
    Get.back(result: _changed);
  }

  Future<Donation?> _reloadFromDatabase() async {
    final id = _donation?.id;
    if (id == null) return null;
    final all = await DbHelper.instance.getDonations();
    for (final donation in all) {
      if (donation.id == id) return donation;
    }
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _changeStatus(String status) async {
    final id = _donation?.id;
    if (id == null || _busy) return;
    setState(() => _busy = true);

    try {
      final rows = await DbHelper.instance.updateDonationStatus(id, status);
      if (!mounted) return;

      if (rows == null || rows <= 0) {
        _showMessage('Could not update the status. Please try again.');
        return;
      }

      _changed = true;
      final current = _donation;
      if (current != null) {
        setState(() {
          _donation = Donation(
            id: current.id,
            donorName: current.donorName,
            phone: current.phone,
            email: current.email,
            amount: current.amount,
            category: current.category,
            paymentMethod: current.paymentMethod,
            transactionId: current.transactionId,
            message: current.message,
            donationDate: current.donationDate,
            status: status,
            receiptNumber: current.receiptNumber,
            createdAt: current.createdAt,
          );
        });
      }
      _showMessage(
        status == DonationConstants.statusVerified
            ? 'Donation ${_friendlyReceipt()} verified'
            : 'Donation rejected',
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendlyReceipt() {
    final receipt = _donation?.receiptNumber ?? '';
    return receipt.isEmpty ? '' : '($receipt)';
  }

  Future<void> _editDonation() async {
    final donation = _donation;
    if (donation == null) return;
    final updated = await Get.toNamed<Object?>(
      AppRoutes.donationForm,
      arguments: donation,
    );
    if (updated == true) {
      _changed = true;
      final reloaded = await _reloadFromDatabase();
      if (!mounted) return;
      if (reloaded != null) setState(() => _donation = reloaded);
      _showMessage('Donation updated successfully.');
    }
  }

  Future<void> _confirmDelete() async {
    final donation = _donation;
    final id = donation?.id;
    if (donation == null || id == null || _busy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Donation'),
        content: Text(
          'Delete the donation record for ${donation.donorName}?'
          '\n\nReceipt: ${donation.receiptNumber.isEmpty ? '-' : donation.receiptNumber}\n'
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final rows = await DbHelper.instance.deleteDonation(id);
      if (!mounted) return;

      if (rows == null || rows <= 0) {
        _showMessage('Could not delete this donation. Please try again.');
        setState(() => _busy = false);
        return;
      }

      _changed = true;
      Get.back(result: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _showMessage('Something went wrong while deleting the donation.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final donation = _donation;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _pop,
        ),
        title: const Text(
          'Donation Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: donation == null
            ? const Center(child: Text('No donation data available.'))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(15),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(donation),
                        const SizedBox(height: 14),
                        _buildDetailsCard(donation),
                        const SizedBox(height: 14),
                        _buildActions(donation),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(Donation donation) {
    final statusColor = _statusColor(donation.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  donation.status.isEmpty
                      ? DonationConstants.statusPending
                      : donation.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donation.receiptNumber.isEmpty
                      ? 'Receipt Number'
                      : donation.receiptNumber,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  donation.donorName,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(Donation donation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _row(Icons.receipt_long_rounded, 'Receipt Number',
              _field(donation.receiptNumber), bold: true),
          _row(Icons.person_outline_rounded, 'Donor Name', donation.donorName),
          _row(Icons.phone_outlined, 'Phone', _field(donation.phone)),
          _row(Icons.email_outlined, 'Email', _field(donation.email)),
          _row(Icons.currency_rupee_rounded, 'Amount',
              _formatMoney(donation.amount), bold: true),
          _row(
              Icons.category_outlined, 'Category', _field(donation.category)),
          _row(Icons.payment_rounded, 'Payment Method',
              _field(donation.paymentMethod)),
          _row(Icons.confirmation_number_outlined, 'Transaction ID',
              _field(donation.transactionId)),
          _row(Icons.message_outlined, 'Message', _field(donation.message)),
          _row(
              Icons.calendar_month_rounded,
              'Donation Date',
              _field(donation.donationDate)),
          _row(Icons.fact_check_outlined, 'Status',
              donation.status.isEmpty
                  ? DonationConstants.statusPending
                  : donation.status),
          _row(Icons.hourglass_top_rounded, 'Created',
              _formatDate(donation.createdAt),
              last: true),
        ],
      ),
    );
  }

  Widget _buildActions(Donation donation) {
    final isPending = donation.status == DonationConstants.statusPending;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          if (isPending) ...[
            _actionButton(
              label: 'Verify',
              icon: Icons.verified_rounded,
              color: const Color(0xFF2E7D32),
              onPressed: _busy
                  ? null
                  : () => _changeStatus(DonationConstants.statusVerified),
            ),
            _actionButton(
              label: 'Reject',
              icon: Icons.cancel_outlined,
              color: const Color(0xFFC62828),
              onPressed: _busy
                  ? null
                  : () => _changeStatus(DonationConstants.statusRejected),
            ),
          ],
          _actionButton(
            label: 'Edit',
            icon: Icons.edit_rounded,
            color: AppColors.primary,
            onPressed: _busy ? null : _editDonation,
          ),
          _actionButton(
            label: 'Delete',
            icon: Icons.delete_outline_rounded,
            color: const Color(0xFFC62828),
            onPressed: _busy ? null : _confirmDelete,
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 132,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.6)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value,
      {bool bold = false, bool last = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 105,
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
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case DonationConstants.statusVerified:
        return const Color(0xFF2E7D32);
      case DonationConstants.statusRejected:
        return const Color(0xFFC62828);
      default:
        return const Color(0xFFEF6C00);
    }
  }

  String _field(String? value) {
    final v = value?.trim() ?? '';
    return v.isEmpty ? '-' : v;
  }

  String _formatMoney(double value) {
    final whole = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
      buffer.write(whole[i]);
    }
    return 'Rs. $buffer';
  }

  String _formatDate(String iso) {
    final dateTime = DateTime.tryParse(iso);
    if (dateTime == null) return iso.isEmpty ? '-' : iso;
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }
}