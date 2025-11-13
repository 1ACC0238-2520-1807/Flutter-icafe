import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:icafe_flutter/core/constants/api_constants.dart';
import '../domain/role.dart';
import 'secure_storage.dart';

class RoleService {
final Uri uri = Uri.parse(
      ApiConstants.baseUrl,
    ).replace(path: ApiConstants.roleEndpoint);
  // Roles disponibles sin autenticación (para registro)
  Future<List<Role>> getRolesForSignup() async {
    return [
      Role(id: 1, name: 'ADMIN'),
      Role(id: 2, name: 'OWNER'),
    ];
  }

  Future<List<Role>> getAllRoles() async {
    final token = await SecureStorage.readToken();
    final response = await http.get(
      uri,
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
