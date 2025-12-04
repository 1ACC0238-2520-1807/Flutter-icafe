import 'package:flutter/material.dart';
import '../data/models/finance_models.dart';
import '../data/network/finance_service.dart';
import '../../products/data/models/product_models.dart';
import '../../products/data/network/product_service.dart';
import '../../inventory/data/models/inventory_models.dart';
import '../../inventory/data/network/inventory_service.dart';

class SalesListProvider extends ChangeNotifier {
  final FinanceService _service;
  final String selectedSedeId;

  bool isLoading = false;
  String? errorMessage;
  List<SaleResource> sales = [];

  SalesListProvider(this._service, this.selectedSedeId) {
    loadSales();
  }

  int get branchId => int.tryParse(selectedSedeId) ?? 1;

  Future<void> loadSales() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      sales = await _service.getSalesByBranchId(branchId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class SaleDetailProvider extends ChangeNotifier {
  final FinanceService _service;
  final int saleId;

  bool isLoading = false;
  String? errorMessage;
  SaleResource? sale;

  SaleDetailProvider(this._service, this.saleId) {
    loadSaleDetails();
  }

  Future<void> loadSaleDetails() async {
    isLoading = true;
    notifyListeners();
    try {
      sale = await _service.getSaleById(saleId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class AddSaleProvider extends ChangeNotifier {
  final FinanceService _financeService;
  final ProductService _productService;
  final InventoryService _inventoryService;
  final String portfolioId;
  final String selectedSedeId;

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;
  String? successMessage;
  String? infoMessage;

  String customerId = "";
  String notes = "";

  List<ProductResource> availableProducts = [];
  List<SaleItemFormModel> selectedSaleItems = [];

  AddSaleProvider(
      this._financeService,
      this._productService,
      this._inventoryService,
      this.portfolioId,
      this.selectedSedeId
      ) {
    _loadAvailableProducts();
  }

  int get branchId => int.tryParse(selectedSedeId) ?? 1;

  double get totalAmount => selectedSaleItems.fold(0.0, (sum, item) => sum + item.subtotal);

  void _loadAvailableProducts() async {
    isLoading = true;
    notifyListeners();
    try {
      availableProducts = await _productService.getProductsByBranchId(branchId);
    } catch (e) {
      errorMessage = "Error cargando productos: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void addProductToSale(ProductResource product) {
    if (selectedSaleItems.any((item) => item.product.id == product.id)) {
      infoMessage = "El producto ya fue agregado.";
      notifyListeners();
      infoMessage = null;
    } else {
      selectedSaleItems.add(SaleItemFormModel(
          product: product,
          quantity: "1",
          unitPrice: product.salePrice.toString()
      ));
      notifyListeners();
    }
  }

  void updateSaleItemQuantity(int index, String quantity) {
    if (index >= 0 && index < selectedSaleItems.length) {
      selectedSaleItems[index].quantity = quantity;
      notifyListeners();
    }
  }

  void removeSaleItem(int index) {
    selectedSaleItems.removeAt(index);
    notifyListeners();
  }

  Future<bool> registerSale() async {
    if (isSubmitting) return false;

    if (customerId.isEmpty || selectedSaleItems.isEmpty) {
      errorMessage = "El ID del cliente y al menos un producto son obligatorios.";
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final itemsRequest = selectedSaleItems.map((item) => SaleItemRequest(
          productId: item.product.id,
          quantity: int.tryParse(item.quantity) ?? 0,
          unitPrice: double.tryParse(item.unitPrice) ?? 0.0
      )).toList();

      final request = CreateSaleRequest(
          customerId: int.parse(customerId),
          branchId: branchId,
          items: itemsRequest,
          notes: notes.isEmpty ? null : notes
      );

      final saleResponse = await _financeService.createSale(request);

      for (var saleItem in itemsRequest) {
        try {
          final product = await _productService.getProductById(saleItem.productId);
          for (var ingredient in product.ingredients) {
            final totalQty = ingredient.quantity * saleItem.quantity;
            final transaction = CreateInventoryTransactionResource(
                supplyItemId: ingredient.supplyItemId,
                branchId: branchId,
                type: TransactionType.SALIDA,
                quantity: totalQty,
                origin: "Venta de Producto '${product.name}' (ID: ${product.id})"
            );
            await _inventoryService.registerMovement(transaction);
          }
        } catch (_) {}
      }

      successMessage = "Venta registrada exitosamente. ID: ${saleResponse.id}";
      return true;

    } catch (e) {
      errorMessage = "Error al registrar venta: $e";
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}

class SaleItemFormModel {
  final ProductResource product;
  String quantity;
  String unitPrice;

  SaleItemFormModel({
    required this.product,
    required this.quantity,
    required this.unitPrice
  });

  double get subtotal => (int.tryParse(quantity) ?? 0) * (double.tryParse(unitPrice) ?? 0.0);
}