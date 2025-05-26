import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import '../theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
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
