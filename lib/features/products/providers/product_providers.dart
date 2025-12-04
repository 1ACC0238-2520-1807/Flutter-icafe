import 'package:flutter/material.dart';
import '../data/models/product_models.dart';
import '../data/network/product_service.dart';
import '../../inventory/data/models/inventory_models.dart';
import '../../inventory/data/network/inventory_service.dart';

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
  final InventoryService? _inventoryService;
  final int productId;

  bool isLoading = false;
  String? errorMessage;
  ProductResource? product;
  bool actionSuccess = false;
  
  /// Mapa de ingredientId -> SupplyItemResource para mostrar nombre y unidad
  Map<int, SupplyItemResource> ingredientDetails = {};

  ProductDetailProvider(this._service, this.productId, [this._inventoryService]) {
    loadProductDetails();
  }

  Future<void> loadProductDetails() async {
    isLoading = true;
    notifyListeners();
    try {
      product = await _service.getProductById(productId);
      
      // Cargar detalles de cada ingrediente
      if (product != null && _inventoryService != null) {
        for (var ingredient in product!.ingredients) {
          try {
            final supplyItem = await _inventoryService.getSupplyItemById(ingredient.ingredientId);
            ingredientDetails[ingredient.ingredientId] = supplyItem;
          } catch (e) {
            // Si falla, simplemente no tendremos el detalle de ese ingrediente
            debugPrint('Error cargando ingrediente ${ingredient.ingredientId}: $e');
          }
        }
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  /// Obtiene el nombre del ingrediente por su ID
  String getIngredientName(int ingredientId) {
    return ingredientDetails[ingredientId]?.name ?? 'Ingrediente #$ingredientId';
  }
  
  /// Obtiene la unidad del ingrediente por su ID
  String getIngredientUnit(int ingredientId) {
    final unit = ingredientDetails[ingredientId]?.unit ?? '';
    return _formatUnitShort(unit);
  }
  
  String _formatUnitShort(String unit) {
    switch (unit.toUpperCase()) {
      case 'GRAMOS':
        return 'g';
      case 'KILOGRAMOS':
        return 'kg';
      case 'MILILITROS':
        return 'ml';
      case 'LITROS':
        return 'L';
      case 'UNIDADES':
        return 'uds';
      default:
        return unit.isNotEmpty ? unit.toLowerCase() : 'u';
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
        // Formatear números: si es entero mostrar sin decimales
        costPrice = product.costPrice == product.costPrice.toInt() 
            ? product.costPrice.toInt().toString() 
            : product.costPrice.toString();
        profitMargin = product.profitMargin == product.profitMargin.toInt() 
            ? product.profitMargin.toInt().toString() 
            : product.profitMargin.toString();

        selectedIngredients = product.ingredients.map((ing) {
          final supplyItem = availableSupplyItems.firstWhere(
                  (s) => s.id == ing.ingredientId,
              orElse: () => SupplyItemResource(id: ing.ingredientId, providerId: 0, branchId: 0, name: ing.name ?? "Desconocido", unit: ing.unit ?? "u", unitPrice: 0, stock: 0, buyDate: "", expiredDate: null)
          );

          return ProductIngredientFormModel(
              supplyItemId: ing.ingredientId,
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

  Future<bool> saveProduct({
    required String productName,
    required String productCostPrice,
    required String productProfitMargin,
  }) async {
    debugPrint('=== SAVE PRODUCT ===');
    debugPrint('productName: $productName');
    debugPrint('productCostPrice: $productCostPrice');
    debugPrint('productProfitMargin: $productProfitMargin');
    debugPrint('productId: $productId');
    
    final cost = double.tryParse(productCostPrice);
    final margin = double.tryParse(productProfitMargin);
    
    debugPrint('parsed cost: $cost');
    debugPrint('parsed margin: $margin');

    if (productName.isEmpty || cost == null || margin == null || selectedIngredients.isEmpty) {
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
        debugPrint('CREATING new product');
        final request = CreateProductRequest(branchId: branchId, name: productName, costPrice: cost, profitMargin: margin);
        debugPrint('CreateProductRequest: ${request.toJson()}');
        final newProduct = await _service.createProduct(request);
        savedProductId = newProduct.id;
      } else {
        debugPrint('UPDATING existing product $productId');
        final request = UpdateProductRequest(name: productName, costPrice: cost, profitMargin: margin);
        debugPrint('UpdateProductRequest: ${request.toJson()}');
        await _service.updateProduct(productId!, request);
        savedProductId = productId!;
      }

      for (var ing in selectedIngredients) {
        try {
          if (productId != null) {
            // Intentar eliminar el ingrediente primero (puede no existir)
            try { 
              debugPrint('Removing ingredient ${ing.supplyItemId} from product $savedProductId');
              await _service.removeIngredientFromProduct(savedProductId, ing.supplyItemId); 
            } catch (e) {
              debugPrint('Remove ingredient failed (may not exist): $e');
            }
          }
          debugPrint('Adding ingredient ${ing.supplyItemId} with qty ${ing.quantity} to product $savedProductId');
          await _service.addIngredientToProduct(savedProductId, AddIngredientRequest(supplyItemId: ing.supplyItemId, quantity: double.parse(ing.quantity)));
          debugPrint('Ingredient added successfully');
        } catch (e) {
          debugPrint('Error with ingredient ${ing.supplyItemId}: $e');
          // Continuar con el siguiente ingrediente
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