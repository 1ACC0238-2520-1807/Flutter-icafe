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

      // 1. Obtener nombre de la sede
      final branchUrl = '${ApiConstants.baseUrl}${ApiConstants.branchEndpoint}/$branchId';
      final branchResponse = await http.get(Uri.parse(branchUrl), headers: headers);

      if (branchResponse.statusCode != 200) {
        throw Exception('Error al obtener información de la sede');
      }

      final branchData = jsonDecode(branchResponse.body);
      final sedeName = branchData['name'] ?? 'Sede';

      // 2. Obtener empleados
      final employeesUrl =
          '${ApiConstants.baseUrl}/api/v1/contact-portfolios/$portfolioId/employees';
      final employeesResponse = await http.get(Uri.parse(employeesUrl), headers: headers);
      final totalEmployees = employeesResponse.statusCode == 200
          ? (jsonDecode(employeesResponse.body) as List).length
          : 0;

      // 3. Obtener proveedores
      final providersUrl =
          '${ApiConstants.baseUrl}/api/v1/contact-portfolios/$portfolioId/providers';
      final providersResponse = await http.get(Uri.parse(providersUrl), headers: headers);
      final totalProviders = providersResponse.statusCode == 200
          ? (jsonDecode(providersResponse.body) as List).length
          : 0;

      // 4. Obtener insumos de la sede
      final supplyItemsUrl =
          '${ApiConstants.baseUrl}/api/v1/supply-items/$branchId/branch';
      final supplyItemsResponse = await http.get(Uri.parse(supplyItemsUrl), headers: headers);
      final totalSupplyItems = supplyItemsResponse.statusCode == 200
          ? (jsonDecode(supplyItemsResponse.body) as List).length
          : 0;

      // 5. Obtener productos de la sede
      final productsUrl = '${ApiConstants.baseUrl}/api/v1/products/branch/$branchId';
      final productsResponse = await http.get(Uri.parse(productsUrl), headers: headers);
      final totalProducts = productsResponse.statusCode == 200
          ? (jsonDecode(productsResponse.body) as List).length
          : 0;

      // 6. Obtener ventas de la sede
      final salesUrl = '${ApiConstants.baseUrl}/api/v1/sales/branch/$branchId';
      final salesResponse = await http.get(Uri.parse(salesUrl), headers: headers);

      double totalSalesAmount = 0.0;
      int totalSalesCount = 0;
      double averageSaleAmount = 0.0;

      if (salesResponse.statusCode == 200) {
        final salesList = jsonDecode(salesResponse.body) as List;
        totalSalesCount = salesList.length;
        totalSalesAmount = 0.0;
        for (var sale in salesList) {
          totalSalesAmount += (sale['totalAmount'] as num?)?.toDouble() ?? 0.0;
        }
        averageSaleAmount =
            totalSalesCount > 0 ? totalSalesAmount / totalSalesCount : 0.0;
      }

      // 7. Obtener órdenes de compra de la sede
      final purchaseOrdersUrl =
          '${ApiConstants.baseUrl}/api/v1/purchase-orders/branch/$branchId';
      final purchaseOrdersResponse =
          await http.get(Uri.parse(purchaseOrdersUrl), headers: headers);

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
