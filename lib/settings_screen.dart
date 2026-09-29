import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'database/db_helper.dart';
import 'services/settings_service.dart';
import 'theme/app_colors.dart';
import 'utils/app_routes.dart';

/// Professional settings screen: app info, preferences, support links,
/// database maintenance and app about.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _dbState = 'Loading...';
  int _donations = 0;
  int _volunteers = 0;
  int _contacts = 0;

  @override
  void initState() {
    super.initState();
    _refreshDatabaseStatus();
  }

  Future<void> _refreshDatabaseStatus() async {
    final db = DbHelper.instance;
    int donations = 0;
    int volunteers = 0;
    int contacts = 0;
    String state;

    try {
      donations = await db.donationCount();
      volunteers = await db.volunteerCount();
      contacts = await db.contactCount();
      state = db.isOffline ? 'Unavailable' : 'Ready';
    } catch (_) {
      state = 'Unavailable';
    }

    if (!mounted) return;
    setState(() {
      _dbState = state;
      _donations = donations;
      _volunteers = volunteers;
      _contacts = contacts;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showInfoDialog(String title, String body) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(body, style: const TextStyle(height: 1.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Local Data'),
        content: const Text(
          'This will permanently delete all saved donations, '
          'volunteer registrations and contact messages on this device.\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SettingsService.instance.clearAllData();
      if (!mounted) return;
      _refreshDatabaseStatus();
      _showMessage('Local data cleared');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===================== PROFILE / APP =====================
                  _sectionHeader(
                    Icons.apps_rounded,
                    'Profile / App',
                    'About Afridi Welfare Trust and application',
                  ),
                  const SizedBox(height: 12),
                  _groupContainer(
                    child: Column(
                      children: const [
                        ListTile(
                          leading: _SettingsIcon(Icons.info_rounded),
                          title: Text('About Afridi Welfare Trust'),
                          subtitle: Text(
                            'A non-profit organization serving humanity '
                            'with love & care.',
                          ),
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: _SettingsIcon(
                            Icons.favorite_rounded,
                            color: Colors.red,
                          ),
                          title: Text('Tagline'),
                          subtitle: Text('Serving Humanity With Love & Care'),
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: _SettingsIcon(Icons.menu_book_rounded),
                          title: Text('App Information'),
                          subtitle:
                              Text('Afridi Welfare Trust charity application'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ===================== PREFERENCES =====================
                  _sectionHeader(
                    Icons.tune_rounded,
                    'Preferences',
                    'Customize your experience',
                  ),
                  const SizedBox(height: 12),
                  _groupContainer(
                    child: Column(
                      children: [
                        _buildDarkModeTile(),
                        const Divider(height: 1),
                        _buildNotificationsTile(),
                        const Divider(height: 1),
                        _buildLanguageTile(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ===================== SUPPORT =====================
                  _sectionHeader(
                    Icons.support_agent_rounded,
                    'Support',
                    'Get in touch and spread the word',
                  ),
                  const SizedBox(height: 12),
                  _groupContainer(
                    child: Column(
                      children: [
                        _tile(
                          icon: Icons.contact_phone_rounded,
                          title: 'Contact Us',
                          subtitle: 'Reach out to the trust team',
                          iconColor: AppColors.primary,
                          onTap: () => Get.toNamed(AppRoutes.contact),
                        ),
                        const Divider(height: 1),
                        _tile(
                          icon: Icons.share_rounded,
                          title: 'Share App',
                          subtitle: 'Share Afridi Welfare Trust with friends',
                          iconColor: Colors.blue,
                          onTap: _shareApp,
                        ),
                        const Divider(height: 1),
                        _tile(
                          icon: Icons.star_rounded,
                          title: 'Rate App',
                          subtitle: 'Support us with a review',
                          iconColor: AppColors.gold,
                          onTap: () => _showInfoDialog(
                            'Rate App',
                            'Thank you for supporting Afridi Welfare Trust!\n\n'
                            'Your review helps more people discover our '
                            'charity work and serve humanity.',
                          ),
                        ),
                        const Divider(height: 1),
                        _tile(
                          icon: Icons.shield_rounded,
                          title: 'Privacy Policy',
                          subtitle: 'How we protect your information',
                          iconColor: Colors.teal,
                          onTap: () => _showInfoDialog(
                            'Privacy Policy',
                            'Afridi Welfare Trust respects your privacy. '
                            'Information you provide through the app '
                            '(donations, volunteer registration and contact '
                            'messages) is stored locally on your device and '
                            'used only to process your request and support '
                            'our charity programs.\n\n'
                            'We do not sell or share your personal data '
                            'with third parties.',
                          ),
                        ),
                        const Divider(height: 1),
                        _tile(
                          icon: Icons.description_rounded,
                          title: 'Terms & Conditions',
                          subtitle: 'Guidelines for using this app',
                          iconColor: Colors.indigo,
                          onTap: () => _showInfoDialog(
                            'Terms & Conditions',
                            'By using this application you agree to use it '
                            'for lawful purposes related to supporting '
                            'humanitarian charity work.\n\n'
                            'Donations recorded in this app are pledge '
                            'records. For the official bank details please '
                            'refer to the Donate screen.',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ===================== DATABASE =====================
                  _sectionHeader(
                    Icons.storage_rounded,
                    'Database',
                    'Local storage status',
                  ),
                  const SizedBox(height: 12),
                  _groupContainer(
                    child: Column(
                      children: [
                        _tile(
                          icon: Icons.dns_rounded,
                          title: 'Database Status',
                          subtitle: _dbState == 'Ready'
                              ? 'SQLite ready - $_donations donations, '
                                  '$_volunteers volunteers, $_contacts messages'
                              : _dbState,
                          iconColor: _dbState == 'Ready'
                              ? Colors.green
                              : Colors.orange,
                          trailing: _dbState == 'Ready'
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : const Icon(Icons.error_outline,
                                  color: Colors.orange),
                          onTap: _refreshDatabaseStatus,
                        ),
                        const Divider(height: 1),
                        _tile(
                          icon: Icons.groups_rounded,
                          title: 'Volunteer Management',
                          subtitle:
                              'View and manage volunteer registrations',
                          iconColor: AppColors.primary,
                          onTap: () =>
                              Get.toNamed(AppRoutes.volunteerManagement),
                        ),
                        const Divider(height: 1),
                        _tile(
                          icon: Icons.receipt_long_rounded,
                          title: 'Donation Management',
                          subtitle:
                              'View, verify and manage donation records',
                          iconColor: AppColors.primary,
                          onTap: () =>
                              Get.toNamed(AppRoutes.donationManagement),
                        ),
                        const Divider(height: 1),
                        _tile(
                          icon: Icons.delete_sweep_rounded,
                          title: 'Clear Local Data',
                          subtitle: 'Delete all saved records from this device',
                          iconColor: Colors.red,
                          onTap: _confirmClearData,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ===================== MANAGEMENT =====================
                  _sectionHeader(
                    Icons.dashboard_rounded,
                    'Management',
                    'Manage records, media and gallery content',
                  ),
                  const SizedBox(height: 12),
                  _groupContainer(
                    child: Column(
                      children: [
                        _tile(
                          icon: Icons.school_rounded,
                          title: 'Education Management',
                          subtitle:
                              'Add, edit and search education records',
                          iconColor: AppColors.primary,
                          onTap: () =>
                              Get.toNamed(AppRoutes.educationManagement),
                        ),
                        const Divider(height: 1),
                        _tile(
                          icon: Icons.restaurant_rounded,
                          title: 'Food Management',
                          subtitle:
                              'Track food packages and distributions',
                          iconColor: Colors.orange,
                          onTap: () =>
                              Get.toNamed(AppRoutes.foodManagement),
                        ),
                        const Divider(height: 1),
                        _tile(
                          icon: Icons.local_hospital_rounded,
                          title: 'Medical Management',
                          subtitle:
                              'Record patients, treatment and assistance',
                          iconColor: Colors.red,
                          onTap: () =>
                              Get.toNamed(AppRoutes.medicalManagement),
                        ),
                        const Divider(height: 1),
                        _tile(
                          icon: Icons.water_drop_rounded,
                          title: 'Clean Water Management',
                          subtitle: 'Manage clean water projects',
                          iconColor: Colors.blue,
                          onTap: () =>
                              Get.toNamed(AppRoutes.waterManagement),
                        ),
                        const Divider(height: 1),
                        _tile(
                          icon: Icons.photo_library_rounded,
                          title: 'Gallery',
                          subtitle: 'Upload, preview and delete photos '
                              '& videos',
                          iconColor: Colors.purple,
                          onTap: () => Get.toNamed(AppRoutes.gallery),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ===================== ABOUT =====================
                  _sectionHeader(
                    Icons.verified_rounded,
                    'About',
                    'Application details',
                  ),
                  const SizedBox(height: 12),
                  _groupContainer(
                    child: Column(
                      children: const [
                        ListTile(
                          leading: _SettingsIcon(
                            Icons.storage_rounded,
                            color: AppColors.primary,
                          ),
                          title: Text('App Version'),
                          subtitle: Text('1.0.0'),
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: _SettingsIcon(
                            Icons.business_rounded,
                            color: AppColors.primary,
                          ),
                          title: Text('Organization Name'),
                          subtitle: Text('Afridi Welfare Trust'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Center(
                    child: Text(
                      '© 2026 Afridi Welfare Trust\nServing Humanity With Love & Care',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // Widget builders
  // ================================================================

  Widget _sectionHeader(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _groupContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color iconColor,
    Widget? trailing,
  }) {
    return ListTile(
      leading: _SettingsIcon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  Widget _buildDarkModeTile() {
    return ValueListenableBuilder<bool>(
      valueListenable: SettingsService.instance.darkMode,
      builder: (context, value, _) {
        return SwitchListTile(
          secondary: _SettingsIcon(Icons.dark_mode_rounded,
              color: Colors.deepPurple),
          title: const Text('Dark Mode',
              style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text('Use a darker theme for the app'),
          value: value,
          activeTrackColor: AppColors.primary,
          onChanged: (v) => SettingsService.instance.setDarkMode(v),
        );
      },
    );
  }

  Widget _buildNotificationsTile() {
    return ValueListenableBuilder<bool>(
      valueListenable: SettingsService.instance.notifications,
      builder: (context, value, _) {
        return SwitchListTile(
          secondary: _SettingsIcon(Icons.notifications_rounded,
              color: Colors.blue),
          title: const Text('Notifications',
              style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text('Receive updates and reminders'),
          value: value,
          activeTrackColor: AppColors.primary,
          onChanged: (v) => SettingsService.instance.setNotifications(v),
        );
      },
    );
  }

  Widget _buildLanguageTile() {
    return ValueListenableBuilder<String>(
      valueListenable: SettingsService.instance.language,
      builder: (context, value, _) {
        return ListTile(
          leading: _SettingsIcon(Icons.language_rounded,
              color: Colors.teal.shade600),
          title: const Text('Language',
              style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text('Choose your preferred language'),
          trailing: DropdownButton<String>(
            value: value,
            underline: const SizedBox.shrink(),
            style: const TextStyle(color: AppColors.primary, fontSize: 14),
            items: const [
              DropdownMenuItem(value: 'English', child: Text('English')),
              DropdownMenuItem(value: 'Urdu', child: Text('اردو / Urdu')),
            ],
            onChanged: (v) {
              if (v != null) SettingsService.instance.setLanguage(v);
            },
          ),
        );
      },
    );
  }

  Future<void> _shareApp() async {
    await Clipboard.setData(
      const ClipboardData(text: 'Afridi Welfare Trust - Serving Humanity '
          'With Love & Care'),
    );
    if (!mounted) return;
    _showMessage('Share text copied - paste it to share the app!');
  }
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon(this.icon, {this.color = AppColors.primary});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}