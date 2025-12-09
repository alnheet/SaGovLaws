import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'google_ai_colors.dart';

/// Application theme configuration
/// Follows Material Design 3 with Google AI Studio aesthetics
class AppTheme {
  AppTheme._();

  // Legacy Brand Colors (for backward compatibility)
  static const Color primaryColor = GoogleAIColors.deepBlue;
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = GoogleAIColors.deepBlueLight;
  static const Color accentColor = GoogleAIColors.sageGreen;
  static const Color errorColor = GoogleAIColors.coral;
  static const Color successColor = GoogleAIColors.sageGreen;
  static const Color warningColor = GoogleAIColors.amber;

  // Source Colors (muted pastels)
  static const Map<String, Color> sourceColors = GoogleAIColors.sourceColors;

  /// Light Theme - Google AI Studio Style
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: GoogleAIColors.deepBlue,
      brightness: Brightness.light,
      primary: GoogleAIColors.deepBlue,
      onPrimary: Colors.white,
      secondary: GoogleAIColors.sageGreen,
      onSecondary: Colors.white,
      tertiary: GoogleAIColors.warmPurple,
      error: GoogleAIColors.coral,
      surface: GoogleAIColors.surfaceLight,
      onSurface: GoogleAIColors.textPrimaryLight,
      surfaceContainerLowest: GoogleAIColors.surfaceLight,
      surfaceContainerLow: GoogleAIColors.surfaceContainerLight,
      surfaceContainer: GoogleAIColors.surfaceContainerLight,
      surfaceContainerHigh: GoogleAIColors.surfaceContainerHighLight,
      outline: GoogleAIColors.borderLight,
      outlineVariant: GoogleAIColors.borderLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,

      // Scaffold - Off-white background
      scaffoldBackgroundColor: GoogleAIColors.backgroundLight,

