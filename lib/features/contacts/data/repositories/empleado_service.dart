import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:icafe_flutter/core/constants/api_constants.dart';
import '../../domain/entities/empleado.dart';
import '../../../auth/data/secure_storage.dart';

class EmpleadoService {
  Future<List<Empleado>> getAllEmpleados(int portfolioId) async {
    try {
      final token = await SecureStorage.readToken();
      
      if (token == null) {
        throw Exception('Token no disponible. Por favor inicia sesión nuevamente.');
      }

      final url = '${ApiConstants.baseUrl}${ApiConstants.contactPortfolioEndpoint}/$portfolioId/employees';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => Empleado.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido.');
      } else {
        throw Exception('Error al obtener empleados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<Empleado> getEmpleadoById(String id, int portfolioId) async {
    try {
      final token = await SecureStorage.readToken();
      
      if (token == null) {
        throw Exception('Token no disponible. Por favor inicia sesión nuevamente.');
      }

      final url = '${ApiConstants.baseUrl}${ApiConstants.contactPortfolioEndpoint}/$portfolioId/employees/$id';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Empleado.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Empleado no encontrado');
      } else {
        throw Exception('Error al obtener empleado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<Empleado> createEmpleado(Empleado empleado, int portfolioId) async {
    try {
      final token = await SecureStorage.readToken();
      
      if (token == null) {
        throw Exception('Token no disponible. Por favor inicia sesión nuevamente.');
      }

      final url = '${ApiConstants.baseUrl}${ApiConstants.contactPortfolioEndpoint}/$portfolioId/employees';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(empleado.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Empleado.fromJson(jsonDecode(response.body));
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
        throw Exception('Error al crear empleado: $errorMessage');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<Empleado> updateEmpleado(Empleado empleado, int portfolioId) async {
    try {
      final token = await SecureStorage.readToken();
      
      if (token == null) {
        throw Exception('Token no disponible. Por favor inicia sesión nuevamente.');
      }

      final url = '${ApiConstants.baseUrl}${ApiConstants.contactPortfolioEndpoint}/$portfolioId/employees/${empleado.id}';
      
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(empleado.toJson()),
      );

      if (response.statusCode == 200) {
        return Empleado.fromJson(jsonDecode(response.body));
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
        throw Exception('Error al actualizar empleado: $errorMessage');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<void> deleteEmpleado(String id, int portfolioId) async {
    try {
      final token = await SecureStorage.readToken();
      
      if (token == null) {
        throw Exception('Token no disponible. Por favor inicia sesión nuevamente.');
      }

      final url = '${ApiConstants.baseUrl}${ApiConstants.contactPortfolioEndpoint}/$portfolioId/employees/$id';
      
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar empleado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}

