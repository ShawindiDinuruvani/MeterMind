
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand colors
  static const Color yellow = Color(0xFFF5C542);
  static const Color yellowLight = Color(0x33F5C542);
  static const Color ink = Color(0xFF202523);
  static const Color soft = Color(0xFFF4F5F0);
  static const Color muted = Color(0xFF626B66);
  static const Color line = Color(0xFFDEE3DB);

  // Semantic status colors
  static const Color green = Color(0xFF237548);
  static const Color greenLight = Color(0xFFE7F2E9);

  static const Color red = Color(0xFFB94338);
  static const Color redLight = Color(0xFFFBECE8);

  static const Color amber = Color(0xFF936715);
  static const Color amberLight = Color(0xFFFBEFD5);

  static const Color blue = Color(0xFF306F94);
  static const Color blueLight = Color(0xFFE8F0F7);

  // Glassmorphism colors
  static const Color glassStart = Color(0xFF353E36);
  static const Color glassEnd = Color(0xFF1C2421);
  static const Color glassBorder = Color(0xFF657060);
  static const Color glassText = Color(0xFFFAFCF8);
  static const Color glassSub = Color(0xFFC5D0C3);

  // Dark mode colors
  static const Color darkBg = Color(0xFF19221D);
  static const Color darkCard = Color(0xFF253029);
  static const Color darkLine = Color(0xFF465044);
  static const Color darkText = Color(0xFFEFF4EA);
  static const Color darkMuted = Color(0xFFB6C3B4);

  // Backward-compatible aliases
  static const Color energyYellow = yellow;
  static const Color background = soft;
}

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.soft,
      colorScheme: const ColorScheme.light(
        primary: AppColors.yellow,
        onPrimary: AppColors.ink,
        surface: Colors.white,
        onSurface: AppColors.ink,
        outline: AppColors.line,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.soft,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.ink,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellow,
          foregroundColor: AppColors.ink,
          elevation: 0,
          minimumSize: const Size.fromHeight(49),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.ink,
          side: const BorderSide(
            color: AppColors.line,
            width: 1,
          ),
          minimumSize: const Size.fromHeight(49),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFBFC9BC),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFBFC9BC),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF9C7B18),
            width: 2,
          ),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.muted,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(21),
          side: const BorderSide(
            color: AppColors.line,
          ),
        ),
        margin: const EdgeInsets.only(top: 14),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.yellow,
        onPrimary: AppColors.ink,
        surface: AppColors.darkCard,
        onSurface: AppColors.darkText,
        outline: AppColors.darkLine,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.darkText,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.darkText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellow,
          foregroundColor: AppColors.ink,
          elevation: 0,
          minimumSize: const Size.fromHeight(49),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.darkCard,
          foregroundColor: AppColors.darkText,
          side: const BorderSide(
            color: AppColors.darkLine,
            width: 1,
          ),
          minimumSize: const Size.fromHeight(49),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.darkLine,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.darkLine,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.yellow,
            width: 2,
          ),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.darkMuted,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(21),
          side: const BorderSide(
            color: AppColors.darkLine,
          ),
        ),
        margin: const EdgeInsets.only(top: 14),
      ),
    );
  }
}

