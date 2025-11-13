import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:icafe_flutter/core/constants/api_constants.dart';
import '../domain/user.dart';
import 'secure_storage.dart';

class UserService {
final Uri uri = Uri.parse(
      ApiConstants.baseUrl,
    ).replace(path: ApiConstants.userEndpoint);
  Future<List<User>> getAllUsers() async {
    final token = await SecureStorage.readToken();

    final response = await http.get(
      uri,
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
      Uri.parse('$uri/email/$email'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Usuario no encontrado');
    }
  }
}
