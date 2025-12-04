import 'package:flutter/material.dart';
import '../data/models/finance_models.dart';
import '../data/network/finance_service.dart';
import '../../contacts/data/models/contact_models.dart';
import '../../contacts/data/network/contacts_service.dart';
import '../../inventory/data/models/inventory_models.dart';
import '../../inventory/data/network/inventory_service.dart';

class PurchaseOrderListProvider extends ChangeNotifier {
  final FinanceService _service;
  final String selectedSedeId;

  bool isLoading = false;
  String? errorMessage;
  List<PurchaseOrderResource> purchaseOrders = [];

  PurchaseOrderListProvider(this._service, this.selectedSedeId) {
    loadPurchaseOrders();
  }

  int get branchId => int.tryParse(selectedSedeId) ?? 1;

  Future<void> loadPurchaseOrders() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      purchaseOrders = await _service.getPurchaseOrdersByBranchId(branchId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class PurchaseOrderDetailProvider extends ChangeNotifier {
  final FinanceService _service;
  final InventoryService _inventoryService;
  final int purchaseOrderId;
  final int branchId;

  bool isLoading = false;
  String? errorMessage;
  PurchaseOrderResource? purchaseOrder;
  String resolvedSupplyItemName = "Cargando...";

  PurchaseOrderDetailProvider(this._service, this._inventoryService, this.purchaseOrderId, this.branchId) {
    loadDetails();
  }

  Future<void> loadDetails() async {
    isLoading = true;
    notifyListeners();
    try {
      purchaseOrder = await _service.getPurchaseOrderById(purchaseOrderId, branchId);

      resolvedSupplyItemName = purchaseOrder?.supplyItemName ?? "Desconocido";

      if (resolvedSupplyItemName.isEmpty || resolvedSupplyItemName == "Desconocido") {
        try {
          final item = await _inventoryService.getSupplyItemById(purchaseOrder!.supplyItemId);
          resolvedSupplyItemName = item.name;
        } catch (_) {
          resolvedSupplyItemName = "No encontrado";
        }
      }

    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class AddPurchaseOrderProvider extends ChangeNotifier {
  final FinanceService _financeService;
  final ContactsService _contactsService;
  final InventoryService _inventoryService;
  final String portfolioId;
  final String selectedSedeId;

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;
  String? successMessage;

  List<ProviderResource> availableProviders = [];
  List<SupplyItemResource> availableSupplyItems = [];

  ProviderResource? selectedProvider;
  SupplyItemResource? selectedSupplyItem;
  String quantity = "";
  String unitPrice = "";
  DateTime purchaseDate = DateTime.now();
  DateTime? expirationDate;
  String notes = "";

  AddPurchaseOrderProvider(
      this._financeService,
      this._contactsService,
      this._inventoryService,
      this.portfolioId,
      this.selectedSedeId
      ) {
    _loadInitialData();
  }

  int get branchId => int.tryParse(selectedSedeId) ?? 1;

  void _loadInitialData() async {
    isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _contactsService.getProviders(portfolioId),
        _inventoryService.getSupplyItemsByBranch(branchId)
      ]);

      availableProviders = results[0] as List<ProviderResource>;
      availableSupplyItems = results[1] as List<SupplyItemResource>;

    } catch (e) {
      errorMessage = "Error cargando datos: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setProvider(ProviderResource? p) { selectedProvider = p; notifyListeners(); }
  void setSupplyItem(SupplyItemResource? s) { selectedSupplyItem = s; notifyListeners(); }
  void setQuantity(String q) { quantity = q; notifyListeners(); }
  void setUnitPrice(String p) { unitPrice = p; notifyListeners(); }
  void setNotes(String n) { notes = n; notifyListeners(); }
  void setPurchaseDate(DateTime d) { purchaseDate = d; notifyListeners(); }
  void setExpirationDate(DateTime? d) { expirationDate = d; notifyListeners(); }

  Future<bool> registerPurchaseOrder() async {
    if (isSubmitting) return false;

    if (selectedProvider == null || selectedSupplyItem == null || quantity.isEmpty || unitPrice.isEmpty) {
      errorMessage = "Completa los campos obligatorios (*)";
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final request = CreatePurchaseOrderRequest(
        branchId: branchId,
        providerId: selectedProvider!.id,
        supplyItemId: selectedSupplyItem!.id,
        quantity: double.parse(quantity),
        unitPrice: double.parse(unitPrice),
        purchaseDate: purchaseDate.toIso8601String().split('T')[0],
        expirationDate: expirationDate?.toIso8601String().split('T')[0],
        notes: notes.isEmpty ? null : notes,
      );

      await _financeService.createPurchaseOrder(request);
      successMessage = "Compra registrada con éxito";
      return true;

    } catch (e) {
      errorMessage = "Error al registrar: $e";
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}