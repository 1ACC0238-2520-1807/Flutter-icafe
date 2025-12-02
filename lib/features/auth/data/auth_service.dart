import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:icafe_flutter/core/constants/api_constants.dart';
import '../domain/authenticated_user.dart';

class AuthService {
  Future<AuthenticatedUser> signIn(String email, String password) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authEndpoint}/sign-in');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return AuthenticatedUser.fromJson(jsonDecode(response.body));
      } else {
        final errorMessage = response.body.isNotEmpty 
            ? jsonDecode(response.body).toString() 
            : 'Error ${response.statusCode}';
        throw Exception('Login fallido: $errorMessage');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  Future<void> signUp(String email, String password, List<String> roles) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authEndpoint}/sign-up');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'roles': roles}),
      );

      if (response.statusCode == 201) {
        return;
      } else {
        String errorMessage = 'Error ${response.statusCode}';
        try {
          if (response.body.isNotEmpty) {
            final errorBody = jsonDecode(response.body);
            errorMessage = errorBody['message'] ?? errorBody.toString();
          }
        } catch (_) {
          errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
        }
        throw Exception('Registro fallido: $errorMessage');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}

