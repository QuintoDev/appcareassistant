import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
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
  final List<String> diasSemana = [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];
  final Set<String> disponibilidadSeleccionada = {};
  final bioController = TextEditingController();
  final availabilityController = TextEditingController();

  String selectedRole = 'PACIENTE';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Crea tu cuenta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF00AEBE),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Te vas a registrar como:',
                        labelStyle: const TextStyle(fontSize: 14),
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF00AEBE),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF00AEBE),
                            width: 1,
                          ),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'PACIENTE',
                          child: Text(
                            'Paciente',
                            style: TextStyle(color: Color(0xFF00AEBE)),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'PROFESIONAL_SALUD',
                          child: Text(
                            'Profesional',
                            style: TextStyle(color: Color(0xFF00AEBE)),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

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

                    if (selectedRole == 'PROFESIONAL_SALUD') ...[
                      const SizedBox(height: 10),
                      CustomTextField(
                        label: 'Especialidad',
                        icon: Icons.medical_services,
                        controller: specialtyController,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF00AEBE),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.schedule, color: Color(0xFF00AEBE)),
                                SizedBox(width: 8),
                                Text(
                                  'Disponibilidad',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  diasSemana.map((dia) {
                                    final activo = disponibilidadSeleccionada
                                        .contains(dia);
                                    return ChoiceChip(
                                      label: Text(dia),
                                      selected: activo,
                                      selectedColor: const Color(0xFF00AEBE),
                                      labelStyle: TextStyle(
                                        color:
                                            activo
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                      onSelected: (valor) {
                                        setState(() {
                                          if (valor) {
                                            disponibilidadSeleccionada.add(dia);
                                          } else {
                                            disponibilidadSeleccionada.remove(
                                              dia,
                                            );
                                          }
                                          availabilityController
                                              .text = disponibilidadSeleccionada
                                              .join(', ');
                                        });
                                      },
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      CustomTextField(
                        label: 'Presentación',
                        icon: Icons.description,
                        controller: bioController,
                      ),
                    ],

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEBE),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final success = await AuthService.register(
                            nombre: firstNameController.text.trim(),
                            apellido: lastNameController.text.trim(),
                            correo: emailController.text.trim(),
                            contrasena: passwordController.text.trim(),
                            ciudad: cityController.text.trim(),
                            rol: selectedRole,
                            celular: phoneController.text.trim(),
                            edad: ageController.text.trim(),
                            parentesco: relationshipController.text.trim(),
                            especialidad: specialtyController.text.trim(),
                            disponibilidad:
                                disponibilidadSeleccionada.toList(), // AQUÍ
                            presentacion: bioController.text.trim(),
                          );

                          if (!context.mounted) return;

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Registro exitoso'),
                                backgroundColor: Color(0xFF2ECC71),
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(16),
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Error al registrar. Verifica los datos.',
                                ),
                                backgroundColor: Color(0xFFE63946),
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(16),
                              ),
                            );
                          }
                        },
                        child: const Text('Registrarse'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
