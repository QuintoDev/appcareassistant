import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AssistantService {
  static Future<String> getRespuesta(String pregunta, String usuario) async {
    final token = await AuthService.getToken();
    final String _baseUrl = dotenv.env['AI_URL'] ?? 'http://localhost:8000';

    final response = await http.post(
      Uri.parse('$_baseUrl/conversations'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'pregunta': pregunta, 'usuario': usuario}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['respuesta'] ?? 'No se obtuvo una respuesta válida.';
    } else {
      return 'Error al comunicarse con el asistente.';
    }
  }
}
