import 'package:flutter/material.dart';
import '../services/assistant_service.dart';
import '../services/api_service.dart';

class AssistantBottomDialog extends StatefulWidget {
  final String nombre;

  const AssistantBottomDialog({super.key, required this.nombre});

  @override
  State<AssistantBottomDialog> createState() => _AssistantBottomDialogState();
}

class _AssistantBottomDialogState extends State<AssistantBottomDialog> {
  final TextEditingController preguntaController = TextEditingController();
  final TextEditingController resumenController = TextEditingController();
  final TextEditingController ubicacionController = TextEditingController();
  String respuesta = '';
  bool loading = false;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> enviarPregunta() async {
    final pregunta = preguntaController.text.trim();
    if (pregunta.isEmpty) return;

    setState(() => loading = true);

    final respuestaLLM = await AssistantService.getRespuesta(
      pregunta,
      widget.nombre,
    );

    print(respuestaLLM);

    setState(() {
      respuesta = respuestaLLM;
      loading = false;
    });
  }

  Future<void> seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> seleccionarHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> agendarCita(String profesionalId) async {
    if (selectedDate == null ||
        selectedTime == null ||
        resumenController.text.trim().isEmpty ||
        ubicacionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa resumen, ubicación, fecha y hora.'),
        ),
      );
      return;
    }

    final fecha =
        '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
    final hora =
        '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';

    final exito = await ApiService.agendarCita(
      profesionalId: profesionalId,
      fecha: fecha,
      hora: hora,
      resumen: resumenController.text.trim(),
      ubicacion: ubicacionController.text.trim(),
    );

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            exito ? 'Cita agendada exitosamente' : 'Error al agendar la cita',
          ),
          backgroundColor: exito ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  List<Map<String, String>> _parseProfesionalesDesdeTexto(String texto) {
    final regex = RegExp(
      r'- \*\*(.*?)\*\* Especialidad: (.*?) ?\. Disponibilidad: \*\*(.*?)\*\*\. \[ID: (.*?)\]',
      dotAll: true,
    );

    return regex.allMatches(texto).map((match) {
      return {
        'nombre': match.group(1) ?? '',
        'especialidad': match.group(2) ?? '',
        'disponibilidad': match.group(3) ?? '',
        'id': match.group(4) ?? '',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder:
          (_, controller) => Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ListView(
              controller: controller,
              children: [
                TextField(
                  controller: preguntaController,
                  decoration: InputDecoration(
                    labelText: '¿Cómo podemos ayudarte?',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: enviarPregunta,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (loading)
                  const Center(child: CircularProgressIndicator())
                else if (respuesta.isNotEmpty) ...[
                  const Text(
                    'Profesionales sugeridos:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: resumenController,
                    decoration: InputDecoration(
                      labelText: 'Resumen del servicio',
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: ubicacionController,
                    decoration: InputDecoration(
                      labelText: 'Ubicación del servicio',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            selectedDate == null
                                ? 'Seleccionar fecha'
                                : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                          ),
                          onPressed: seleccionarFecha,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            selectedTime == null
                                ? 'Seleccionar hora'
                                : '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                          ),
                          onPressed: seleccionarHora,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Builder(
                    builder: (_) {
                      final lista = _parseProfesionalesDesdeTexto(respuesta);
                      if (lista.isEmpty) {
                        return const Text(
                          'No se encontraron profesionales disponibles en este momento.',
                          style: TextStyle(color: Colors.grey),
                        );
                      }

                      return Column(
                        children:
                            lista.map((prof) {
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                title: Text(
                                  prof['nombre'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '${prof['especialidad']} - Disponibilidad: ${prof['disponibilidad']}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () => agendarCita(prof['id']!),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEFE7F6),
                                    foregroundColor: const Color(0xFF6200EE),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text('Agendar'),
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
    );
  }
}
