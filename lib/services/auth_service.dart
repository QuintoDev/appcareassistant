import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static final String _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8080';

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'correo': email, 'contraseña': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        return true;
      } else {
        return false;
      }
    } on Exception {
      return false;
    }
  }

  static Future<bool> register({
    required String nombre,
    required String apellido,
    required String correo,
    required String contrasena,
    required String ciudad,
    required String rol,
    String? celular,
    String? edad,
    String? parentesco,
    String? especialidad,
    List<String>? disponibilidad,
    String? presentacion,
  }) async {
    final Map<String, dynamic> body = {
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'contraseña': contrasena,
      'ciudad': ciudad,
      'tipo': rol,
    };

    if (rol == 'PACIENTE') {
      body['celular'] = celular;
      body['edad'] = edad;
      body['parentesco'] = parentesco;
    } else if (rol == 'PROFESIONAL_SALUD') {
      body['especialidad'] = especialidad;
      body['disponibilidad'] = disponibilidad;
      body['presentacion'] = presentacion;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}
