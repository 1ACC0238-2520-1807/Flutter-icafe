import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:icafe_flutter/core/constants/api_constants.dart';
import '../domain/authenticated_user.dart';

class AuthService {
final Uri uri = Uri.parse(
      ApiConstants.baseUrl,
    ).replace(path: ApiConstants.authEndpoint);
  Future<AuthenticatedUser> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('$uri/sign-in'),
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
      Uri.parse('$uri/sign-up'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'roles': roles}),
    );

    if (response.statusCode != 201) {
      throw Exception('Registro fallido');
    }
  }
}

