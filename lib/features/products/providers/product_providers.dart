import 'package:flutter/material.dart';
import '../data/models/product_models.dart';
import '../data/network/product_service.dart';
import '../../inventory/data/models/inventory_models.dart';

class ProductListProvider extends ChangeNotifier {
  final ProductService _service;
  final String selectedSedeId;

  bool isLoading = false;
  String? errorMessage;
  List<ProductResource> products = [];

  ProductListProvider(this._service, this.selectedSedeId) {
    loadProducts();
  }

  int get branchId => int.tryParse(selectedSedeId) ?? 1;

  Future<void> loadProducts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      products = await _service.getProductsByBranchId(branchId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class ProductDetailProvider extends ChangeNotifier {
  final ProductService _service;
  final int productId;

  bool isLoading = false;
  String? errorMessage;
  ProductResource? product;
  bool actionSuccess = false;

  ProductDetailProvider(this._service, this.productId) {
    loadProductDetails();
  }

  Future<void> loadProductDetails() async {
    isLoading = true;
    notifyListeners();
    try {
      product = await _service.getProductById(productId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleArchiveStatus() async {
    if (product == null) return;
    isLoading = true;
    notifyListeners();
    try {
      if (product!.status == ProductStatus.ACTIVE) {
        await _service.archiveProduct(productId);
      } else {
        await _service.activateProduct(productId);
      }
      await loadProductDetails();
      actionSuccess = true;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct() async {
    isLoading = true;
    notifyListeners();
    try {
      await _service.deleteProduct(productId);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

class ProductFormProvider extends ChangeNotifier {
  final ProductService _service;
  final String selectedSedeId;
  final int? productId;

  bool isLoading = false;
  String? errorMessage;

  String name = "";
  String costPrice = "";
  String profitMargin = "";

  List<SupplyItemResource> availableSupplyItems = [];
  List<ProductIngredientFormModel> selectedIngredients = [];

  ProductFormProvider(this._service, this.selectedSedeId, this.productId) {
    _init();
  }

  int get branchId => int.tryParse(selectedSedeId) ?? 1;

  void _init() async {
    isLoading = true;
    notifyListeners();
    try {

      final allItems = await _service.getAllSupplyItems();
      availableSupplyItems = allItems.where((i) => i.branchId == branchId).toList();

      if (productId != null) {
        final product = await _service.getProductById(productId!);
        name = product.name;
        costPrice = product.costPrice.toString();
        profitMargin = product.profitMargin.toString();

        selectedIngredients = product.ingredients.map((ing) {
          final supplyItem = availableSupplyItems.firstWhere(
                  (s) => s.id == ing.supplyItemId,
              orElse: () => SupplyItemResource(id: ing.supplyItemId, providerId: 0, branchId: 0, name: ing.name ?? "Desconocido", unit: ing.unit ?? "u", unitPrice: 0, stock: 0, buyDate: "", expiredDate: null)
          );

          return ProductIngredientFormModel(
              supplyItemId: ing.supplyItemId,
              name: supplyItem.name,
              unit: supplyItem.unit,
              quantity: ing.quantity.toString()
          );
        }).toList();
      }
    } catch (e) {
      errorMessage = "Error inicializando formulario: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void addOrUpdateIngredient(SupplyItemResource item, String qty) {
    final index = selectedIngredients.indexWhere((i) => i.supplyItemId == item.id);
    final newIng = ProductIngredientFormModel(
        supplyItemId: item.id,
        name: item.name,
        unit: item.unit,
        quantity: qty
    );

    if (index >= 0) {
      selectedIngredients[index] = newIng;
    } else {
      selectedIngredients.add(newIng);
    }
    notifyListeners();
  }

  void removeIngredient(int supplyItemId) {
    selectedIngredients.removeWhere((i) => i.supplyItemId == supplyItemId);
    notifyListeners();
  }

  Future<bool> saveProduct() async {
    final cost = double.tryParse(costPrice);
    final margin = double.tryParse(profitMargin);

    if (name.isEmpty || cost == null || margin == null || selectedIngredients.isEmpty) {
      errorMessage = "Completa todos los campos y añade al menos un ingrediente.";
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      int savedProductId;

      // 1. Guardar o Actualizar el Producto base
      if (productId == null) {
        final request = CreateProductRequest(branchId: branchId, name: name, costPrice: cost, profitMargin: margin);
        final newProduct = await _service.createProduct(request);
        savedProductId = newProduct.id;
      } else {
        final request = UpdateProductRequest(name: name, costPrice: cost, profitMargin: margin);
        await _service.updateProduct(productId!, request);
        savedProductId = productId!;
      }

      for (var ing in selectedIngredients) {
        try {
          if (productId != null) {
            try { await _service.removeIngredientFromProduct(savedProductId, ing.supplyItemId); } catch (_) {}
          }
          await _service.addIngredientToProduct(savedProductId, AddIngredientRequest(supplyItemId: ing.supplyItemId, quantity: double.parse(ing.quantity)));
        } catch (e) {
          // Ignorar o loguear
        }
      }

      return true;
    } catch (e) {
      errorMessage = "Error guardando producto: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class ProductIngredientFormModel {
  final int supplyItemId;
  final String name;
  final String unit;
  final String quantity;

  ProductIngredientFormModel({required this.supplyItemId, required this.name, required this.unit, required this.quantity});
}