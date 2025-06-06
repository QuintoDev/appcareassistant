import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import '../theme/app_theme.dart';

void main() {
  runApp(const CareAssistantApp());
}

class CareAssistantApp extends StatelessWidget {
  const CareAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareAssistant',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
