import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/auth_service.dart';

Future<String> decodeUserIdFromToken() async {
  final token = await AuthService.getToken();
  if (token != null) {
    Map<String, dynamic> decoded = JwtDecoder.decode(token);
    return decoded['sub'];
  } else {
    throw Exception('Token no disponible');
  }
}
