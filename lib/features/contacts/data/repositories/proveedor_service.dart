import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:icafe_flutter/core/constants/api_constants.dart';
import '../../domain/entities/proveedor.dart';
import '../../../auth/data/secure_storage.dart';

class ProveedorService {
  Future<List<Proveedor>> getAllProveedores(int portfolioId) async {
    try {
      final token = await SecureStorage.readToken();
      
      if (token == null) {
        throw Exception('Token no disponible. Por favor inicia sesión nuevamente.');
      }

      final url = '${ApiConstants.baseUrl}${ApiConstants.contactPortfolioEndpoint}/$portfolioId/providers';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => Proveedor.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido.');
      } else {
        throw Exception('Error al obtener proveedores: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<Proveedor> getProveedorById(String id, int portfolioId) async {
    try {
      final token = await SecureStorage.readToken();
      
      if (token == null) {
        throw Exception('Token no disponible. Por favor inicia sesión nuevamente.');
      }

      final url = '${ApiConstants.baseUrl}${ApiConstants.contactPortfolioEndpoint}/$portfolioId/providers/$id';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Proveedor.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Proveedor no encontrado');
      } else {
        throw Exception('Error al obtener proveedor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<Proveedor> createProveedor(Proveedor proveedor, int portfolioId) async {
    try {
      final token = await SecureStorage.readToken();
      
      if (token == null) {
        throw Exception('Token no disponible. Por favor inicia sesión nuevamente.');
      }

      final url = '${ApiConstants.baseUrl}${ApiConstants.contactPortfolioEndpoint}/$portfolioId/providers';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(proveedor.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Proveedor.fromJson(jsonDecode(response.body));
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
        throw Exception('Error al crear proveedor: $errorMessage');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<Proveedor> updateProveedor(Proveedor proveedor, int portfolioId) async {
    try {
      final token = await SecureStorage.readToken();
      
      if (token == null) {
        throw Exception('Token no disponible. Por favor inicia sesión nuevamente.');
      }

      final url = '${ApiConstants.baseUrl}${ApiConstants.contactPortfolioEndpoint}/$portfolioId/providers/${proveedor.id}';
      
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(proveedor.toJson()),
      );

      if (response.statusCode == 200) {
        return Proveedor.fromJson(jsonDecode(response.body));
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
        throw Exception('Error al actualizar proveedor: $errorMessage');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<void> deleteProveedor(String id, int portfolioId) async {
    try {
      final token = await SecureStorage.readToken();
      
      if (token == null) {
        throw Exception('Token no disponible. Por favor inicia sesión nuevamente.');
      }

      final url = '${ApiConstants.baseUrl}${ApiConstants.contactPortfolioEndpoint}/$portfolioId/providers/$id';
      
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar proveedor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}

