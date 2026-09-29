import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'database/db_helper.dart';
import 'models/donation_model.dart';
import 'theme/app_colors.dart';

/// Professional donation form used for both creating new donations and
/// editing existing records.
///
/// Validation rules:
/// * Donor name required
/// * Phone required
/// * Amount required and greater than 0
/// * Category required
/// * Payment method required
/// * Transaction ID required for online payment methods
/// * Email is validated only when provided
class DonationFormScreen extends StatefulWidget {
  const DonationFormScreen({super.key, this.donation});

  /// When provided the form edits this existing record instead of creating
  /// a new one.
  final Donation? donation;

  @override
  State<DonationFormScreen> createState() => _DonationFormScreenState();
}

class _DonationFormScreenState extends State<DonationFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _amountController;
  late final TextEditingController _transactionController;
  late final TextEditingController _messageController;

  String? _selectedCategory;
  String? _selectedPaymentMethod;
  String _donationDate = '';

  bool _saving = false;

  final RegExp _emailRegExp = RegExp(
    r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$',
  );

  Donation? get _editing {
    final arg = Get.arguments;
    if (arg is Donation) return arg;
    return widget.donation;
  }

  bool get _isEdit => _editing != null;

  @override
  void initState() {
    super.initState();
    final donation = _editing;
    _nameController = TextEditingController(text: donation?.donorName ?? '');
    _phoneController = TextEditingController(text: donation?.phone ?? '');
    _emailController = TextEditingController(text: donation?.email ?? '');
    _amountController = TextEditingController(
      text: donation == null ? '' : _amountText(donation.amount),
    );
    _transactionController =
        TextEditingController(text: donation?.transactionId ?? '');
    _messageController =
        TextEditingController(text: donation?.message ?? '');
    _selectedCategory =
        _valueOrNullable(donation?.category, DonationConstants.categories);
    _selectedPaymentMethod = _valueOrNullable(
        donation?.paymentMethod, DonationConstants.paymentMethods);
    _donationDate = donation?.donationDate ?? _dateKey(DateTime.now());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _amountController.dispose();
    _transactionController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String? _valueOrNullable(String? value, List<String> options) {
    if (value == null || value.isEmpty || options.contains(value)) {
      return value == null || value.isEmpty ? null : value;
    }
    return value;
  }

  String _amountText(double amount) {
    return amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toString();
  }

  String _dateKey(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(_donationDate) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) =>
          Theme(data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Theme.of(context).brightness,
            ),
          ), child: child!),
    );
    if (picked != null) {
      setState(() => _donationDate = _dateKey(picked));
    }
  }

  Future<bool> _transactionIdAlreadyUsed(String transactionId) async {
    if (transactionId.isEmpty) return false;
    final matches =
        await DbHelper.instance.getDonations(search: transactionId);
    return matches
        .where((d) => d.transactionId == transactionId)
        .any((d) => d.id != _editing?.id);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final amountText = _amountController.text.trim();
    final transactionId = _transactionController.text.trim();
    final message = _messageController.text.trim();
    final paymentMethod = _selectedPaymentMethod;

    if (name.isEmpty) return _showMessage('Please enter the donor name');
    if (phone.isEmpty) return _showMessage('Please enter the phone number');
    if (amountText.isEmpty) {
      return _showMessage('Please enter the donation amount');
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      return _showMessage('Please enter an amount greater than 0');
    }

    if (_selectedCategory == null) {
      return _showMessage('Please select a donation category');
    }
    if (paymentMethod == null) {
      return _showMessage('Please select a payment method');
    }
    if (paymentMethod != 'Cash' && transactionId.isEmpty) {
      return _showMessage('Transaction ID is required for $paymentMethod');
    }
    if (email.isNotEmpty && !_emailRegExp.hasMatch(email)) {
      return _showMessage('Please enter a valid email address');
    }

    setState(() => _saving = true);

    try {
      final isDuplicate = await _transactionIdAlreadyUsed(transactionId);
      if (isDuplicate) {
        if (!mounted) return;
        setState(() => _saving = false);
        _showMessage('This transaction ID has already been recorded');
        return;
      }

      final existing = _editing;
      final donation = Donation(
        id: existing?.id,
        donorName: name,
        phone: phone,
        email: email,
        amount: amount,
        category: _selectedCategory!,
        paymentMethod: paymentMethod,
        transactionId: paymentMethod == 'Cash' ? '' : transactionId,
        message: message,
        donationDate: _donationDate,
        status: existing?.status ?? DonationConstants.statusPending,
        receiptNumber: existing?.receiptNumber ?? '',
        createdAt: existing?.createdAt ?? DateTime.now().toIso8601String(),
      );

      final result = _isEdit
          ? await DbHelper.instance.updateDonation(donation)
          : await DbHelper.instance.insertDonation(donation);

      if (!mounted) return;

      if (result == null || (_isEdit && result <= 0)) {
        setState(() => _saving = false);
        _showMessage('Could not save this donation. Please try again.');
        return;
      }

      Get.back(result: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('Something went wrong while saving the donation.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _isEdit ? 'Edit Donation' : 'Add Donation',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.tealGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: isDesktop ? 56 : 40,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEdit
                                    ? 'Update Donation Record'
                                    : 'Record a Donation',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _isEdit
                                    ? 'Changes update the existing record.'
                                    : 'Every donation gets a unique receipt number.',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const _SectionLabel('Donor Information'),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _nameController,
                    label: 'Donor Name',
                    hint: 'Enter full name',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: 'Enter phone number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'Optional',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 24),

                  const _SectionLabel('Donation Details'),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: _amountController,
                    label: 'Donation Amount (Rs.)',
                    hint: 'Enter amount',
                    icon: Icons.currency_rupee_rounded,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildDropdown(
                    value: _selectedCategory,
                    items: DonationConstants.categories,
                    hint: 'Select donation category',
                    icon: Icons.category_outlined,
                    onChanged: (v) =>
                        setState(() => _selectedCategory = v),
                  ),
                  const SizedBox(height: 14),
                  _buildDropdown(
                    value: _selectedPaymentMethod,
                    items: DonationConstants.paymentMethods,
                    hint: 'Select payment method',
                    icon: Icons.payment_rounded,
                    onChanged: (v) =>
                        setState(() => _selectedPaymentMethod = v),
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _transactionController,
                    label: 'Transaction ID',
                    hint: 'Required for online payments',
                    icon: Icons.confirmation_number_outlined,
                  ),
                  const SizedBox(height: 14),
                  _buildDateField(),

                  const SizedBox(height: 24),

                  const _SectionLabel('Message (optional)'),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _messageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Donation Message',
                      hintText: 'Add a message with your donation',
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 46),
                        child: Icon(
                          Icons.message_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        borderSide:
                            BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              _isEdit
                                  ? Icons.save_rounded
                                  : Icons.check_circle_outline_rounded,
                            ),
                      label: Text(
                        _saving
                            ? 'Saving...'
                            : (_isEdit ? 'Save Changes' : 'Save Donation'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(15),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Donation Date',
          hintText: 'Select donation date',
          prefixIcon:
              const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Text(
          _donationDate,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value == null || !items.contains(value) ? null : value,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(child: Text(hint, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}