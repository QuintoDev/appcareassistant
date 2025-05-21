import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AssistantService {
  static Future<String> getRespuesta(String pregunta, String usuario) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('http://ia.careassistant.co:8000/conversations');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'pregunta': pregunta, 'usuario': usuario}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['respuesta'] ?? 'No se obtuvo una respuesta válida.';
    } else {
      return 'Error al comunicarse con el asistente.';
    }
  }
}
