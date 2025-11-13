import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/branch.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../features/auth/data/secure_storage.dart';

class BranchService {
  Future<List<Branch>> getBranchesByOwnerId(String ownerId) async {
    try {
      final token = await SecureStorage.readToken();
      
      if (token == null) {
        throw Exception('Token no disponible. Por favor inicia sesión nuevamente.');
      }

      final url = '${ApiConstants.baseUrl}${ApiConstants.branchEndpoint}/owner/$ownerId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => Branch.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido.');
      } else if (response.statusCode == 403) {
        throw Exception('Acceso denegado.');
      } else if (response.statusCode == 404) {
        throw Exception('No hay sedes registradas.');
      } else {
        final errorBody = response.body.isNotEmpty ? response.body : 'Error desconocido';
        throw Exception('Error al obtener sedes: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<Branch> getBranchById(int id) async {
    final token = await SecureStorage.readToken();
    
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.branchEndpoint}/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Branch.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener sede');
    }
  }

  Future<Branch> createBranch({
    required String name,
    required String location,
    required String ownerId,
    String? description,
  }) async {
    final token = await SecureStorage.readToken();
    
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.branchEndpoint}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'location': location,
        'description': description,
        'ownerId': ownerId,
      }),
    );

    if (response.statusCode == 201) {
      return Branch.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear sede');
    }
  }

  Future<void> deleteBranch(int id) async {
    final token = await SecureStorage.readToken();
    
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.branchEndpoint}/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar sede');
    }
  }

  Future<Branch> updateBranch({
    required int id,
    required String name,
    required String address,
  }) async {
    final token = await SecureStorage.readToken();
    
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.branchEndpoint}/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'address': address,
      }),
    );

    if (response.statusCode == 200) {
      return Branch.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar sede');
    }
  }
}
