import 'package:flutter/material.dart';

/// SummaRead's design system ("Azure Precision" - see `design/DESIGN.md`):
/// a corporate-modern palette anchored by a sky blue primary, Manrope
/// headlines over Inter body/label text, 16px-radius cards with 1px borders
/// instead of shadows, and 8px-radius buttons/inputs/tags. Colors and type
/// sizes are transcribed directly from `design/DESIGN.md`'s frontmatter.
class AppTheme {
  const AppTheme._();

  static const _manrope = 'Manrope';
  static const _inter = 'Inter';

  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF26619B),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF6DA1E0),
    onPrimaryContainer: Color(0xFF003762),
    primaryFixed: Color(0xFFD2E4FF),
    primaryFixedDim: Color(0xFFA1C9FF),
    onPrimaryFixed: Color(0xFF001C37),
    onPrimaryFixedVariant: Color(0xFF004880),
    secondary: Color(0xFF5F5E5E),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE2DFDE),
    onSecondaryContainer: Color(0xFF636262),
    secondaryFixed: Color(0xFFE5E2E1),
    secondaryFixedDim: Color(0xFFC8C6C5),
    onSecondaryFixed: Color(0xFF1C1B1B),
    onSecondaryFixedVariant: Color(0xFF474746),
    tertiary: Color(0xFF52606E),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFF91A0B0),
    onTertiaryContainer: Color(0xFF293744),
    tertiaryFixed: Color(0xFFD5E4F5),
    tertiaryFixedDim: Color(0xFFB9C8D9),
    onTertiaryFixed: Color(0xFF0E1D29),
    onTertiaryFixedVariant: Color(0xFF3A4856),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: Color(0xFFF7F9FC),
    onSurface: Color(0xFF191C1E),
    surfaceDim: Color(0xFFD8DADD),
    surfaceBright: Color(0xFFF7F9FC),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF2F4F7),
    surfaceContainer: Color(0xFFECEEF1),
    surfaceContainerHigh: Color(0xFFE6E8EB),
    surfaceContainerHighest: Color(0xFFE0E3E6),
    onSurfaceVariant: Color(0xFF424750),
    outline: Color(0xFF727781),
    outlineVariant: Color(0xFFC2C7D1),
    inverseSurface: Color(0xFF2D3133),
    onInverseSurface: Color(0xFFEFF1F4),
    inversePrimary: Color(0xFFA1C9FF),
    surfaceTint: Color(0xFF26619B),
  );

  /// Radius used for cards/containers (design spec: "16px (1rem)").
  static const double cardRadius = 16;

  /// Radius used for buttons, inputs, and chips/tags (design spec:
  /// "8px (0.5rem)").
  static const double controlRadius = 8;

  static final TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: _manrope,
      fontSize: 48,
      height: 56 / 48,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.96,
    ),
    headlineLarge: TextStyle(
      fontFamily: _manrope,
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.32,
    ),
    // "headline-lg-mobile" in the design spec - the hero headline size
    // actually used on this phone-only app.
    headlineMedium: TextStyle(
      fontFamily: _manrope,
      fontSize: 28,
      height: 34 / 28,
      fontWeight: FontWeight.w700,
    ),
    // "headline-md".
    headlineSmall: TextStyle(
      fontFamily: _manrope,
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: TextStyle(
      fontFamily: _manrope,
      fontSize: 20,
      height: 26 / 20,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: TextStyle(
      fontFamily: _inter,
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w600,
    ),
    // "label-bold".
    titleSmall: TextStyle(
      fontFamily: _inter,
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w600,
    ),
    // "body-lg".
    bodyLarge: TextStyle(
      fontFamily: _inter,
      fontSize: 18,
      height: 28 / 18,
      fontWeight: FontWeight.w400,
    ),
    // "body-md".
    bodyMedium: TextStyle(
      fontFamily: _inter,
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      fontFamily: _inter,
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w400,
    ),
    // "label-bold", used for button labels.
    labelLarge: TextStyle(
      fontFamily: _inter,
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: TextStyle(
      fontFamily: _inter,
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w500,
    ),
    // "label-sm".
    labelSmall: TextStyle(
      fontFamily: _inter,
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w500,
    ),
  ).apply(
    bodyColor: colorScheme.onSurface,
    displayColor: colorScheme.onSurface,
  );

  static ThemeData get light {
    final base = ThemeData(colorScheme: colorScheme, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceBright,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: _textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          textStyle: _textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outlineVariant),
          textStyle: _textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: _textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: colorScheme.onSurfaceVariant),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        hintStyle: _textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
        labelStyle: _textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(controlRadius + 8),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        titleTextStyle: _textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
        subtitleTextStyle: _textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        titleTextStyle: _textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
        contentTextStyle: _textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: _textTheme.bodyMedium?.copyWith(color: colorScheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(controlRadius),
        ),
      ),
    );
  }
}
