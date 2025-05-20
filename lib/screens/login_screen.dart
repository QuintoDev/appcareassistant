import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../utils/decode_user_id.dart';
import '../screens/register_screen.dart';
import '../screens/patient_home_screen.dart';
import '../screens/professional_home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      SvgPicture.asset(
                        'assets/images/careassistant_logo.svg',
                        width: 200,
                      ),
                      const SizedBox(height: 50),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: CustomTextField(
                          label: 'Correo',
                          icon: Icons.email_outlined,
                          controller: emailController,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: CustomTextField(
                          label: 'Contraseña',
                          icon: Icons.lock_outline,
                          controller: passwordController,
                          obscure: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00AEBE),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();

                            final success = await AuthService.login(
                              email,
                              password,
                            );

                            if (success) {
                              final userId = await decodeUserIdFromToken();
                              final userData = await ApiService.getUserById(
                                userId,
                              );

                              final String nombre = userData['nombre'];

                              if (context.mounted) {
                                final String rol = userData['tipo'];

                                if (context.mounted) {
                                  if (rol == 'PACIENTE') {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => PatientHomeScreen(
                                              nombre: nombre,
                                            ),
                                      ),
                                    );
                                  } else if (rol == 'PROFESIONAL_SALUD') {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ProfessionalHomeScreen(
                                              nombre: nombre,
                                            ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Rol no soportado'),
                                      ),
                                    );
                                  }
                                }
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Corrreo o contraseña incorrectos',
                                  ),
                                  backgroundColor: const Color(0xFFE63946),
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                            }
                          },
                          child: const Text('Iniciar Sesión'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF00AEBE),
                    side: const BorderSide(color: Color(0xFF00AEBE)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },

                  child: const Text('Registrarse'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
