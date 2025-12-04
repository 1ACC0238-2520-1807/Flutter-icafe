import 'package:dio/dio.dart';
import '../models/inventory_models.dart';

class InventoryService {
  final Dio _dio;

  InventoryService(this._dio);

  Future<List<SupplyItemResource>> getSupplyItemsByBranch(int branchId) async {
    final response = await _dio.get('/api/v1/product/supply-items/branch/$branchId');
    return (response.data as List).map((x) => SupplyItemResource.fromJson(x)).toList();
  }

  Future<SupplyItemResource> getSupplyItemById(int id) async {
    final response = await _dio.get('/api/v1/product/supply-items/$id');
    return SupplyItemResource.fromJson(response.data);
  }

  Future<SupplyItemResource> createSupplyItem(CreateSupplyItemRequest request) async {
    final response = await _dio.post('/api/v1/product/supply-items', data: request.toJson());
    return SupplyItemResource.fromJson(response.data);
  }

  Future<void> updateSupplyItem(int id, UpdateSupplyItemRequest request) async {
    await _dio.put('/api/v1/product/supply-items/$id', data: request.toJson());
  }

  Future<void> deleteSupplyItem(int id) async {
    await _dio.delete('/api/v1/product/supply-items/$id');
  }

  Future<void> registerMovement(CreateInventoryTransactionResource request) async {
    await _dio.post('/api/v1/inventory/movements', data: request.toJson());
  }

  Future<double> getCurrentStock(int branchId, int supplyItemId) async {
    final response = await _dio.get('/api/v1/inventory/stock/$branchId/$supplyItemId');
    return (response.data['currentStock'] as num).toDouble();
  }

  Future<List<InventoryTransactionResource>> getAllStockMovementsByBranch(int branchId) async {
    final response = await _dio.get('/api/v1/inventory/movements/$branchId');
    return (response.data as List).map((x) => InventoryTransactionResource.fromJson(x)).toList();
  }
}