      // AppBar - Clean, minimal
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        backgroundColor: GoogleAIColors.surfaceLight,
        foregroundColor: GoogleAIColors.textPrimaryLight,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: _getTitleTextStyle(GoogleAIColors.textPrimaryLight),
        iconTheme:
            const IconThemeData(color: GoogleAIColors.textSecondaryLight),
        shape: const Border(
          bottom: BorderSide(color: GoogleAIColors.borderLight, width: 1),
        ),
      ),

      // Card - White surface with subtle border and high radius
      cardTheme: CardThemeData(
        elevation: 0,
        color: GoogleAIColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GoogleAIColors.radiusXl),
          side: const BorderSide(color: GoogleAIColors.borderLight, width: 1),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: GoogleAIColors.spacing4,
          vertical: GoogleAIColors.spacing2,
        ),
      ),

      // Text Theme
      textTheme: _getTextTheme(Brightness.light),

      // Input - High border radius, clean design
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GoogleAIColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GoogleAIColors.radiusLg),
          borderSide: const BorderSide(color: GoogleAIColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GoogleAIColors.radiusLg),
          borderSide: const BorderSide(color: GoogleAIColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GoogleAIColors.radiusLg),
          borderSide:
              const BorderSide(color: GoogleAIColors.deepBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GoogleAIColors.radiusLg),
          borderSide: const BorderSide(color: GoogleAIColors.coral),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: GoogleAIColors.spacing5,
          vertical: GoogleAIColors.spacing4,
        ),
        hintStyle: TextStyle(color: GoogleAIColors.textTertiaryLight),
      ),

      // Elevated Button - High radius, subtle shadow
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GoogleAIColors.deepBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: GoogleAIColors.spacing6,
            vertical: GoogleAIColors.spacing4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GoogleAIColors.radiusLg),
          ),
          textStyle: _getButtonTextStyle(),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GoogleAIColors.deepBlue,
          padding: const EdgeInsets.symmetric(
            horizontal: GoogleAIColors.spacing6,
            vertical: GoogleAIColors.spacing4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GoogleAIColors.radiusLg),
          ),
          side: const BorderSide(color: GoogleAIColors.borderLight),
          textStyle: _getButtonTextStyle(),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GoogleAIColors.deepBlue,
          padding: const EdgeInsets.symmetric(
            horizontal: GoogleAIColors.spacing4,
            vertical: GoogleAIColors.spacing3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GoogleAIColors.radiusMd),
          ),
          textStyle: _getButtonTextStyle(),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: GoogleAIColors.deepBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GoogleAIColors.radiusLg),
        ),
      ),

      // Tab Bar - Clean, underlined
      tabBarTheme: TabBarThemeData(
        labelColor: GoogleAIColors.deepBlue,
        unselectedLabelColor: GoogleAIColors.textSecondaryLight,
        indicatorColor: GoogleAIColors.deepBlue,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: GoogleAIColors.borderLight,
        labelStyle: _getLabelTextStyle(GoogleAIColors.deepBlue),
        unselectedLabelStyle:
            _getLabelTextStyle(GoogleAIColors.textSecondaryLight),
      ),

      // Navigation Rail - For sidebar
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: GoogleAIColors.surfaceLight,
        selectedIconTheme: const IconThemeData(color: GoogleAIColors.deepBlue),
        unselectedIconTheme:
            const IconThemeData(color: GoogleAIColors.textSecondaryLight),
        selectedLabelTextStyle: _getLabelTextStyle(GoogleAIColors.deepBlue),
        unselectedLabelTextStyle:
            _getLabelTextStyle(GoogleAIColors.textSecondaryLight),
        indicatorColor: GoogleAIColors.deepBlueMuted,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GoogleAIColors.radiusMd),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: GoogleAIColors.surfaceLight,
        selectedItemColor: GoogleAIColors.deepBlue,
        unselectedItemColor: GoogleAIColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: GoogleAIColors.borderLight,
        thickness: 1,
        space: 1,
      ),

      // Chip - High radius, muted colors
      chipTheme: ChipThemeData(
        backgroundColor: GoogleAIColors.surfaceContainerLight,
        selectedColor: GoogleAIColors.deepBlueMuted,
        labelStyle: _getCaptionTextStyle(GoogleAIColors.textPrimaryLight),
        padding: const EdgeInsets.symmetric(
          horizontal: GoogleAIColors.spacing3,
          vertical: GoogleAIColors.spacing2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GoogleAIColors.radiusFull),
          side: const BorderSide(color: GoogleAIColors.borderLight),
        ),
      ),

      // Dialog - High radius
      dialogTheme: DialogThemeData(
        backgroundColor: GoogleAIColors.surfaceLight,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GoogleAIColors.radius2xl),
        ),
      ),

      // Bottom Sheet - High radius
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: GoogleAIColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(GoogleAIColors.radius2xl),
          ),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: GoogleAIColors.textPrimaryLight,
        contentTextStyle: _getBodyTextStyle(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GoogleAIColors.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: GoogleAIColors.spacing4,
          vertical: GoogleAIColors.spacing2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GoogleAIColors.radiusMd),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: GoogleAIColors.textSecondaryLight,
        size: 24,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: GoogleAIColors.deepBlue,
        linearTrackColor: GoogleAIColors.surfaceContainerHighLight,
      ),
    );
  }

  /// Dark Theme - Google AI Studio Style
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: GoogleAIColors.deepBlue,
      brightness: Brightness.dark,
      primary: GoogleAIColors.deepBlueLight,
      onPrimary: Colors.white,
      secondary: GoogleAIColors.sageGreenLight,
      onSecondary: Colors.white,
      tertiary: GoogleAIColors.warmPurpleLight,
      error: GoogleAIColors.coralLight,
      surface: GoogleAIColors.surfaceDark,
      onSurface: GoogleAIColors.textPrimaryDark,
      surfaceContainerLowest: GoogleAIColors.backgroundDark,
      surfaceContainerLow: GoogleAIColors.surfaceDark,
      surfaceContainer: GoogleAIColors.surfaceContainerDark,
      surfaceContainerHigh: GoogleAIColors.surfaceContainerHighDark,
      outline: GoogleAIColors.borderDark,
      outlineVariant: GoogleAIColors.borderDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,

      // Scaffold
      scaffoldBackgroundColor: GoogleAIColors.backgroundDark,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        backgroundColor: GoogleAIColors.surfaceDark,
        foregroundColor: GoogleAIColors.textPrimaryDark,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: _getTitleTextStyle(GoogleAIColors.textPrimaryDark),
        iconTheme: const IconThemeData(color: GoogleAIColors.textSecondaryDark),
        shape: const Border(
          bottom: BorderSide(color: GoogleAIColors.borderDark, width: 1),
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        color: GoogleAIColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GoogleAIColors.radiusXl),
          side: const BorderSide(color: GoogleAIColors.borderDark, width: 1),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: GoogleAIColors.spacing4,
          vertical: GoogleAIColors.spacing2,
        ),
      ),

      // Text Theme
      textTheme: _getTextTheme(Brightness.dark),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GoogleAIColors.surfaceContainerDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GoogleAIColors.radiusLg),
          borderSide: const BorderSide(color: GoogleAIColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GoogleAIColors.radiusLg),
          borderSide: const BorderSide(color: GoogleAIColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GoogleAIColors.radiusLg),
          borderSide:
              const BorderSide(color: GoogleAIColors.deepBlueLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: GoogleAIColors.spacing5,
          vertical: GoogleAIColors.spacing4,
        ),
        hintStyle: TextStyle(color: GoogleAIColors.textTertiaryDark),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GoogleAIColors.deepBlueLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: GoogleAIColors.spacing6,
            vertical: GoogleAIColors.spacing4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GoogleAIColors.radiusLg),
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GoogleAIColors.deepBlueLight,
          padding: const EdgeInsets.symmetric(
            horizontal: GoogleAIColors.spacing6,
            vertical: GoogleAIColors.spacing4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GoogleAIColors.radiusLg),
          ),
          side: const BorderSide(color: GoogleAIColors.borderDark),
        ),
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: GoogleAIColors.deepBlueLight,
        unselectedLabelColor: GoogleAIColors.textSecondaryDark,
        indicatorColor: GoogleAIColors.deepBlueLight,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: GoogleAIColors.borderDark,
        labelStyle: _getLabelTextStyle(GoogleAIColors.deepBlueLight),
        unselectedLabelStyle:
            _getLabelTextStyle(GoogleAIColors.textSecondaryDark),
      ),

      // Navigation Rail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: GoogleAIColors.surfaceDark,
        selectedIconTheme:
            const IconThemeData(color: GoogleAIColors.deepBlueLight),
        unselectedIconTheme:
            const IconThemeData(color: GoogleAIColors.textSecondaryDark),
        indicatorColor: GoogleAIColors.deepBlue.withValues(alpha: 0.3),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GoogleAIColors.radiusMd),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: GoogleAIColors.surfaceDark,
        selectedItemColor: GoogleAIColors.deepBlueLight,
        unselectedItemColor: GoogleAIColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: GoogleAIColors.borderDark,
        thickness: 1,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: GoogleAIColors.surfaceContainerDark,
        selectedColor: GoogleAIColors.deepBlue.withValues(alpha: 0.3),
        labelStyle: _getCaptionTextStyle(GoogleAIColors.textPrimaryDark),
        padding: const EdgeInsets.symmetric(
          horizontal: GoogleAIColors.spacing3,
          vertical: GoogleAIColors.spacing2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GoogleAIColors.radiusFull),
          side: const BorderSide(color: GoogleAIColors.borderDark),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: GoogleAIColors.surfaceDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GoogleAIColors.radius2xl),
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: GoogleAIColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(GoogleAIColors.radius2xl),
          ),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: GoogleAIColors.textSecondaryDark,
        size: 24,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: GoogleAIColors.deepBlueLight,
        linearTrackColor: GoogleAIColors.surfaceContainerHighDark,
      ),
    );
  }

  // ============ Text Styles ============

  static TextTheme _getTextTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final primary = isLight
        ? GoogleAIColors.textPrimaryLight
        : GoogleAIColors.textPrimaryDark;
    final secondary = isLight
        ? GoogleAIColors.textSecondaryLight
        : GoogleAIColors.textSecondaryDark;

    return TextTheme(
      displayLarge: _getDisplayTextStyle(primary),
      displayMedium: _getDisplayTextStyle(primary).copyWith(fontSize: 32),
      displaySmall: _getDisplayTextStyle(primary).copyWith(fontSize: 28),
      headlineLarge: _getHeadlineTextStyle(primary),
      headlineMedium: _getHeadlineTextStyle(primary).copyWith(fontSize: 20),
      headlineSmall: _getHeadlineTextStyle(primary).copyWith(fontSize: 18),
      titleLarge: _getTitleTextStyle(primary),
      titleMedium: _getTitleTextStyle(primary).copyWith(fontSize: 16),
      titleSmall: _getTitleTextStyle(primary).copyWith(fontSize: 14),
      bodyLarge: _getBodyTextStyle(primary),
      bodyMedium: _getBodyTextStyle(primary).copyWith(fontSize: 14),
      bodySmall: _getBodyTextStyle(secondary).copyWith(fontSize: 12),
      labelLarge: _getLabelTextStyle(primary),
      labelMedium: _getLabelTextStyle(primary).copyWith(fontSize: 12),
      labelSmall: _getCaptionTextStyle(secondary),
    );
  }

  static TextStyle _getDisplayTextStyle(Color color) {
    return GoogleFonts.cairo(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: color,
      height: 1.3,
    );
  }

  static TextStyle _getHeadlineTextStyle(Color color) {
    return GoogleFonts.cairo(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.3,
    );
  }

  static TextStyle _getTitleTextStyle(Color color) {
    return GoogleFonts.cairo(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle _getBodyTextStyle(Color color) {
    return GoogleFonts.cairo(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: color,
      height: 1.6,
    );
  }

  static TextStyle _getLabelTextStyle(Color color) {
    return GoogleFonts.cairo(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle _getCaptionTextStyle(Color color) {
    return GoogleFonts.cairo(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle _getButtonTextStyle() {
    return GoogleFonts.cairo(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.2,
    );
  }
}
