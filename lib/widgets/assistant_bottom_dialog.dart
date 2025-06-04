import 'package:flutter/material.dart';
import '../services/assistant_service.dart';
import '../services/api_service.dart';

class AssistantBottomDialog extends StatefulWidget {
  final String nombre;
  final VoidCallback onAppointmentCreated;

  const AssistantBottomDialog({
    super.key,
    required this.nombre,
    required this.onAppointmentCreated,
  });

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
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> seleccionarHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) setState(() => selectedTime = picked);
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
      widget.onAppointmentCreated();
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
      r'- \*\*(.*?)\*\* Especialidad: (.*?)\. Ciudad: (.*?)\. Disponibilidad: \*\*(.*?)\*\*\. \[ID:\s*(.*?)\](?:\.?\s*(.*?))?(?=(?:- \*\*|$))',
      dotAll: true,
    );

    final matches = regex.allMatches(texto);

    return matches.map((match) {
      return {
        'nombre': match.group(1)?.trim() ?? '',
        'especialidad': match.group(2)?.trim() ?? '',
        'ciudad': match.group(3)?.trim() ?? '',
        'disponibilidad': match.group(4)?.trim() ?? '',
        'id': match.group(5)?.trim() ?? '',
        'presentacion': match.group(6)?.trim() ?? '',
      };
    }).toList();
  }

@override
Widget build(BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
    ),
    child: DraggableScrollableSheet(
      expand: false,
      builder: (_, controller) => SingleChildScrollView(
        controller: controller,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: preguntaController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00AEBE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00AEBE),
                      width: 2,
                    ),
                  ),
                  labelText: '¿Cómo podemos ayudarte?',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    color: Color(0xFF00AEBE),
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
                    prefixIcon: const Icon(
                      Icons.description_outlined,
                      color: Color(0xFF00AEBE),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00AEBE)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF00AEBE),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ubicacionController,
                  decoration: InputDecoration(
                    labelText: 'Ubicación del servicio',
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF00AEBE),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00AEBE)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF00AEBE),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF00AEBE),
                        ),
                        label: Text(
                          selectedDate == null
                              ? 'Seleccionar fecha'
                              : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                          style: const TextStyle(color: Color(0xFF00AEBE)),
                        ),
                        onPressed: seleccionarFecha,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.access_time,
                          color: Color(0xFF00AEBE),
                        ),
                        label: Text(
                          selectedTime == null
                              ? 'Seleccionar hora'
                              : '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Color(0xFF00AEBE)),
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
                      children: lista.map((prof) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          title: Text(
                            prof['nombre'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${prof['especialidad']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF00AEBE),
                                ),
                                tooltip: 'Saber más',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: Text(
                                        '👩‍⚕️ ${prof['nombre']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      content: SingleChildScrollView(
                                        child: RichText(
                                          text: TextSpan(
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  height: 1.5,
                                                  color: Colors.black87,
                                                ),
                                            children: [
                                              const TextSpan(
                                                text: '🩺 Especialidad: ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                  text:
                                                      '${prof['especialidad']}\n'),
                                              const TextSpan(
                                                text: '📍 Ciudad: ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                  text: '${prof['ciudad']}\n'),
                                              const TextSpan(
                                                text: '📆 Disponibilidad: ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                  text:
                                                      '${prof['disponibilidad']}\n\n'),
                                              const TextSpan(
                                                text: '🧑‍💼 Sobre mí:\n',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: prof['presentacion'] ??
                                                    'Este profesional aún no ha añadido una presentación.',
                                                style: const TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cerrar'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Tooltip(
                                message:
                                    'Agendar cita con ${prof['nombre']}',
                                child: ElevatedButton(
                                  onPressed: () =>
                                      agendarCita(prof['id'] ?? ''),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF00AEBE),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: const Text('Agendar'),
                                ),
                              ),
                            ],
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
      ),
    ),
  );
}
}
