import 'package:flutter/material.dart';

final ThemeData icafeTheme = ThemeData(
  primarySwatch: Colors.indigo,
  scaffoldBackgroundColor: Colors.grey[100],
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
);
