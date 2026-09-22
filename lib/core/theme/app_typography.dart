import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme get textTheme => TextTheme(
    displayLarge: GoogleFonts.merriweather(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    displayMedium: GoogleFonts.merriweather(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    headlineLarge: GoogleFonts.merriweather(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.merriweather(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleLarge: GoogleFonts.lato(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleMedium: GoogleFonts.lato(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    bodyLarge: GoogleFonts.lato(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.lato(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.textSecondary,
    ),
    bodySmall: GoogleFonts.lato(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.textLight,
    ),
    labelLarge: GoogleFonts.lato(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.surface,
      letterSpacing: 0.5,
    ),
  );
}