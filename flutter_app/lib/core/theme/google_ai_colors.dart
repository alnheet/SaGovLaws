import 'package:flutter/material.dart';

/// Google AI Studio inspired color system
/// Based on Material Design 3 with sophisticated surface colors
class GoogleAIColors {
  GoogleAIColors._();

  // ============ Light Mode Colors ============

  /// Background - Very light grey/off-white
  static const Color backgroundLight = Color(0xFFF9FAFB);

  /// Surface - White containers
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Surface Container - Slightly elevated
  static const Color surfaceContainerLight = Color(0xFFF3F4F6);

  /// Surface Container High - More elevation
  static const Color surfaceContainerHighLight = Color(0xFFE5E7EB);

  /// Border color - Subtle grey
  static const Color borderLight = Color(0xFFE5E7EB);

  /// Text Primary
  static const Color textPrimaryLight = Color(0xFF111827);

  /// Text Secondary
  static const Color textSecondaryLight = Color(0xFF6B7280);

  /// Text Tertiary
  static const Color textTertiaryLight = Color(0xFF9CA3AF);

  // ============ Dark Mode Colors ============

  /// Background - Dark charcoal
  static const Color backgroundDark = Color(0xFF0F0F0F);

  /// Surface - Elevated dark surface
  static const Color surfaceDark = Color(0xFF1A1A1A);

  /// Surface Container
  static const Color surfaceContainerDark = Color(0xFF262626);

  /// Surface Container High
  static const Color surfaceContainerHighDark = Color(0xFF303030);

  /// Border color - Subtle dark
  static const Color borderDark = Color(0xFF374151);

  /// Text Primary
  static const Color textPrimaryDark = Color(0xFFF9FAFB);

  /// Text Secondary
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  /// Text Tertiary
  static const Color textTertiaryDark = Color(0xFF6B7280);

  // ============ Accent Colors (Muted Pastels) ============

  /// Deep Blue - Primary accent
  static const Color deepBlue = Color(0xFF1A56DB);
  static const Color deepBlueLight = Color(0xFF3B82F6);
  static const Color deepBlueMuted = Color(0xFFDBEAFE);

  /// Sage Green - Secondary accent
  static const Color sageGreen = Color(0xFF059669);
  static const Color sageGreenLight = Color(0xFF10B981);
  static const Color sageGreenMuted = Color(0xFFD1FAE5);

  /// Warm Purple - Tertiary
  static const Color warmPurple = Color(0xFF7C3AED);
  static const Color warmPurpleLight = Color(0xFF8B5CF6);
  static const Color warmPurpleMuted = Color(0xFFEDE9FE);

  /// Coral - Warning/Highlight
  static const Color coral = Color(0xFFDC2626);
  static const Color coralLight = Color(0xFFEF4444);
  static const Color coralMuted = Color(0xFFFEE2E2);

  /// Amber - Notice
  static const Color amber = Color(0xFFD97706);
  static const Color amberLight = Color(0xFFF59E0B);
  static const Color amberMuted = Color(0xFFFEF3C7);

  // ============ Source-specific Colors (Muted) ============

  static const Map<String, Color> sourceColors = {
    'cabinet_decisions': Color(0xFF1A56DB), // Deep Blue
    'royal_orders': Color(0xFF7C3AED), // Warm Purple
    'royal_decrees': Color(0xFFBE185D), // Rose
    'decisions_regulations': Color(0xFF059669), // Sage Green
    'laws_regulations': Color(0xFFD97706), // Amber
    'ministerial_decisions': Color(0xFF78716C), // Warm Grey
    'authorities': Color(0xFF475569), // Slate
  };

  static const Map<String, Color> sourceColorsLight = {
    'cabinet_decisions': Color(0xFFDBEAFE),
    'royal_orders': Color(0xFFEDE9FE),
    'royal_decrees': Color(0xFFFCE7F3),
    'decisions_regulations': Color(0xFFD1FAE5),
    'laws_regulations': Color(0xFFFEF3C7),
    'ministerial_decisions': Color(0xFFF5F5F4),
    'authorities': Color(0xFFF1F5F9),
  };

  // ============ Design Tokens ============

  /// Border radius values (high for Google AI Studio style)
  static const double radiusXs = 8.0;
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;
  static const double radius2xl = 28.0;
  static const double radius3xl = 32.0;
  static const double radiusFull = 9999.0;

  /// Spacing values
  static const double spacing1 = 4.0;
  static const double spacing2 = 8.0;
  static const double spacing3 = 12.0;
  static const double spacing4 = 16.0;
  static const double spacing5 = 20.0;
  static const double spacing6 = 24.0;
  static const double spacing8 = 32.0;
  static const double spacing10 = 40.0;
  static const double spacing12 = 48.0;

  /// Elevation/Shadow values
  static const List<BoxShadow> shadowNone = [];

  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 15,
      offset: Offset(0, 4),
    ),
  ];
}
