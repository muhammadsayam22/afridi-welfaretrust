import 'package:flutter/material.dart';

import 'database/db_helper.dart';
import 'models/volunteer_model.dart';
import 'theme/app_colors.dart';

/// Professional volunteer management screen.
///
/// Reads volunteer registrations straight from the local SQLite database,
/// ordered newest first. Supports manual refresh, editing (with a form
/// dialog that updates the record in place) and deletion (with a
/// confirmation dialog before removing a record).
class VolunteerManagementScreen extends StatefulWidget {
  const VolunteerManagementScreen({super.key});

  @override
  State<VolunteerManagementScreen> createState() =>
      _VolunteerManagementScreenState();
}

class _VolunteerManagementScreenState extends State<VolunteerManagementScreen> {
  late Future<List<Volunteer>> _volunteersFuture;

  @override
  void initState() {
    super.initState();
    _volunteersFuture = _loadVolunteers();
  }

  Future<List<Volunteer>> _loadVolunteers() =>
      DbHelper.instance.getVolunteers();

  void _refresh() {
    setState(() {
      _volunteersFuture = _loadVolunteers();
    });
  }

  Future<void> _confirmDelete(Volunteer volunteer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Delete Volunteer"),
        content: Text(
          "Remove ${volunteer.name} from the volunteer records?\n\n"
          "This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final rowsAffected = await DbHelper.instance.deleteVolunteer(volunteer.id!);
    if (!mounted) return;

    _showMessage(
      (rowsAffected != null && rowsAffected > 0)
          ? "${volunteer.name} removed from volunteers"
          : "Could not delete this volunteer. Please try again.",
    );
    _refresh();
  }

  Future<void> _editVolunteer(Volunteer volunteer) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => _EditVolunteerDialog(volunteer: volunteer),
    );

    if (updated != true || !mounted) return;

