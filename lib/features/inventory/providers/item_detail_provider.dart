import 'package:flutter/material.dart';
import '../data/models/inventory_models.dart';
import '../data/network/inventory_service.dart';

class ItemDetailProvider extends ChangeNotifier {
  final InventoryService _service;
  final String portfolioId;
  final String selectedSedeId;
  final String? itemId;

  String name = "";
  UnitMeasureType unit = UnitMeasureType.UNIDADES;
  String unitPrice = "";
  String stock = "";
  String dateInputText = "";

  bool isLoading = false;
  SupplyItemResource? supplyItem;

  ItemDetailProvider(this._service, this.portfolioId, this.selectedSedeId, this.itemId) {
    _init();
  }

  int get branchId => int.tryParse(selectedSedeId) ?? 1;

  void _init() async {
    if (itemId != null) {
      await loadItem(int.parse(itemId!));
    }
  }

  Future<void> loadItem(int id) async {
    isLoading = true;
    notifyListeners();
    try {
      supplyItem = await _service.getSupplyItemById(id);
      if (supplyItem != null) {
        name = supplyItem!.name;
        unit = UnitMeasureType.values.firstWhere(
                (e) => e.toString().split('.').last == supplyItem!.unit,
            orElse: () => UnitMeasureType.UNIDADES
        );
        unitPrice = supplyItem!.unitPrice.toString();
        stock = supplyItem!.stock.toString();
        dateInputText = supplyItem!.expiredDate ?? "";
      }
    } catch (e) {
      // Manejar error
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveItem(BuildContext context) async {
    final priceVal = double.tryParse(unitPrice);
    final stockVal = double.tryParse(stock);

    if (name.isEmpty || priceVal == null || stockVal == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Datos inválidos")));
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      if (itemId == null) {
        final request = CreateSupplyItemRequest(
          providerId: 1,
          branchId: branchId,
          name: name,
          unit: unit.toString().split('.').last,
          unitPrice: priceVal,
          stock: stockVal,
          expiredDate: dateInputText.isNotEmpty ? dateInputText : null,
        );

        final newItem = await _service.createSupplyItem(request);

        final moveRequest = CreateInventoryTransactionResource(
            type: TransactionType.ENTRADA,
            quantity: stockVal,
            origin: "Initial Stock",
            supplyItemId: newItem.id,
            branchId: branchId
        );

        await _service.registerMovement(moveRequest);

      } else {
        final updateRequest = UpdateSupplyItemRequest(
          name: name,
          unitPrice: priceVal,
          stock: stockVal,
          expiredDate: dateInputText.isNotEmpty ? dateInputText : null,
        );
        await _service.updateSupplyItem(int.parse(itemId!), updateRequest);
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      return false;
    }
  }
}