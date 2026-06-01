import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Palette ──────────────────────────────────────────────────────────────────

  static const Color cream = Color(0xFFF7F3ED);
  static const Color deepInk = Color(0xFF1A1714);
  static const Color warmGrey = Color(0xFF8A8279);
  static const Color dustyRose = Color(0xFFD4A8A0);
  static const Color lightDivider = Color(0xFFE8E2D8);

  // ─── Typography ───────────────────────────────────────────────────────────────

  // Primary display font: Cormorant Garamond — elegant, spiritual, literary
  static TextStyle get displayLarge => GoogleFonts.cormorantGaramond(
        fontSize: 34,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
        color: deepInk,
        height: 1.25,
      );

  static TextStyle get quoteText => GoogleFonts.cormorantGaramond(
        fontSize: 26,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.2,
        height: 1.55,
      );

  static TextStyle get bodyText => GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        height: 1.6,
      );

  static TextStyle get labelSmallCaps => GoogleFonts.lato(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
      );

  static TextStyle get cardTitle => GoogleFonts.cormorantGaramond(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  static TextStyle get nameText => GoogleFonts.lato(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 3.5,
      );

  // ─── Theme ────────────────────────────────────────────────────────────────────

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: deepInk,
        secondary: dustyRose,
        surface: cream,
        background: cream,
        onPrimary: cream,
        onSurface: deepInk,
      ),
      scaffoldBackgroundColor: cream,
      textTheme: GoogleFonts.latoTextTheme().copyWith(
        displayLarge: displayLarge,
        bodyMedium: bodyText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cream,
        foregroundColor: deepInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.0,
          color: deepInk,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: deepInk, width: 1.5),
        ),
        labelStyle: GoogleFonts.lato(
          fontSize: 13,
          color: warmGrey,
          letterSpacing: 0.5,
        ),
        hintStyle: GoogleFonts.lato(
          fontSize: 13,
          color: warmGrey.withOpacity(0.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepInk,
          foregroundColor: cream,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.lato(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}

// ─── Gradient helpers ─────────────────────────────────────────────────────────

/// Generates the gradient for a day card based on mood colors
LinearGradient moodGradient(Color primary, Color secondary) {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primary,
      Color.lerp(primary, secondary, 0.6)!,
      secondary,
    ],
    stops: const [0.0, 0.5, 1.0],
  );
}
