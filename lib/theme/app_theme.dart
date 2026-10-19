import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const cream = Color(0xFFF6F4EE);
  static const ink = Color(0xFF1C1C1A);
  static const green = Color(0xFF1F5C45);
  static const greenSoft = Color(0xFFE4F0E9);
  static const muted = Color(0xFF8C8C84);
  static const card = Color(0xFFFFFCF8);
  static const line = Color(0xFFE7E3D9);

  static const darkBg = Color(0xFF161815);
  static const darkInk = Color(0xFFF3F1EA);
  static const darkCard = Color(0xFF232522);
  static const darkLine = Color(0xFF31342F);
  static const darkMuted = Color(0xFF9B9C95);
  static const mint = Color(0xFF8FCBB0);
}

class AppTheme {
  static ThemeData light() => _build(
        brightness: Brightness.light,
        bg: AppColors.cream,
        ink: AppColors.ink,
        muted: AppColors.muted,
        card: AppColors.card,
        line: AppColors.line,
        accent: AppColors.green,
        onAccent: Colors.white,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        bg: AppColors.darkBg,
        ink: AppColors.darkInk,
        muted: AppColors.darkMuted,
        card: AppColors.darkCard,
        line: AppColors.darkLine,
        accent: AppColors.mint,
        onAccent: AppColors.darkBg,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color ink,
    required Color muted,
    required Color card,
    required Color line,
    required Color accent,
    required Color onAccent,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: accent,
        onPrimary: onAccent,
        secondary: accent,
        onSecondary: onAccent,
        error: const Color(0xFFB42318),
        onError: Colors.white,
        surface: card,
        onSurface: ink,
      ),
    );
    final sans = GoogleFonts.sourceSans3TextTheme(base.textTheme).apply(
      bodyColor: ink,
      displayColor: ink,
    );
    return base.copyWith(
      textTheme: sans,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }

  static TextStyle serif(BuildContext context, double size, {FontWeight weight = FontWeight.w500, double height = 1.05}) {
    return GoogleFonts.newsreader(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: Theme.of(context).colorScheme.onSurface,
      letterSpacing: -0.4,
    );
  }

  static TextStyle label(BuildContext context) {
    return GoogleFonts.sourceSans3(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.6,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
    );
  }
}
