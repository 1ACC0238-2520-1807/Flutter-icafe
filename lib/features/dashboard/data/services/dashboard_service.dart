import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../features/auth/data/secure_storage.dart';

class DashboardService {
  Future<Map<String, dynamic>> getDashboardData({
    required int branchId,
    required String portfolioId,
  }) async {
    try {
      final token = await SecureStorage.readToken();
      if (token == null) {
        throw Exception('Token no disponible. Por favor inicia sesión nuevamente.');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Hacer todas las llamadas en paralelo
      final results = await Future.wait([
        // 1. Obtener nombre de la sede
        http.get(
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.branchEndpoint}/$branchId'),
          headers: headers,
        ),
        // 2. Obtener empleados
        http.get(
          Uri.parse('${ApiConstants.baseUrl}/api/v1/contact-portfolios/$portfolioId/employees'),
          headers: headers,
        ),
        // 3. Obtener proveedores
        http.get(
          Uri.parse('${ApiConstants.baseUrl}/api/v1/contact-portfolios/$portfolioId/providers'),
          headers: headers,
        ),
        // 4. Obtener insumos de la sede
        http.get(
          Uri.parse('${ApiConstants.baseUrl}/api/v1/supply-items/$branchId/branch'),
          headers: headers,
        ),
        // 5. Obtener productos de la sede
        http.get(
          Uri.parse('${ApiConstants.baseUrl}/api/v1/products/branch/$branchId'),
          headers: headers,
        ),
        // 6. Obtener ventas de la sede
        http.get(
          Uri.parse('${ApiConstants.baseUrl}/api/v1/sales/branch/$branchId'),
          headers: headers,
        ),
        // 7. Obtener órdenes de compra de la sede
        http.get(
          Uri.parse('${ApiConstants.baseUrl}/api/v1/purchase-orders/branch/$branchId'),
          headers: headers,
        ),
      ]);

      // Procesar resultados
      final branchResponse = results[0];
      final employeesResponse = results[1];
      final providersResponse = results[2];
      final supplyItemsResponse = results[3];
      final productsResponse = results[4];
      final salesResponse = results[5];
      final purchaseOrdersResponse = results[6];

      // Validar respuesta de rama
      if (branchResponse.statusCode != 200) {
        throw Exception('Error al obtener información de la sede');
      }

      final branchData = jsonDecode(branchResponse.body);
      final sedeName = branchData['name'] ?? 'Sede';

      // Procesar empleados
      final totalEmployees = employeesResponse.statusCode == 200
          ? (jsonDecode(employeesResponse.body) as List).length
          : 0;

      // Procesar proveedores
      final totalProviders = providersResponse.statusCode == 200
          ? (jsonDecode(providersResponse.body) as List).length
          : 0;

      // Procesar insumos
      final totalSupplyItems = supplyItemsResponse.statusCode == 200
          ? (jsonDecode(supplyItemsResponse.body) as List).length
          : 0;

      // Procesar productos
      final totalProducts = productsResponse.statusCode == 200
          ? (jsonDecode(productsResponse.body) as List).length
          : 0;

      // Procesar ventas
      double totalSalesAmount = 0.0;
      int totalSalesCount = 0;
      double averageSaleAmount = 0.0;

      if (salesResponse.statusCode == 200) {
        final salesList = jsonDecode(salesResponse.body) as List;
        totalSalesCount = salesList.length;
        for (var sale in salesList) {
          totalSalesAmount += (sale['totalAmount'] as num?)?.toDouble() ?? 0.0;
        }
        averageSaleAmount =
            totalSalesCount > 0 ? totalSalesAmount / totalSalesCount : 0.0;
      }

      // Procesar órdenes de compra
      double totalPurchasesAmount = 0.0;
      if (purchaseOrdersResponse.statusCode == 200) {
        final purchaseOrdersList = jsonDecode(purchaseOrdersResponse.body) as List;
        for (var order in purchaseOrdersList) {
          totalPurchasesAmount += (order['totalAmount'] as num?)?.toDouble() ?? 0.0;
        }
      }

      return {
        'sedeName': sedeName,
        'totalEmployees': totalEmployees,
        'totalProviders': totalProviders,
        'totalSupplyItems': totalSupplyItems,
        'totalProducts': totalProducts,
        'totalSalesAmount': totalSalesAmount,
        'totalSalesCount': totalSalesCount,
        'averageSaleAmount': averageSaleAmount,
        'totalPurchasesAmount': totalPurchasesAmount,
      };
    } catch (e) {
      throw Exception('Error al cargar datos del dashboard: ${e.toString()}');
    }
  }
}
