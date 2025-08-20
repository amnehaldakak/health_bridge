import 'package:flutter/material.dart';
import 'package:health_bridge/constant/color.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: blue3,
  scaffoldBackgroundColor: Colors.white,
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: blue3),
    titleTextStyle: TextStyle(
      color: blue3,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: blue3,
    unselectedItemColor: blue4,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: blue1, fontSize: 16),
    bodyMedium: TextStyle(color: blue1, fontSize: 14),
    bodySmall: TextStyle(color: blue2, fontSize: 12),
    titleLarge:
        TextStyle(color: blue1, fontSize: 20, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: blue2, fontSize: 16),
    titleSmall: TextStyle(color: blue3, fontSize: 14),
    labelLarge: TextStyle(color: blue3, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(color: blue2),
    labelSmall: TextStyle(color: blue3),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(blue3),
      foregroundColor: MaterialStatePropertyAll(blue5),
      elevation: MaterialStatePropertyAll(0),
      padding: MaterialStatePropertyAll(
          EdgeInsets.symmetric(vertical: 12, horizontal: 20)),
      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      )),
      textStyle: MaterialStatePropertyAll(TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      )),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStatePropertyAll(blue3),
      textStyle: MaterialStatePropertyAll(TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      )),
    ),
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: blue3,
    secondary: blue2,
    background: Colors.white,
    onPrimary: blue5,
    onSecondary: blue3,
    onBackground: blue1,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: blue3,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: blue4.withOpacity(0.2),
    thickness: 1,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: blue4.withOpacity(0.5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: blue4.withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: blue3, width: 2),
    ),
    labelStyle: const TextStyle(color: blue2),
    prefixIconColor: blue3,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: blue3,
    contentTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 4,
    actionTextColor: blue5,
  ),
);
