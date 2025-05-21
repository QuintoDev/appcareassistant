import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/decode_user_id.dart';
import '../widgets/assistant_bottom_dialog.dart';

class PatientHomeScreen extends StatefulWidget {
  final String nombre;

  const PatientHomeScreen({super.key, required this.nombre});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  late Future<List<dynamic>> citas;

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  void _cargarCitas() async {
    final userId = await decodeUserIdFromToken();
    setState(() {
      citas = ApiService.getAppointmentsForPatient(userId);
    });
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':
        return const Color(0xFFFFF3CD); // Amarillo suave
      case 'CONFIRMADA':
        return const Color(0xFFD4EDDA); // Verde suave
      case 'CANCELADA':
        return const Color(0xFFF8D7DA); // Rojo suave
      default:
        return const Color(0xFFF0F0F0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                    radius: 24,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hola,',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        widget.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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

                      return Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                          expansionTileTheme: ExpansionTileThemeData(
                            backgroundColor: cardColor,
                            collapsedBackgroundColor: cardColor,
                          ),
                        ),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        Text('Ubicación: ${cita['ubicacion']}'),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00AEBE),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.smart_toy_outlined),
        label: const Text('Asistente'),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AssistantBottomDialog(nombre: widget.nombre),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
