import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/decode_user_id.dart';

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
      appBar: AppBar(
        title: const Text('Mis citas asignadas'),
        backgroundColor: const Color(0xFF00AEBE),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: citas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          }

          final citasList = snapshot.data!;

          if (citasList.isEmpty) {
            return const Center(child: Text('No tienes citas asignadas.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: citasList.length,
            itemBuilder: (context, index) {
              final cita = citasList[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.person, color: Color(0xFF00AEBE)),
                          SizedBox(width: 8),
                          Text(
                            'Información del paciente',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Nombre: ${cita['paciente']['nombre']} ${cita['paciente']['apellido']}",
                      ),
                      Text("Edad: ${cita['paciente']['edad']}"),
                      Text("Celular: ${cita['paciente']['celular']}"),
                      Text("Parentesco: ${cita['paciente']['parentesco']}"),
                      Text("Servicio: ${cita['resumen']}"),
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
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => confirmarCita(cita['id']),
                            child: const Text('Aceptar'),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () => rechazarCita(cita['id']),
                            child: const Text(
                              'Rechazar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
