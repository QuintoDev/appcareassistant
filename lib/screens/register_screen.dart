import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Comunes
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final cityController = TextEditingController();

  // Solo PACIENTE
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final relationshipController = TextEditingController();

  // Solo PROFESIONAL
  final specialtyController = TextEditingController();
  final availabilityController = TextEditingController();
  final bioController = TextEditingController();

  String selectedRole = 'PACIENTE';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF00AEBE),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: const EdgeInsets.only(top: 32),
              width: MediaQuery.of(context).size.width * 0.7,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Te vas a registrar como:',
                      labelStyle: const TextStyle(
                        fontFamily: 'inter',
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF00AEBE),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Color(0xFF00AEBE),
                          width: 2,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'PACIENTE',
                        child: Text(
                          'Paciente',
                          style: TextStyle(fontFamily: 'inter', fontSize: 14),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'PROFESIONAL_SALUD',
                        child: Text(
                          'Profesional',
                          style: TextStyle(fontFamily: 'inter', fontSize: 14),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),

                  // Comunes
                  CustomTextField(
                    label: 'Nombre',
                    icon: Icons.person_outline,
                    controller: firstNameController,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Apellido',
                    icon: Icons.person_outline,
                    controller: lastNameController,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Correo electrónico',
                    icon: Icons.email_outlined,
                    controller: emailController,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Contraseña',
                    icon: Icons.lock_outline,
                    controller: passwordController,
                    obscure: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Ciudad',
                    icon: Icons.location_city,
                    controller: cityController,
                  ),

                  // Solo PACIENTE
                  if (selectedRole == 'PACIENTE') ...[
                    const SizedBox(height: 10),
                    CustomTextField(
                      label: 'Celular',
                      icon: Icons.phone,
                      controller: phoneController,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      label: 'Edad',
                      icon: Icons.cake_outlined,
                      controller: ageController,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      label: 'Parentesco',
                      icon: Icons.group_outlined,
                      controller: relationshipController,
                    ),
                  ],

                  // Solo PROFESIONAL
                  if (selectedRole == 'PROFESIONAL_SALUD') ...[
                    const SizedBox(height: 10),
                    CustomTextField(
                      label: 'Especialidad',
                      icon: Icons.medical_services,
                      controller: specialtyController,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      label: 'Disponibilidad',
                      icon: Icons.schedule,
                      controller: availabilityController,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      label: 'Presentación',
                      icon: Icons.description,
                      controller: bioController,
                    ),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 20),
        child: SizedBox(
          height: 45,
          width: MediaQuery.of(context).size.width * 0.7,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0082B2),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final firstName = firstNameController.text.trim();
              final lastName = lastNameController.text.trim();
              final email = emailController.text.trim();
              final password = passwordController.text.trim();
              final city = cityController.text.trim();
              final role = selectedRole;

              final phone = phoneController.text.trim();
              final age = ageController.text.trim();
              final relationship = relationshipController.text.trim();

              final specialty = specialtyController.text.trim();
              final availability = availabilityController.text.trim();
              final bio = bioController.text.trim();

              final success = await AuthService.register(
                nombre: firstName,
                apellido: lastName,
                correo: email,
                contrasena: password,
                ciudad: city,
                rol: role,
                celular: phone,
                edad: age,
                parentesco: relationship,
                especialidad: specialty,
                disponibilidad: availability,
                presentacion: bio,
              );

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Registro exitoso'),
                      backgroundColor: Color(0xFF2ECC71),
                    ),
                  );
                  // Navigate to login screen or home screen
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al registrar. Verifica los datos.'),
                      backgroundColor: Color(0xFFE74C3C),
                    ),
                  );
                }
              }
            },
            child: const Text('Registrarse'),
          ),
        ),
      ),
    );
  }
}
