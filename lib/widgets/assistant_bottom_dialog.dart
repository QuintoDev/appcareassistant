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
  String respuesta = '';
  bool loading = false;

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

  Future<void> agendarCita(String profesionalId) async {
    final exito = await ApiService.agendarCita(
      profesionalId: profesionalId,
      fecha: '2025-05-11',
      hora: '10:30',
      resumen: 'Atención solicitada a través del asistente',
      ubicacion: 'Casa',
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
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  List<Map<String, String>> _parseProfesionalesDesdeTexto(String texto) {
    final regex = RegExp(
      r'- \*\*(.*?)\*\* Especialidad: (.*?)\. Ciudad: (.*?)\. Disponibilidad: \*\*(.*?)\*\*\. \[ID: (.*?)\]',
      dotAll: true,
    );

    return regex.allMatches(texto).map((match) {
      return {
        'nombre': match.group(1) ?? '',
        'especialidad': match.group(2) ?? '',
        'ciudad': match.group(3) ?? '',
        'disponibilidad': match.group(4) ?? '',
        'id': match.group(5) ?? '',
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
                                title: Text(prof['nombre'] ?? ''),
                                subtitle: Text(
                                  '${prof['especialidad']} en ${prof['ciudad']} - Disponibilidad: ${prof['disponibilidad']}',
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () => agendarCita(prof['id']!),
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
