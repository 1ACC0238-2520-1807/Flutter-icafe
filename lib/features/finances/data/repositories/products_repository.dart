import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/data/secure_storage.dart';
import '../../domain/entities/product.dart';

class ProductsRepository {
  Future<List<Product>> getProducts() async {
    try {
      final token = await SecureStorage.readToken();
      
      if (token == null) {
        throw Exception('Token no disponible. Por favor inicia sesión nuevamente.');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/products'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final products = jsonData
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
        return products;
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido.');
      } else {
        throw Exception('Error al cargar productos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
