import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/data/secure_storage.dart';
import '../../domain/entities/sale.dart';

class SalesRepository {
  Future<List<Sale>> getSalesByBranch(int branchId) async {
    try {
      final token = await SecureStorage.readToken();
      
      if (token == null) {
        throw Exception('Token no disponible. Por favor inicia sesión nuevamente.');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/sales/branch/$branchId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final sales = jsonData
            .map((json) => Sale.fromJson(json as Map<String, dynamic>))
            .toList();
        return sales;
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido.');
      } else {
        throw Exception('Error al cargar las ventas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Sale> createSale(Map<String, dynamic> saleData) async {
    try {
      final token = await SecureStorage.readToken();
      
      if (token == null) {
        throw Exception('Token no disponible. Por favor inicia sesión nuevamente.');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/sales'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(saleData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return Sale.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido.');
      } else {
        throw Exception('Error al crear la venta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
