import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

ThemeData get appTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: energyYellow,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: lightBackground,
  textTheme: const TextTheme().apply(bodyColor: energyInk, displayColor: energyInk),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: lightSurface,
    contentPadding: const EdgeInsets.all(14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: lightLine),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: lightLine),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF9C7B18), width: 2),
    ),
  ),
  cardTheme: CardThemeData(
    color: lightSurface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
    margin: const EdgeInsets.only(top: 14),
  ),
  dividerTheme: DividerThemeData(color: lightLine, thickness: 1, space: 24),
  chipTheme: ChipThemeData(
    backgroundColor: energyYellow.withAlpha(22),
    labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: energyYellow,
      foregroundColor: energyInk,
      minimumSize: const Size(0, 49),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF7B5B00),
      padding: EdgeInsets.zero,
      minimumSize: const Size(44, 44),
      alignment: Alignment.centerLeft,
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: energyInk,
      side: const BorderSide(color: lightLine),
      minimumSize: const Size(0, 49),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
    ),
  ),
  iconTheme: const IconThemeData(color: energyInk),
  appBarTheme: const AppBarTheme(
    backgroundColor: lightBackground,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: energyInk,
      fontSize: 19,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
    ),
  ),
);