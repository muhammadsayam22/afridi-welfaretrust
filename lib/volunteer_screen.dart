import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'database/db_helper.dart';
import 'models/volunteer_model.dart';
import 'theme/app_colors.dart';
import 'utils/app_routes.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({super.key});

  @override
  State<VolunteerScreen> createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  String? selectedSkill;
  String? selectedAvailability;

  final List<String> skills = [
    'Education',
    'Food Distribution',
    'Medical Support',
    'Clean Water',
    'Fundraising',
    'Event Support',
    'Other',
  ];

  final List<String> availabilities = [
    'Weekdays',
    'Weekends',
    'Evenings',
    'Full Time',
  ];

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    cityController.dispose();
    messageController.dispose();
    super.dispose();
  }

  final RegExp emailRegExp = RegExp(
    r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$',
  );

  void applyAsVolunteer() {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final city = cityController.text.trim();
    final message = messageController.text.trim();

    if (name.isEmpty) return showMessage("Please enter your full name");
    if (phone.isEmpty) return showMessage("Please enter your phone number");
    if (email.isEmpty) return showMessage("Please enter your email");
    if (email.isNotEmpty && !emailRegExp.hasMatch(email)) {
      return showMessage("Please enter a valid email address");
    }
    if (selectedSkill == null) {
      return showMessage("Please select your volunteer area");
    }

    _saveVolunteer(
      name: name,
      phone: phone,
      email: email,
      city: city,
      area: selectedSkill!,
      availability: selectedAvailability,
      message: message,
    );
  }

  Future<void> _saveVolunteer({
    required String name,
    required String phone,
    required String email,
    required String city,
    required String area,
    String? availability,
    required String message,
  }) async {
    final volunteer = Volunteer(
      name: name,
      phone: phone,
      email: email,
      city: city,
      area: area,
      availability: availability ?? "",
      message: message,
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      final id = await DbHelper.instance.insertVolunteer(volunteer);
      if (!mounted) return;

      if (id == null) {
        _showBackendMessage();
        return;
      }

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
              Expanded(child: Text("Application Submitted")),
            ],
          ),
          content: Text(
            "Thank you for joining our volunteer team, $name!\n\n"
            "Your volunteer application has been received successfully.\n\n"
            "Our team will contact you soon.",
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
          "We could not save your volunteer registration right now. "
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
    cityController.clear();
    messageController.clear();
    setState(() {
      selectedSkill = null;
      selectedAvailability = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Volunteer",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: "Volunteer Management",
            onPressed: () {
              Get.toNamed(AppRoutes.volunteerManagement);
            },
            icon: const Icon(Icons.manage_accounts_rounded),
            color: Colors.white,
          ),
        ],
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
                    child: const Column(
                      children: [
                        Icon(Icons.people_alt, color: Colors.white, size: 60),
                        SizedBox(height: 12),
                        Text(
                          "Become a Volunteer",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Join us in serving humanity",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Volunteer Registration",
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
                    label: "Full Name",
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
                  const SizedBox(height: 15),
                  textField(
                    controller: cityController,
                    label: "City",
                    hint: "Enter your city",
                    icon: Icons.location_city,
                  ),

                  const SizedBox(height: 20),

                  _dropdown(
                    value: selectedSkill,
                    items: skills,
                    hint: "Select volunteer area",
                    icon: Icons.handyman_rounded,
                    onChanged: (v) => setState(() => selectedSkill = v),
                  ),

                  const SizedBox(height: 15),

                  _dropdown(
                    value: selectedAvailability,
                    items: availabilities,
                    hint: "Select your availability",
                    icon: Icons.event_available_rounded,
                    onChanged: (v) => setState(() => selectedAvailability = v),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: messageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Message",
                      hintText: "Why do you want to volunteer?",
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 46),
                        child: Icon(
                          Icons.message,
                          color: AppColors.primary,
                        ),
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
                      onPressed: applyAsVolunteer,
                      icon: const Icon(Icons.volunteer_activism),
                      label: const Text(
                        "Join as Volunteer",
                        style: TextStyle(
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
                            "After submitting your application, our team "
                            "will review your information and contact you.",
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

  Widget _dropdown({
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
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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