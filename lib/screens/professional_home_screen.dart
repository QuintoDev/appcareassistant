import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/decode_user_id.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ProfessionalHomeScreen extends StatefulWidget {
  final String nombre;

  const ProfessionalHomeScreen({super.key, required this.nombre});

  @override
  State<ProfessionalHomeScreen> createState() => _ProfessionalHomeScreenState();
}

class _ProfessionalHomeScreenState extends State<ProfessionalHomeScreen> {
  late Future<List<dynamic>> citas = Future.value([]);

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  void _cargarCitas() async {
    final userId = await decodeUserIdFromToken();
    setState(() {
      citas = ApiService.getAppointmentsForProfessional(userId);
    });
  }

  void confirmarCita(String id) async {
    await ApiService.updateAppointmentStatus(id, true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita aceptada'),
          backgroundColor: Color(0xFF2ECC71),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    }
    _cargarCitas();
  }

  void rechazarCita(String id) async {
    await ApiService.updateAppointmentStatus(id, false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita rechazada'),
          backgroundColor: Color(0xFFE74C3C),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    }
    _cargarCitas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00AEBE), Color(0xFFB2EBF2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFF00AEBE),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Que gusto tenerte de vuelta',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.nombre,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: Color(0xFF00AEBE),
                        ),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('jwt_token');
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: FutureBuilder<List<dynamic>>(
                    future: citas,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final citasList = snapshot.data!;

                      if (citasList.isEmpty) {
                        return const Center(
                          child: Text('No tienes citas asignadas.'),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: citasList.length,
                        itemBuilder: (context, index) {
                          final cita = citasList[index];

                          return Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                              expansionTileTheme: const ExpansionTileThemeData(
                                backgroundColor: Color(0xFFE0F7FA),
                                collapsedBackgroundColor: Color(0xFFE0F7FA),
                              ),
                            ),
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 2,
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                title: Row(
                                  children: const [
                                    Icon(
                                      Icons.person,
                                      color: Color(0xFF00AEBE),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Información de la cita',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF0F9FA),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15),
                                      ),
                                    ),
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Nombre: ${cita['paciente']['nombre']} ${cita['paciente']['apellido']}",
                                        ),
                                        Text(
                                          "Edad: ${cita['paciente']['edad']}",
                                        ),
                                        Text(
                                          "Celular: ${cita['paciente']['celular']}",
                                        ),
                                        Text(
                                          "Parentesco: ${cita['paciente']['parentesco']}",
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Descripción del servicio:",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(cita['resumen']),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "Fecha: ${cita['fecha'].toString().split('T')[0]}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed:
                                                  () =>
                                                      confirmarCita(cita['id']),
                                              child: const Text('Aceptar'),
                                            ),
                                            const SizedBox(width: 10),
                                            TextButton(
                                              onPressed:
                                                  () =>
                                                      rechazarCita(cita['id']),
                                              child: const Text(
                                                'Rechazar',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
