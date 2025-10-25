import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App-wide theme configuration. Centralizes typography and colors so that
/// future feature screens stay consistent.
class WenColors {
  WenColors._();

  static const seed = Color(0xFF0EA5E9);
  static const accent = Color(0xFF7C3AED);
  static const surfaceTint = Color(0xFFF8FAFC);
}

class WenTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: WenColors.seed,
      brightness: Brightness.light,
    );
    final textTheme = GoogleFonts.cairoTextTheme(base.textTheme);

    return _baseTheme(base, colorScheme, textTheme).copyWith(
      scaffoldBackgroundColor: WenColors.surfaceTint,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: WenColors.seed,
      brightness: Brightness.dark,
    );
    final textTheme = GoogleFonts.cairoTextTheme(base.textTheme);
    return _baseTheme(
      base,
      colorScheme,
      textTheme,
    ).copyWith(scaffoldBackgroundColor: colorScheme.surface);
  }

  static ThemeData _baseTheme(
    ThemeData base,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.12),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: WenColors.accent,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.primary,
        titleTextStyle: textTheme.bodyLarge,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}
