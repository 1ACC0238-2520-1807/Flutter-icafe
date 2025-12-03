import 'package:dio/dio.dart';
import '../../../inventory/data/models/inventory_models.dart';
import '../models/product_models.dart';

class ProductService {
  final Dio _dio;

  ProductService(this._dio);

  Future<List<ProductResource>> getProductsByBranchId(int branchId) async {
    final response = await _dio.get('/api/v1/products/branch/$branchId');
    return (response.data as List).map((x) => ProductResource.fromJson(x)).toList();
  }

  Future<ProductResource> getProductById(int productId) async {
    final response = await _dio.get('/api/v1/products/$productId');
    return ProductResource.fromJson(response.data);
  }

  Future<ProductResource> createProduct(CreateProductRequest request) async {
    final response = await _dio.post('/api/v1/products', data: request.toJson());
    return ProductResource.fromJson(response.data);
  }

  Future<ProductResource> updateProduct(int productId, UpdateProductRequest request) async {
    final response = await _dio.put('/api/v1/products/$productId', data: request.toJson());
    return ProductResource.fromJson(response.data);
  }

  Future<void> deleteProduct(int productId) async {
    await _dio.delete('/api/v1/products/$productId');
  }

  Future<void> archiveProduct(int productId) async {
    await _dio.post('/api/v1/products/$productId/archive');
  }

  Future<void> activateProduct(int productId) async {
    await _dio.post('/api/v1/products/$productId/activate');
  }

  Future<void> addIngredientToProduct(int productId, AddIngredientRequest request) async {
    await _dio.post('/api/v1/products/$productId/ingredients', data: request.toJson());
  }

  Future<void> removeIngredientFromProduct(int productId, int supplyItemId) async {
    await _dio.delete('/api/v1/products/$productId/ingredients/$supplyItemId');
  }

  Future<List<SupplyItemResource>> getAllSupplyItems() async {
    final response = await _dio.get('/api/v1/supply-items');
    return (response.data as List).map((x) => SupplyItemResource.fromJson(x)).toList();
  }
}