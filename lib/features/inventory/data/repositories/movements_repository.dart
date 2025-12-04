import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../auth/data/secure_storage.dart';
import '../../domain/entities/stock_movement.dart';
import '../models/inventory_models.dart';

class MovementsRepository {
  Future<List<StockMovement>> getMovementsByBranch(int branchId) async {
    final token = await SecureStorage.readToken();
    
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/v1/inventory/movements/$branchId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => StockMovement.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar movimientos: ${response.statusCode}');
    }
  }

  Future<SupplyItemResource?> getSupplyItemById(int id) async {
    final token = await SecureStorage.readToken();
    
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/v1/supply-items/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SupplyItemResource.fromJson(data);
    }
    return null;
  }

  Future<Map<int, SupplyItemResource>> getSupplyItemsForMovements(List<StockMovement> movements) async {
    final Map<int, SupplyItemResource> supplyItems = {};
    final uniqueIds = movements.map((m) => m.supplyItemId).toSet();
    
    for (final id in uniqueIds) {
      final item = await getSupplyItemById(id);
      if (item != null) {
        supplyItems[id] = item;
      }
    }
    
    return supplyItems;
  }
}
