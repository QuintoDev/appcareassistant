import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/patient_home_screen.dart';
import 'screens/professional_home_screen.dart';
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
      //home: const LoginScreen(),
      home: const PatientHomeScreen(nombre: 'Usuario'), // Cambia esto para probar
      //home: const ProfessionalHomeScreen(nombre: 'Usuario'), // Cambia esto para probar
    );
  }
}
