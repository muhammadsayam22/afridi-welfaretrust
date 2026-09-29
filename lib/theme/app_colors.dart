import 'package:flutter/material.dart';

/// Central color palette for the Afridi Welfare Trust app.
///
/// The whole app uses these constants so that the green "Qatar-style"
/// charity theme stays consistent everywhere.
class AppColors {
  AppColors._();

  /// Primary brand green used for app bars, buttons and highlights.
  static const Color primary = Color(0xFF087F5B);

  /// A slightly brighter emerald green used in gradients.
  static const Color secondGreen = Color(0xFF12B886);

  /// Deep teal-green used in gradients next to [primary].
  static const Color tealGreen = Color(0xFF099268);

  /// Very dark green used for the footer and strong headings.
  static const Color darkGreen = Color(0xFF063B2B);

  /// Light green used for soft backgrounds and empty icons.
  static const Color lightGreen = Color(0xFFE8F5E9);

  /// Light green border colour.
  static const Color mintGreen = Color(0xFFB7E4C7);

  /// Gold accent used for important charity highlights.
  static const Color gold = Color(0xFFD4A017);

  /// App scaffold background colour.
  static const Color background = Color(0xFFF7F9F8);

  /// Dark text colour used across the app.
  static const Color textDark = Color(0xFF263238);
}