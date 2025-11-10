import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/authenticated_user.dart';

class AuthService {
  static const baseUrl = 'http://<TU-IP>:8080/api/v1/authentication';

  Future<AuthenticatedUser> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sign-in'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return AuthenticatedUser.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Login fallido');
    }
  }

  Future<void> signUp(String email, String password, List<String> roles) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sign-up'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'roles': roles}),
    );

    if (response.statusCode != 201) {
      throw Exception('Registro fallido');
    }
  }
}

