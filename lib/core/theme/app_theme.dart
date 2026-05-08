import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static TextTheme _textTheme(Color base) => GoogleFonts.nunitoTextTheme(
        TextTheme(
          displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: base),
          displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: base),
          headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: base),
          headlineMedium:TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: base),
          titleLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: base),
          titleMedium:   TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: base),
          titleSmall:    TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: base),
          bodyLarge:     TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: base),
          bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: base),
          bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: base),
          labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: base),
          labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: base),
        ),
      );

  static ThemeData light() {
    const primary   = Color(0xFF4F6AF5);
    const secondary = Color(0xFF34C78A);
    const onSurface = Color(0xFF1A1D2E);

    final base = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: const Color(0xFFE53935),
      surface: Colors.white,
      onSurface: onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      textTheme: _textTheme(onSurface),
      scaffoldBackgroundColor: const Color(0xFFEEF2FF), // gradient start colour as fallback
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF4F6AF5),
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: Colors.white,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        minVerticalPadding: 10,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F4FF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDE3FF), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static ThemeData dark() {
    const primary   = Color(0xFF00D68F);
    const secondary = Color(0xFF7B8BFF);
    const onSurface = Color(0xFFE8EAED);

    final base = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primary,
      onPrimary: const Color(0xFF0F1117),
      secondary: secondary,
      onSecondary: const Color(0xFF0F1117),
      error: const Color(0xFFFF6584),
      surface: const Color(0xFF1A1D2E),
      onSurface: onSurface,
      surfaceContainerHighest: const Color(0xFF222539),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      textTheme: _textTheme(onSurface),
      scaffoldBackgroundColor: const Color(0xFF0F1117),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF141725),
        foregroundColor: onSurface,
        elevation: 0,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        iconTheme: const IconThemeData(color: Color(0xFFE8EAED)),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: const Color(0xFF1E2235),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: const Color(0xFF0F1117),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        minVerticalPadding: 10,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E2235),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D3555), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
