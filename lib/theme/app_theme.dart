import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// VaultKey design system — Material 3 theme (dark & light).
///
/// Tokens extracted from stitch_vaultkey_secure_password_manager prototypes.
/// Switch palettes at runtime by setting [isDark].
class AppTheme {
  AppTheme._();

  /// Current palette: dark by default. Toggled at runtime.
  static bool isDark = true;

  static Color _t(Color dark, Color light) => isDark ? dark : light;

  // --------------------------------------------------------------------------
  // Colors (dark / light pairs)
  // --------------------------------------------------------------------------

  static Color get background =>
      _t(const Color(0xFF0e131f), const Color(0xFFF1F4FB));
  static Color get surface =>
      _t(const Color(0xFF0e131f), const Color(0xFFF7F9FE));
  static Color get surfaceDim =>
      _t(const Color(0xFF0e131f), const Color(0xFFD9DEE8));
  static Color get surfaceBright =>
      _t(const Color(0xFF343946), const Color(0xFFF7F9FE));
  static Color get surfaceContainerLowest =>
      _t(const Color(0xFF090e1a), const Color(0xFFFFFFFF));
  static Color get surfaceContainerLow =>
      _t(const Color(0xFF161b28), const Color(0xFFF1F4FB));
  static Color get surfaceContainer =>
      _t(const Color(0xFF1a1f2c), const Color(0xFFE9EDF6));
  static Color get surfaceContainerHigh =>
      _t(const Color(0xFF252a37), const Color(0xFFE3E8F2));
  static Color get surfaceContainerHighest =>
      _t(const Color(0xFF303542), const Color(0xFFDDE2EE));
  static Color get onSurface =>
      _t(const Color(0xFFdee2f3), const Color(0xFF1A2233));
  static Color get onSurfaceVariant =>
      _t(const Color(0xFFc2c6d6), const Color(0xFF4C5568));
  static Color get inverseSurface =>
      _t(const Color(0xFFdee2f3), const Color(0xFF1A2233));
  static Color get inverseOnSurface =>
      _t(const Color(0xFF2b303d), const Color(0xFFF1F4FB));
  static Color get outline =>
      _t(const Color(0xFF8c909f), const Color(0xFF747C90));
  static Color get outlineVariant =>
      _t(const Color(0xFF424754), const Color(0xFFC3CAD8));
  static Color get surfaceTint =>
      _t(const Color(0xFFadc6ff), const Color(0xFF2E5BD6));
  static Color get surfaceVariant =>
      _t(const Color(0xFF303542), const Color(0xFFDDE2EE));

  static Color get primary =>
      _t(const Color(0xFFadc6ff), const Color(0xFF2E5BD6));
  static Color get onPrimary =>
      _t(const Color(0xFF002e6a), const Color(0xFFFFFFFF));
  static Color get primaryContainer =>
      _t(const Color(0xFF4d8eff), const Color(0xFF4D8EFF));
  static Color get onPrimaryContainer =>
      _t(const Color(0xFF00285d), const Color(0xFF0B2E6E));
  static Color get inversePrimary =>
      _t(const Color(0xFF005ac2), const Color(0xFFADC6FF));

  static Color get secondary =>
      _t(const Color(0xFF4edea3), const Color(0xFF00875A));
  static Color get onSecondary =>
      _t(const Color(0xFF003824), const Color(0xFFFFFFFF));
  static Color get secondaryContainer =>
      _t(const Color(0xFF00a572), const Color(0xFF9EF2CC));
  static Color get onSecondaryContainer =>
      _t(const Color(0xFF00311f), const Color(0xFF00381F));

  static Color get tertiary =>
      _t(const Color(0xFFffb95f), const Color(0xFFB46B00));
  static Color get onTertiary =>
      _t(const Color(0xFF472a00), const Color(0xFFFFFFFF));
  static Color get tertiaryContainer =>
      _t(const Color(0xFFca8100), const Color(0xFFFFDDB3));
  static Color get onTertiaryContainer =>
      _t(const Color(0xFF3e2400), const Color(0xFF4A2A00));

  static Color get error =>
      _t(const Color(0xFFffb4ab), const Color(0xFFBA1A1A));
  static Color get onError =>
      _t(const Color(0xFF690005), const Color(0xFFFFFFFF));
  static Color get errorContainer =>
      _t(const Color(0xFF93000a), const Color(0xFFFFDAD6));
  static Color get onErrorContainer =>
      _t(const Color(0xFFffdad6), const Color(0xFF410002));

  static Color get primaryFixed =>
      _t(const Color(0xFFd8e2ff), const Color(0xFFD8E2FF));
  static Color get primaryFixedDim =>
      _t(const Color(0xFFadc6ff), const Color(0xFFADC6FF));
  static Color get onPrimaryFixed =>
      _t(const Color(0xFF001a42), const Color(0xFF001A42));
  static Color get onPrimaryFixedVariant =>
      _t(const Color(0xFF004395), const Color(0xFF004395));

  static Color get secondaryFixed =>
      _t(const Color(0xFF6ffbbe), const Color(0xFF6FFBBE));
  static Color get secondaryFixedDim =>
      _t(const Color(0xFF4edea3), const Color(0xFF4EDEA3));
  static Color get onSecondaryFixed =>
      _t(const Color(0xFF002113), const Color(0xFF002113));
  static Color get onSecondaryFixedVariant =>
      _t(const Color(0xFF005236), const Color(0xFF005236));

  static Color get tertiaryFixed =>
      _t(const Color(0xFFffddb8), const Color(0xFFFFDDB8));
  static Color get tertiaryFixedDim =>
      _t(const Color(0xFFffb95f), const Color(0xFFFFB95F));
  static Color get onTertiaryFixed =>
      _t(const Color(0xFF2a1700), const Color(0xFF2A1700));
  static Color get onTertiaryFixedVariant =>
      _t(const Color(0xFF653e00), const Color(0xFF653E00));

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
        borderSide: BorderSide(color: primary, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: error, width: 1),
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: onSurfaceVariant.withValues(alpha: 0.5),
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
            shadowColor: primary.withValues(alpha: 0.15),
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.white.withValues(alpha: 0.1);
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
            side: BorderSide(color: surfaceContainerHighest),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.all(
              surfaceContainerHigh.withValues(alpha: 0.3),
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

  static CardThemeData _cardTheme() {
    return CardThemeData(
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
      backgroundColor: surface.withValues(alpha: 0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.headlineMedium?.copyWith(color: onSurface),
      iconTheme: IconThemeData(color: onSurfaceVariant),
      actionsIconTheme: IconThemeData(color: onSurfaceVariant),
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
      colorScheme: ColorScheme(
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
        scrim: Color(0x99000000),
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
      iconTheme: IconThemeData(color: onSurfaceVariant),
      splashColor: primary.withValues(alpha: 0.1),
      highlightColor: primary.withValues(alpha: 0.05),
    );
  }

  /// Light theme (same design tokens, light palette).
  static ThemeData lightTheme(BuildContext context) {
    final textTheme = _textTheme(context);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
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
        shadow: Colors.black26,
        scrim: const Color(0x66000000),
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
      iconTheme: IconThemeData(color: onSurfaceVariant),
      splashColor: primary.withValues(alpha: 0.1),
      highlightColor: primary.withValues(alpha: 0.05),
    );
  }
}
