import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: const Color(0xFF00AEBE),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'inter',
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      labelStyle: const TextStyle(fontSize: 14),
    ),
  );
}
