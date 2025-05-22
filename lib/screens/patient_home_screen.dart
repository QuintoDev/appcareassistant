import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/decode_user_id.dart';
import '../widgets/assistant_bottom_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  final String nombre;

  const PatientHomeScreen({super.key, required this.nombre});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  late Future<List<dynamic>> citas = Future.value([]);

  @override
  void initState() {
    super.initState();
    cargarCitas();
  }

  Future<void> cargarCitas() async {
    final userId = await decodeUserIdFromToken();
    setState(() {
      citas = ApiService.getAppointmentsForPatient(userId);
    });
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':
        return const Color(0xFFFFF3CD);
      case 'CONFIRMADA':
        return const Color(0xFFD4EDDA);
      case 'CANCELADA':
        return const Color(0xFFF8D7DA);
      default:
        return const Color(0xFFF0F0F0);
    }
  }

  Color _getEstadoTextColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':
        return const Color(0xFF856404);
      case 'CONFIRMADA':
        return const Color(0xFF155724);
      case 'CANCELADA':
        return const Color(0xFF721C24);
      default:
        return Colors.black87;
    }
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
              // Encabezado con fondo blanco
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
                              'Qué gusto tenerte de vuelta',
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
                        tooltip: 'Cerrar sesión',
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
                          final profesional = cita['profesional'];
                          final nombreProfesional =
                              profesional != null
                                  ? '${profesional['nombre']} ${profesional['apellido']}'
                                  : 'Por asignar';
                          final especialidad =
                              profesional?['especialidad'] ?? 'Sin definir';
                          final estado = cita['estado'] ?? '';
                          final cardColor = _getEstadoColor(estado);
                          final estadoTextColor = _getEstadoTextColor(estado);

                          return Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                              expansionTileTheme: ExpansionTileThemeData(
                                backgroundColor: cardColor,
                                collapsedBackgroundColor: cardColor,
                              ),
                            ),
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              child: ExpansionTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Text(
                                  '${especialidad[0].toUpperCase()}${especialidad.substring(1).toLowerCase()} - ${estado[0].toUpperCase()}${estado.substring(1).toLowerCase()}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: estadoTextColor,
                                  ),
                                ),
                                subtitle: Text('Con $nombreProfesional'),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Fecha: ${cita['fecha'].toString().split("T")[0]}',
                                            ),
                                            const SizedBox(width: 16),
                                            const Icon(
                                              Icons.access_time,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 5),
                                            Text('Hora: ${cita['hora']}'),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Ubicación: ${cita['ubicacion']}',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.info_outline,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 5),
                                            Expanded(
                                              child: Text(
                                                'Resumen: ${cita['resumen']}',
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00AEBE),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.smart_toy_outlined),
        label: const Text('Asistente'),
        tooltip: 'Da click sobre mi para ayudarte a crear una cita',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AssistantBottomDialog(nombre: widget.nombre, onAppointmentCreated: cargarCitas),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
