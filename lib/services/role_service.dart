import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/role.dart';
import '../utils/secure_storage.dart';

class RoleService {
  static const baseUrl = 'http://<TU-IP>:8080/ap/v1/roles';

  Future<List<Role>> getAllRoles() async {
    final token = await SecureStorage.readToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((r) => Role.fromJson(r)).toList();
    } else {
      throw Exception('Error al obtener roles');
    }
  }
}
