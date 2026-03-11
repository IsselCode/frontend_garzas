import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'consts.dart';

ThemeData darkTheme = ThemeData(

    scaffoldBackgroundColor: AppColors.darkBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      surfaceTintColor: Colors.transparent
    ),

    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      error: AppColors.red,
      onError: AppColors.white,
      surface: AppColors.darkBackSurface,
      onSurface: AppColors.white,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: CircleBorder(),
      elevation: 1
    ),

    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      tileColor: AppColors.darkBackSurface
    ),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.roboto(fontSize: 44, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.roboto(fontSize: 40, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.roboto(fontSize: 38, fontWeight: FontWeight.bold),
      headlineLarge: GoogleFonts.roboto(fontSize: 34, fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.roboto(fontSize: 32, fontWeight: FontWeight.bold),
      headlineSmall: GoogleFonts.roboto(fontSize: 30, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 28, fontWeight: FontWeight.bold),
      titleMedium: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
      bodyLarge: GoogleFonts.roboto(fontSize: 18),
      bodyMedium: GoogleFonts.roboto(fontSize: 16),
      labelLarge: GoogleFonts.roboto(fontSize: 13),
      labelMedium: GoogleFonts.roboto(fontSize: 12),
      labelSmall: GoogleFonts.roboto(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.grey),
    )

);

ThemeData lightTheme = ThemeData(

    scaffoldBackgroundColor: AppColors.lightBackground,

    appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        surfaceTintColor: Colors.transparent
    ),

    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.black,
      error: AppColors.red,
      onError: AppColors.black,
      surface: AppColors.whiteBackSurface,
      onSurface: AppColors.black,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: CircleBorder(),
        elevation: 1
    ),

    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      tileColor: AppColors.whiteBackSurface
    ),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.roboto(fontSize: 44, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.roboto(fontSize: 40, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.roboto(fontSize: 38, fontWeight: FontWeight.bold),
      headlineLarge: GoogleFonts.roboto(fontSize: 34, fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.roboto(fontSize: 32, fontWeight: FontWeight.bold),
      headlineSmall: GoogleFonts.roboto(fontSize: 30, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 28, fontWeight: FontWeight.bold),
      titleMedium: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
      bodyLarge: GoogleFonts.roboto(fontSize: 18),
      bodyMedium: GoogleFonts.roboto(fontSize: 16),
      labelLarge: GoogleFonts.roboto(fontSize: 13),
      labelMedium: GoogleFonts.roboto(fontSize: 12),
      labelSmall: GoogleFonts.roboto(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.grey),
    )

);