    _showMessage("Volunteer updated successfully.");
    _refresh();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Volunteer Management",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
            color: Colors.white,
          ),
        ],
      ),
      body: FutureBuilder<List<Volunteer>>(
        future: _volunteersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final volunteers = snapshot.data ?? const <Volunteer>[];

          if (volunteers.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadVolunteers,
            color: AppColors.primary,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.all(15),
              itemCount: volunteers.length,
              itemBuilder: (context, index) =>
                  _buildVolunteerCard(volunteers[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_2_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            const Text(
              "No volunteers yet",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Submitted volunteer registrations will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Refresh"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolunteerCard(Volunteer volunteer) {
    final initial = volunteer.name.isNotEmpty
        ? volunteer.name[0].toUpperCase()
        : 'V';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: CircleAvatar(
              radius: 23,
              backgroundColor: AppColors.lightGreen,
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              volunteer.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                "Joined ${_formatJoined(volunteer.createdAt)}",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: "Edit volunteer",
                  onPressed: () => _editVolunteer(volunteer),
                  icon: const Icon(Icons.edit_rounded,
                      color: AppColors.primary),
                ),
                IconButton(
                  tooltip: "Delete volunteer",
                  onPressed: () => _confirmDelete(volunteer),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.red),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row(Icons.phone_rounded, "Phone",
                    _field(volunteer.phone)),
                _row(Icons.email_rounded, "Email", _field(volunteer.email)),
                _row(Icons.location_city_rounded, "Address / City",
                    _field(volunteer.city)),
                _row(
                    Icons.work_outline_rounded,
                    "Occupation / Area",
                    _field(volunteer.area),
                    bold: true),
                _row(Icons.event_available_rounded, "Availability",
                    _field(volunteer.availability)),
                _row(Icons.message_outlined, "Message",
                    _field(volunteer.message),
                    last: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value,
      {bool bold = false, bool last = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
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
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _field(String? value) {
    final v = value?.trim() ?? '';
    return v.isEmpty ? '-' : v;
  }

  String _formatJoined(String iso) {
    final dateTime = DateTime.tryParse(iso);
    if (dateTime == null) return iso.isEmpty ? '-' : iso;

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    String two(int n) => n.toString().padLeft(2, '0');

    final hour12 = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final period = dateTime.hour < 12 ? 'AM' : 'PM';

    return '${dateTime.day} ${months[dateTime.month - 1]} '
        '${dateTime.year}, $hour12:${two(dateTime.minute)} $period';
  }
}

/// Dialog that pre-loads an existing volunteer and updates the same
/// database record on save. Cancel makes no database changes.
class _EditVolunteerDialog extends StatefulWidget {
  const _EditVolunteerDialog({required this.volunteer});

  final Volunteer volunteer;

  @override
  State<_EditVolunteerDialog> createState() => _EditVolunteerDialogState();
}

class _EditVolunteerDialogState extends State<_EditVolunteerDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _cityController;
  late final TextEditingController _messageController;

  late String? _selectedSkill;
  late String? _selectedAvailability;

  bool _saving = false;

  final RegExp _emailRegExp = RegExp(
    r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$',
  );

  static const List<String> _skills = [
    'Education',
    'Food Distribution',
    'Medical Support',
    'Clean Water',
    'Fundraising',
    'Event Support',
    'Other',
  ];

  static const List<String> _availabilities = [
    'Weekdays',
    'Weekends',
    'Evenings',
    'Full Time',
  ];

  @override
  void initState() {
    super.initState();
    final v = widget.volunteer;
    _nameController = TextEditingController(text: v.name);
    _phoneController = TextEditingController(text: v.phone);
    _emailController = TextEditingController(text: v.email);
    _cityController = TextEditingController(text: v.city);
    _messageController = TextEditingController(text: v.message);
    _selectedSkill = v.area.isEmpty ? null : v.area;
    _selectedAvailability = v.availability.isEmpty ? null : v.availability;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final city = _cityController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty) return _showMessage("Please enter your full name");
    if (phone.isEmpty) return _showMessage("Please enter your phone number");
    if (email.isEmpty) return _showMessage("Please enter your email");
    if (!_emailRegExp.hasMatch(email)) {
      return _showMessage("Please enter a valid email address");
    }
    if (_selectedSkill == null) {
      return _showMessage("Please select your volunteer area");
    }

    setState(() => _saving = true);

    final updated = Volunteer(
      id: widget.volunteer.id,
      name: name,
      phone: phone,
      email: email,
      city: city,
      area: _selectedSkill!,
      availability: _selectedAvailability ?? "",
      message: message,
      createdAt: widget.volunteer.createdAt,
    );

    final rowsAffected = await DbHelper.instance.updateVolunteer(updated);
    if (!mounted) return;

    if (rowsAffected == null || rowsAffected <= 0) {
      setState(() => _saving = false);
      _showMessage("Could not update this volunteer. Please try again.");
      return;
    }

    Navigator.pop(context, true);
  }

  List<String> _itemsWithCurrent(List<String> items, String? current) {
    if (current == null || current.isEmpty || items.contains(current)) {
      return items;
    }
    return [...items, current];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Row(
        children: [
          Icon(Icons.edit_rounded, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(child: Text("Edit Volunteer")),
        ],
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _textField(
                controller: _nameController,
                label: "Full Name",
                hint: "Enter full name",
                icon: Icons.person,
              ),
              const SizedBox(height: 12),
              _textField(
                controller: _phoneController,
                label: "Phone Number",
                hint: "Enter phone number",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _textField(
                controller: _emailController,
                label: "Email Address",
                hint: "Enter email",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _textField(
                controller: _cityController,
                label: "Address / City",
                hint: "Enter address or city",
                icon: Icons.location_city,
              ),
              const SizedBox(height: 12),
              _dropdown(
                value: _selectedSkill,
                items: _itemsWithCurrent(_skills, _selectedSkill),
                hint: "Select volunteer area (Skills)",
                icon: Icons.handyman_rounded,
                onChanged: (v) => setState(() => _selectedSkill = v),
              ),
              const SizedBox(height: 12),
              _dropdown(
                value: _selectedAvailability,
                items: _itemsWithCurrent(_availabilities, _selectedAvailability),
                hint: "Select availability (Status)",
                icon: Icons.event_available_rounded,
                onChanged: (v) => setState(() => _selectedAvailability = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        TextButton.icon(
          onPressed: _saving ? null : _saveChanges,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_rounded, size: 18),
          label: const Text(
            "Save Changes",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _textField({
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
          value: items.contains(value) ? value : null,
          hint: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(hint)),
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
}