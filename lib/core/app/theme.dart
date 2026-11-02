import 'package:flutter/material.dart';

import 'consts.dart';

TextStyle _roboto(
  double fontSize, {
  FontWeight fontWeight = FontWeight.normal,
  Color? color,
}) {
  return TextStyle(
    fontFamily: 'Roboto',
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}

TextTheme _appTextTheme() => TextTheme(
  displayLarge: _roboto(44, fontWeight: FontWeight.bold),
  displayMedium: _roboto(40, fontWeight: FontWeight.bold),
  displaySmall: _roboto(38, fontWeight: FontWeight.bold),
  headlineLarge: _roboto(34, fontWeight: FontWeight.bold),
  headlineMedium: _roboto(32, fontWeight: FontWeight.bold),
  headlineSmall: _roboto(30, fontWeight: FontWeight.bold),
  titleLarge: _roboto(28, fontWeight: FontWeight.bold),
  titleMedium: _roboto(26, fontWeight: FontWeight.bold),
  titleSmall: _roboto(25, fontWeight: FontWeight.bold),
  bodyLarge: _roboto(25),
  bodyMedium: _roboto(22),
  labelLarge: _roboto(17, fontWeight: FontWeight.w500, color: AppColors.grey),
  labelMedium: _roboto(16, fontWeight: FontWeight.w500, color: AppColors.grey),
  labelSmall: _roboto(15, fontWeight: FontWeight.w500, color: AppColors.grey),
);

ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.darkBackground,

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkBackground,
    surfaceTintColor: Colors.transparent,
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
    surfaceContainer: AppColors.darkBackground,
    onSurface: AppColors.white,
    outline: AppColors.grey,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    shape: CircleBorder(),
    elevation: 1,
  ),

  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    tileColor: AppColors.darkBackSurface,
  ),

  textTheme: _appTextTheme(),
);

ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.lightBackground,

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.lightBackground,
    surfaceTintColor: Colors.transparent,
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
    surfaceContainer: AppColors.lightBackground,
    onSurface: AppColors.black,
    outline: AppColors.grey,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    shape: CircleBorder(),
    elevation: 1,
  ),

  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    tileColor: AppColors.whiteBackSurface,
  ),

  textTheme: _appTextTheme(),
);
