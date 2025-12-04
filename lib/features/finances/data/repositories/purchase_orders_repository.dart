import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/data/secure_storage.dart';
import '../../domain/entities/purchase_order.dart';

class PurchaseOrdersRepository {
  Future<List<PurchaseOrder>> getPurchaseOrdersByBranch(int branchId) async {
    try {
      final token = await SecureStorage.readToken();
      
      if (token == null) {
        throw Exception('Token no disponible. Por favor inicia sesión nuevamente.');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/purchase-orders/branch/$branchId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final orders = jsonData
            .map((json) => PurchaseOrder.fromJson(json as Map<String, dynamic>))
            .toList();
        return orders;
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido.');
      } else {
        throw Exception('Error al cargar órdenes de compra: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
