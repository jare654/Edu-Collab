import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_tokens.dart';

class AppTheme {
  static const bool _disableGoogleFonts = bool.fromEnvironment(
    'DISABLE_GOOGLE_FONTS',
    defaultValue: false,
  );
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryContainer = Color(0xFF1E3A8A);
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryContainer = Colors.white;
  static const Color secondary = Color(0xFFBFDBFE);
  static const Color secondaryContainer = Color(0xFFDBEAFE);
  static const Color tertiary = Color(0xFFF59E0B);
  static const Color tertiaryContainer = Color(0xFFFEF3C7);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFF8FAFC);
  static const Color surfaceContainer = Color(0xFFEEF4FF);
  static const Color surfaceHigh = Color(0xFFE0EAFF);
  static const Color surfaceHighest = Color(0xFFD5E3FF);
  static const Color surfaceBright = Color(0xFFCADBFF);
  static const Color outline = Color(0xFFD7E3F6);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFF43F5E);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: textPrimary,
        tertiary: tertiary,
        onTertiary: textPrimary,
        error: danger,
        onError: onPrimary,
        surface: surface,
        onSurface: textPrimary,
      ),
    );
    final bodyTheme = _disableGoogleFonts
        ? base.textTheme
        : GoogleFonts.outfitTextTheme(base.textTheme);
    final displayTheme = _disableGoogleFonts
        ? base.textTheme
        : GoogleFonts.syneTextTheme(base.textTheme);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: bodyTheme
          .copyWith(
            displayLarge: displayTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            displayMedium: displayTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            displaySmall: displayTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            headlineLarge: displayTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            headlineMedium: displayTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            headlineSmall: displayTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            titleLarge: displayTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            titleMedium: displayTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          )
          .apply(bodyColor: textPrimary, displayColor: textPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textPrimary,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: outline.withValues(alpha: 0.9)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide(color: outline.withValues(alpha: 0.9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: const BorderSide(color: danger, width: 1.1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: const BorderSide(color: danger, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: const TextStyle(color: textTertiary),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: outline.withValues(alpha: 0.95)),
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surfaceContainer,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        side: BorderSide(color: outline.withValues(alpha: 0.85)),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            borderSide: BorderSide(color: outline.withValues(alpha: 0.9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            borderSide: const BorderSide(color: primary, width: 1.4),
          ),
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(surface),
          surfaceTintColor: const WidgetStatePropertyAll<Color>(
            Colors.transparent,
          ),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              side: BorderSide(color: outline.withValues(alpha: 0.9)),
            ),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: const WidgetStatePropertyAll<Color>(
          Colors.transparent,
        ),
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (states) =>
              states.contains(WidgetState.selected) ? Colors.white : surface,
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (states) =>
              states.contains(WidgetState.selected) ? primary : surfaceHigh,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF60A5FA),
        onPrimary: Colors.white,
        secondary: Color(0xFF1E3A8A),
        onSecondary: Colors.white,
        tertiary: Color(0xFFF59E0B),
        onTertiary: Color(0xFF0F172A),
        error: Color(0xFFFB7185),
        onError: Colors.white,
        surface: Color(0xFF0B1220),
        onSurface: Color(0xFFE2E8F0),
      ),
    );
    final bodyTheme = _disableGoogleFonts
        ? base.textTheme
        : GoogleFonts.outfitTextTheme(base.textTheme);
    final displayTheme = _disableGoogleFonts
        ? base.textTheme
        : GoogleFonts.syneTextTheme(base.textTheme);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: bodyTheme
          .copyWith(
            displayLarge: displayTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            displayMedium: displayTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            displaySmall: displayTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            headlineLarge: displayTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            headlineMedium: displayTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            headlineSmall: displayTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            titleLarge: displayTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            titleMedium: displayTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          )
          .apply(
            bodyColor: const Color(0xFFE2E8F0),
            displayColor: const Color(0xFFE2E8F0),
          ),
      cardTheme: CardThemeData(
        color: const Color(0xFF111A2A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: Color(0xFF23314A)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: const BorderSide(color: Color(0xFF23314A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: const BorderSide(color: Color(0xFF60A5FA), width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        labelStyle: const TextStyle(
          color: Color(0xFFCBD5E1),
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE2E8F0),
          side: const BorderSide(color: Color(0xFF334155)),
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: Color(0xFF60A5FA),
        unselectedItemColor: Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
    );
  }
}
