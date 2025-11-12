import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/secure_storage.dart';

class UserService {
  static const baseUrl = 'http://<10.0.2.2>:8080/api/v1/users';

  Future<List<User>> getAllUsers() async {
    final token = await SecureStorage.readToken();

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((u) => User.fromJson(u)).toList();
    } else {
      throw Exception('Error al obtener usuarios');
    }
  }

  Future<User> getUserByEmail(String email) async {
    final token = await SecureStorage.readToken();

    final response = await http.get(
      Uri.parse('$baseUrl/email/$email'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Usuario no encontrado');
    }
  }
}
