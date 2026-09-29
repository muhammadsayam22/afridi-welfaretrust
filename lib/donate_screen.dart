import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'database/db_helper.dart';
import 'models/donation_model.dart';
import 'theme/app_colors.dart';

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  final String accountNumber = "YOUR_ACCOUNT_NUMBER";
  final String bankName = "Bank AL Habib";
  final String accountTitle = "Afridi Welfare Trust";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String? selectedType;
  String? selectedMethod;
  int? selectedPreset;
  bool _saving = false;

  final List<int> presetAmounts = [500, 1000, 2500, 5000, 10000];

  final List<String> donationTypes = [
    'General Donation',
    'Zakat',
    'Sadaqah',
    'Orphan Support',
    'Education Fund',
    'Food Relief',
    'Medical Aid',
    'Clean Water',
  ];

  final List<String> paymentMethods = [
    'Bank Transfer',
    'JazzCash',
    'Easypaisa',
    'Cash In Person',
    'Other',
  ];

  void selectPreset(int amount) {
    setState(() {
      selectedPreset = amount;
      amountController.text = amount.toString();
    });
  }

  @override
  void initState() {
    super.initState();

    amountController.addListener(_onAmountChanged);

    final args = Get.arguments;
    if (args is Map) {
      if (args['donationType'] != null) {
        selectedType = args['donationType'] as String;
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final parsed = int.tryParse(amountController.text.trim());
    if (parsed == null || parsed != selectedPreset) {
      if (selectedPreset != null && mounted) {
        setState(() => selectedPreset = null);
      }
    }
  }

  void copyAccountNumber() {
    Clipboard.setData(ClipboardData(text: accountNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account number copied!")),
    );
  }

  final RegExp emailRegExp = RegExp(
    r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$',
  );

  void donateNow() {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final notes = noteController.text.trim();
    final amountText = amountController.text.trim();

    if (name.isEmpty) return showMessage("Please enter your name");
    if (phone.isEmpty) return showMessage("Please enter your phone number");
    if (email.isNotEmpty && !emailRegExp.hasMatch(email)) {
      return showMessage("Please enter a valid email address");
    }
    if (amountText.isEmpty) return showMessage("Please enter donation amount");

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      return showMessage("Please enter a valid amount greater than 0");
    }

    // Save the donation into the local SQLite database.
    _saveDonation(
      donorName: name,
      phone: phone,
      email: email,
      amount: amount,
      purpose: selectedType ?? 'General Donation',
      paymentMethod: selectedMethod ?? 'Bank Transfer',
      message: notes,
    );
  }

  Future<void> _saveDonation({
    required String donorName,
    required String phone,
    required String email,
    required double amount,
    required String purpose,
    required String paymentMethod,
    required String message,
  }) async {
    if (_saving) return;
    setState(() => _saving = true);

    final donation = Donation(
      donorName: donorName,
      phone: phone,
      email: email,
      amount: amount,
      purpose: purpose,
      paymentMethod: paymentMethod,
      message: message,
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      final id = await DbHelper.instance.insertDonation(donation);
      if (!mounted) return;

      if (id == null) {
        _showBackendMessage();
        return;
      }

      final amountText = amount.toStringAsFixed(0);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Expanded(child: Text("Thank You!")),
            ],
          ),
          content: Text(
            "Dear $donorName,\n\n"
            "Thank you for your donation of Rs. $amountText.\n\n"
            "Please transfer the amount to our $bankName account.\n\n"
            "Your support helps us serve humanity.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                clearForm();
              },
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!mounted) return;
      _showBackendMessage();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showBackendMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Something Went Wrong"),
        content: const Text(
          "We could not save your donation right now. "
          "Please try again later.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void clearForm() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    amountController.clear();
    noteController.clear();
    setState(() {
      selectedType = null;
      selectedMethod = null;
      selectedPreset = null;
    });
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
        title: const Text(
          "Donate",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 28,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.tealGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.white.withValues(alpha: 0.25),
                          size: isDesktop ? 110 : 60,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Make a Donation",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Your generosity changes lives",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Bank Account Details",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  informationBox(
                    icon: Icons.account_balance,
                    title: "Bank Name",
                    value: bankName,
                  ),
                  const SizedBox(height: 12),
                  informationBox(
                    icon: Icons.person_pin,
                    title: "Account Title",
                    value: accountTitle,
                  ),
                  const SizedBox(height: 12),
                  informationBox(
                    icon: Icons.pin,
                    title: "Account Number",
                    value: accountNumber,
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: copyAccountNumber,
                      icon: const Icon(Icons.copy, color: AppColors.primary),
                      label: const Text(
                        "Copy Account Number",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Donation Form",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  textField(
                    controller: nameController,
                    label: "Donor Name",
                    hint: "Enter your full name",
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 15),
                  textField(
                    controller: phoneController,
                    label: "Phone Number",
                    hint: "Enter your phone number",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 15),
                  textField(
                    controller: emailController,
                    label: "Email Address",
                    hint: "Enter your email",
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Donation Amount",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: presetAmounts.map((amount) {
                      final selected = selectedPreset == amount;
                      return ChoiceChip(
                        label: Text("Rs. $amount"),
                        selected: selected,
                        onSelected: (_) => selectPreset(amount),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : AppColors.darkGreen,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 15),

                  textField(
                    controller: amountController,
                    label: "Amount (Rs.)",
                    hint: "Enter donation amount",
                    icon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                  ),

                  const SizedBox(height: 15),

                  dropdownField(
                    value: selectedType,
                    items: donationTypes,
                    hint: "Select purpose of donation",
                    icon: Icons.category_outlined,
                    onChanged: (v) => setState(() => selectedType = v),
                  ),

                  const SizedBox(height: 15),

                  dropdownField(
                    value: selectedMethod,
                    items: paymentMethods,
                    hint: "Select payment method",
                    icon: Icons.payment,
                    onChanged: (v) => setState(() => selectedMethod = v),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Message",
                      hintText: "Any message or note",
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 46),
                        child: Icon(Icons.message, color: AppColors.primary),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : donateNow,
                      icon: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.favorite),
                      label: Text(
                        _saving ? "Saving..." : "Donate Now",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.mintGreen),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primary),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "After submitting your donation, please complete "
                            "the transfer using the bank account details above. "
                            "Your support helps us serve humanity.",
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ),
                      ],
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

  Widget dropdownField({
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(hint),
            ],
          ),
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget informationBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget textField({
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}