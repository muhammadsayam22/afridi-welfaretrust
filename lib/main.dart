import 'package:afridiwelfaretrust/about_screen.dart';
import 'package:afridiwelfaretrust/clean_water_management_screen.dart';
import 'package:afridiwelfaretrust/clean_water_screen.dart';
import 'package:afridiwelfaretrust/contact_screen.dart';
import 'package:afridiwelfaretrust/donation_details_screen.dart';
import 'package:afridiwelfaretrust/donation_form_screen.dart';
import 'package:afridiwelfaretrust/donation_management_screen.dart';
import 'package:afridiwelfaretrust/donate_screen.dart';
import 'package:afridiwelfaretrust/education_management_screen.dart';
import 'package:afridiwelfaretrust/education_screen.dart';
import 'package:afridiwelfaretrust/food_management_screen.dart';
import 'package:afridiwelfaretrust/food_screen.dart';
import 'package:afridiwelfaretrust/gallery_screen.dart';
import 'package:afridiwelfaretrust/home_screen.dart';
import 'package:afridiwelfaretrust/medical_management_screen.dart';
import 'package:afridiwelfaretrust/medical_screen.dart';
import 'package:afridiwelfaretrust/settings_screen.dart';
import 'package:afridiwelfaretrust/splash_screen.dart';
import 'package:afridiwelfaretrust/theme/app_theme.dart';
import 'package:afridiwelfaretrust/utils/app_routes.dart';
import 'package:afridiwelfaretrust/volunteer_management_screen.dart';
import 'package:afridiwelfaretrust/volunteer_screen.dart';
import 'package:afridiwelfaretrust/services/settings_service.dart';
import 'package:afridiwelfaretrust/database/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SettingsService.instance.load();
  await DbHelper.instance.initializeDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: SettingsService.instance.darkMode,
      builder: (context, isDarkMode, _) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AFRIDI WELFARE TRUST',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: AppRoutes.splash,
          getPages: [
            GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
            GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
            GetPage(name: AppRoutes.about, page: () => const AboutScreen()),
            GetPage(name: AppRoutes.donate, page: () => const DonateScreen()),
            GetPage(
              name: AppRoutes.volunteer,
              page: () => const VolunteerScreen(),
            ),
            GetPage(name: AppRoutes.contact, page: () => const ContactScreen()),
            GetPage(
              name: AppRoutes.education,
              page: () => const EducationScreen(),
            ),
            GetPage(name: AppRoutes.food, page: () => const FoodScreen()),
            GetPage(
              name: AppRoutes.medical,
              page: () => const MedicalScreen(),
            ),
            GetPage(
              name: AppRoutes.water,
              page: () => const CleanWaterScreen(),
            ),
            GetPage(
              name: AppRoutes.settings,
              page: () => const SettingsScreen(),
            ),
            GetPage(
              name: AppRoutes.volunteerManagement,
              page: () => const VolunteerManagementScreen(),
            ),
            GetPage(
              name: AppRoutes.donationManagement,
              page: () => const DonationManagementScreen(),
            ),
            GetPage(
              name: AppRoutes.donationForm,
              page: () => const DonationFormScreen(),
            ),
            GetPage(
              name: AppRoutes.donationDetails,
              page: () => const DonationDetailsScreen(),
            ),
            GetPage(
              name: AppRoutes.educationManagement,
              page: () => const EducationManagementScreen(),
            ),
            GetPage(
              name: AppRoutes.foodManagement,
              page: () => const FoodManagementScreen(),
            ),
            GetPage(
              name: AppRoutes.medicalManagement,
              page: () => const MedicalManagementScreen(),
            ),
            GetPage(
              name: AppRoutes.waterManagement,
              page: () => const CleanWaterManagementScreen(),
            ),
            GetPage(
              name: AppRoutes.gallery,
              page: () => const GalleryScreen(),
            ),
          ],
        );
      },
    );
  }
}