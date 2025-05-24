import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String _baseUrl = 'http://api.careassistant.co:8080';

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

  static Future<bool> agendarCita({
    required String profesionalId,
    required String fecha,
    required String hora,
    required String resumen,
    required String ubicacion,
  }) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('$_baseUrl/appointments');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'uuidProfesionalSalud': profesionalId,
        'fecha': fecha,
        'hora': hora,
        'resumen': resumen,
        'ubicacion': ubicacion,
      }),
    );

    return response.statusCode == 201;
  }

  static Future<List<dynamic>> getAppointmentsForPatient(String userId) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/appointments/$userId/patient'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener las citas del paciente');
    }
  }
}
