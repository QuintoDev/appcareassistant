import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String _baseUrl = 'http://api.careassistant.co:8081';

  static Future<dynamic> getUserById(String userId) async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener usuario: ${response.body}');
    }
  }

  static Future<List<dynamic>> getAppointmentsForProfessional(
    String userId,
  ) async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/appointments/$userId/professional'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Error al obtener citas del profesional');
    }
  }

  static Future<bool> updateAppointmentStatus(String id, bool confirmar) async {
    final endpoint = confirmar ? 'confirm' : 'cancel';
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/appointments/$id/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }
}
