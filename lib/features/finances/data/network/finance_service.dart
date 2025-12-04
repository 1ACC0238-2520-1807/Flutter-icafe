import 'package:dio/dio.dart';
import '../models/finance_models.dart';

class FinanceService {
  final Dio _dio;

  FinanceService(this._dio);

  // ==========================================
  //               PURCHASE ORDERS
  // ==========================================

  Future<PurchaseOrderResource> createPurchaseOrder(CreatePurchaseOrderRequest request) async {
    final response = await _dio.post('/api/v1/purchase-orders', data: request.toJson());
    return PurchaseOrderResource.fromJson(response.data);
  }

  Future<List<PurchaseOrderResource>> getPurchaseOrdersByBranchId(int branchId) async {
    final response = await _dio.get('/api/v1/purchase-orders/branch/$branchId');
    return (response.data as List).map((x) => PurchaseOrderResource.fromJson(x)).toList();
  }

  Future<PurchaseOrderResource> getPurchaseOrderById(int purchaseOrderId, int branchId) async {
    final response = await _dio.get('/api/v1/purchase-orders/$purchaseOrderId/branch/$branchId');
    return PurchaseOrderResource.fromJson(response.data);
  }

  Future<PurchaseOrderResource> confirmPurchaseOrder(int purchaseOrderId, int branchId) async {
    final response = await _dio.put('/api/v1/purchase-orders/$purchaseOrderId/branch/$branchId/confirm');
    return PurchaseOrderResource.fromJson(response.data);
  }

  Future<PurchaseOrderResource> completePurchaseOrder(int purchaseOrderId, int branchId) async {
    final response = await _dio.put('/api/v1/purchase-orders/$purchaseOrderId/branch/$branchId/complete');
    return PurchaseOrderResource.fromJson(response.data);
  }

  Future<PurchaseOrderResource> cancelPurchaseOrder(int purchaseOrderId, int branchId) async {
    final response = await _dio.put('/api/v1/purchase-orders/$purchaseOrderId/branch/$branchId/cancel');
    return PurchaseOrderResource.fromJson(response.data);
  }

  // ==========================================
  //                  SALES
  // ==========================================

  Future<SaleResource> createSale(CreateSaleRequest request) async {
    final response = await _dio.post('/api/v1/sales', data: request.toJson());
    return SaleResource.fromJson(response.data);
  }

  Future<List<SaleResource>> getSalesByBranchId(int branchId) async {
    final response = await _dio.get('/api/v1/sales/branch/$branchId');
    return (response.data as List).map((x) => SaleResource.fromJson(x)).toList();
  }

  Future<SaleResource> getSaleById(int saleId) async {
    final response = await _dio.get('/api/v1/sales/$saleId');
    return SaleResource.fromJson(response.data);
  }

  Future<SaleResource> completeSale(int saleId) async {
    final response = await _dio.put('/api/v1/sales/$saleId/complete');
    return SaleResource.fromJson(response.data);
  }

  Future<SaleResource> cancelSale(int saleId) async {
    final response = await _dio.put('/api/v1/sales/$saleId/cancel');
    return SaleResource.fromJson(response.data);
  }

  Future<List<SaleResource>> getAllSales() async {
    final response = await _dio.get('/api/v1/sales');
    return (response.data as List).map((x) => SaleResource.fromJson(x)).toList();
  }
}