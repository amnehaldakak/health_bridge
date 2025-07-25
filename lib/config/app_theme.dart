import 'package:flutter/material.dart';
import 'package:health_bridge/constant/color.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: blue3,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: blue2,
    iconTheme: IconThemeData(color: blue5),
    titleTextStyle: TextStyle(
      color: blue5,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    foregroundColor: blue5,
    elevation: 0,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: blue1,
    selectedItemColor: blue3,
    unselectedItemColor: blue4,
    showUnselectedLabels: true,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: blue1),
    bodyMedium: TextStyle(color: blue1),
    bodySmall: TextStyle(color: blue2),
    titleLarge: TextStyle(color: blue1, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: blue2),
    titleSmall: TextStyle(color: blue3),
    labelLarge: TextStyle(color: blue3),
    labelMedium: TextStyle(color: blue2),
    labelSmall: TextStyle(color: blue3),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(blue3),
      foregroundColor: MaterialStatePropertyAll(blue5),
      textStyle:
          MaterialStatePropertyAll(TextStyle(fontWeight: FontWeight.bold)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStatePropertyAll(blue3),
      textStyle:
          MaterialStatePropertyAll(TextStyle(fontWeight: FontWeight.bold)),
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
  ),
);
