import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:tasket/app/constants.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      primaryFixedDim: AppColors.primaryDim,
      onPrimary: AppColors.surface,
      secondary: AppColors.secondary,
      secondaryFixedDim: AppColors.secondaryDim,
      onSecondary: AppColors.surface,
      tertiary: AppColors.tertiary,
      tertiaryFixedDim: AppColors.tertiary,
      onTertiary: AppColors.surface,
      error: AppColors.error,
      onError: AppColors.surface,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.surface,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.hint,
      shadow: AppColors.shadow,
      surfaceDim: const Color(0xFFdddddd),
    ),

    textTheme: GoogleFonts.openSansTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        color: AppColors.onSurface,
        fontSize: 48,
        fontWeight: AppFontWeights.extrabold,
      ),
      displayMedium: GoogleFonts.ptSans(
        color: AppColors.hint,
        fontSize: 36,
        fontWeight: AppFontWeights.semibold,
      ),
      headlineLarge: GoogleFonts.openSans(
        // Topbar
        color: AppColors.onSurface,
        fontSize: 28,
        fontWeight: AppFontWeights.extrabold,
      ),
      headlineSmall: GoogleFonts.openSans(
        // Topbar
        color: AppColors.hint,
        fontSize: AppFontSizes.lg,
        fontWeight: AppFontWeights.semibold,
      ),
      labelMedium: GoogleFonts.openSans(
        // Task tile title
        color: AppColors.hint,
        fontSize: AppFontSizes.md,
        fontWeight: AppFontWeights.bold,
      ),
      titleMedium: GoogleFonts.openSans(
        // Task tile title
        color: AppColors.onSurface,
        fontSize: AppFontSizes.lg,
        fontWeight: AppFontWeights.bold,
      ),
      titleSmall: GoogleFonts.openSans(
        // Task tile metadata label (due date...)
        color: AppColors.onSurface,
        fontSize: AppFontSizes.sm,
        fontWeight: AppFontWeights.semibold,
      ),
      bodyLarge: GoogleFonts.openSans(
        // Subtask title
        color: AppColors.onSurface,
        fontSize: AppFontSizes.sm,
        fontWeight: AppFontWeights.bold,
      ),
      bodyMedium: GoogleFonts.openSans(
        // Tile note
        color: AppColors.onSurface,
        fontSize: AppFontSizes.md,
        fontWeight: AppFontWeights.regular,
      ),
      bodySmall: GoogleFonts.openSans(
        color: AppColors.onSurface,
        fontSize: AppFontSizes.xs,
        fontWeight: AppFontWeights.regular,
      ),
    ),
    dividerTheme: DividerThemeData(color: AppColors.faint, thickness: 1),
  );
}
