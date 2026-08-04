import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// VaultKey design system — Material 3 dark theme.
///
/// Tokens extracted from stitch_vaultkey_secure_password_manager prototypes.
class AppTheme {
  AppTheme._();

  // --------------------------------------------------------------------------
  // Colors
  // --------------------------------------------------------------------------

  static const Color background = Color(0xFF0e131f);
  static const Color surface = Color(0xFF0e131f);
  static const Color surfaceDim = Color(0xFF0e131f);
  static const Color surfaceBright = Color(0xFF343946);
  static const Color surfaceContainerLowest = Color(0xFF090e1a);
  static const Color surfaceContainerLow = Color(0xFF161b28);
  static const Color surfaceContainer = Color(0xFF1a1f2c);
  static const Color surfaceContainerHigh = Color(0xFF252a37);
  static const Color surfaceContainerHighest = Color(0xFF303542);
  static const Color onSurface = Color(0xFFdee2f3);
  static const Color onSurfaceVariant = Color(0xFFc2c6d6);
  static const Color inverseSurface = Color(0xFFdee2f3);
  static const Color inverseOnSurface = Color(0xFF2b303d);
  static const Color outline = Color(0xFF8c909f);
  static const Color outlineVariant = Color(0xFF424754);
  static const Color surfaceTint = Color(0xFFadc6ff);
  static const Color surfaceVariant = Color(0xFF303542);

  static const Color primary = Color(0xFFadc6ff);
  static const Color onPrimary = Color(0xFF002e6a);
  static const Color primaryContainer = Color(0xFF4d8eff);
  static const Color onPrimaryContainer = Color(0xFF00285d);
  static const Color inversePrimary = Color(0xFF005ac2);

  static const Color secondary = Color(0xFF4edea3);
  static const Color onSecondary = Color(0xFF003824);
  static const Color secondaryContainer = Color(0xFF00a572);
  static const Color onSecondaryContainer = Color(0xFF00311f);

  static const Color tertiary = Color(0xFFffb95f);
  static const Color onTertiary = Color(0xFF472a00);
  static const Color tertiaryContainer = Color(0xFFca8100);
  static const Color onTertiaryContainer = Color(0xFF3e2400);

  static const Color error = Color(0xFFffb4ab);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000a);
  static const Color onErrorContainer = Color(0xFFffdad6);

  static const Color primaryFixed = Color(0xFFd8e2ff);
  static const Color primaryFixedDim = Color(0xFFadc6ff);
  static const Color onPrimaryFixed = Color(0xFF001a42);
  static const Color onPrimaryFixedVariant = Color(0xFF004395);

  static const Color secondaryFixed = Color(0xFF6ffbbe);
  static const Color secondaryFixedDim = Color(0xFF4edea3);
  static const Color onSecondaryFixed = Color(0xFF002113);
  static const Color onSecondaryFixedVariant = Color(0xFF005236);

  static const Color tertiaryFixed = Color(0xFFffddb8);
  static const Color tertiaryFixedDim = Color(0xFFffb95f);
  static const Color onTertiaryFixed = Color(0xFF2a1700);
  static const Color onTertiaryFixedVariant = Color(0xFF653e00);

  // --------------------------------------------------------------------------
  // Typography
  // --------------------------------------------------------------------------

  static TextTheme _textTheme(BuildContext context) {
    final base = GoogleFonts.interTextTheme(Theme.of(context).textTheme);
    final mono = GoogleFonts.jetBrainsMonoTextTheme();

    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        letterSpacing: -0.02 * 32,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        letterSpacing: -0.01 * 24,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.05 * 12,
      ),
      // Use JetBrains Mono for code-like text
      bodySmall: mono.bodySmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Component themes
  // --------------------------------------------------------------------------

  static InputDecorationTheme _inputDecorationTheme(TextTheme textTheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: onSurfaceVariant.withOpacity(0.5),
      ),
      labelStyle: textTheme.labelSmall?.copyWith(color: onSurfaceVariant),
      prefixIconColor: onSurfaceVariant,
      suffixIconColor: onSurfaceVariant,
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(TextTheme textTheme) {
    return ElevatedButtonThemeData(
      style:
          ElevatedButton.styleFrom(
            backgroundColor: primaryContainer,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            shadowColor: primary.withOpacity(0.15),
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.white.withOpacity(0.1);
              }
              return null;
            }),
          ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(TextTheme textTheme) {
    return OutlinedButtonThemeData(
      style:
          OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: surfaceContainerHighest),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.all(
              surfaceContainerHigh.withOpacity(0.3),
            ),
          ),
    );
  }

  static TextButtonThemeData _textButtonTheme(TextTheme textTheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static CardTheme _cardTheme() {
    return CardTheme(
      color: surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
    );
  }

  static ChipThemeData _chipTheme(TextTheme textTheme) {
    return ChipThemeData(
      backgroundColor: surfaceContainer,
      selectedColor: primary,
      labelStyle: textTheme.labelSmall?.copyWith(color: onSurfaceVariant),
      secondaryLabelStyle: textTheme.labelSmall?.copyWith(color: onPrimary),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide.none,
      elevation: 0,
    );
  }

  static BottomSheetThemeData _bottomSheetTheme() {
    return BottomSheetThemeData(
      backgroundColor: surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      elevation: 8,
      modalBackgroundColor: surfaceContainerHighest,
    );
  }

  static FloatingActionButtonThemeData _fabTheme() {
    return FloatingActionButtonThemeData(
      backgroundColor: primaryContainer,
      foregroundColor: Colors.white,
      elevation: 4,
      highlightElevation: 8,
      shape: const CircleBorder(),
      sizeConstraints: const BoxConstraints.tightFor(width: 56, height: 56),
    );
  }

  static AppBarTheme _appBarTheme(TextTheme textTheme) {
    return AppBarTheme(
      backgroundColor: surface.withOpacity(0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.headlineMedium?.copyWith(color: onSurface),
      iconTheme: const IconThemeData(color: onSurfaceVariant),
      actionsIconTheme: const IconThemeData(color: onSurfaceVariant),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Theme assembly
  // --------------------------------------------------------------------------

  static ThemeData darkTheme(BuildContext context) {
    final textTheme = _textTheme(context);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceContainerHighest,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainer: surfaceContainer,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainerLowest: surfaceContainerLowest,
        surfaceBright: surfaceBright,
        surfaceDim: surfaceDim,
        outline: outline,
        outlineVariant: outlineVariant,
        inverseSurface: inverseSurface,
        inversePrimary: inversePrimary,
        shadow: Colors.black,
        scrim: Colors.black.withOpacity(0.6),
      ),
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      inputDecorationTheme: _inputDecorationTheme(textTheme),
      elevatedButtonTheme: _elevatedButtonTheme(textTheme),
      outlinedButtonTheme: _outlinedButtonTheme(textTheme),
      textButtonTheme: _textButtonTheme(textTheme),
      cardTheme: _cardTheme(),
      chipTheme: _chipTheme(textTheme),
      bottomSheetTheme: _bottomSheetTheme(),
      floatingActionButtonTheme: _fabTheme(),
      appBarTheme: _appBarTheme(textTheme),
      dividerTheme: DividerThemeData(
        color: outlineVariant,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: onSurfaceVariant),
      splashColor: primary.withOpacity(0.1),
      highlightColor: primary.withOpacity(0.05),
    );
  }
}
