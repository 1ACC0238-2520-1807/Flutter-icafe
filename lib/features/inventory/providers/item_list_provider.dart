import 'package:flutter/material.dart';
import '../data/models/inventory_models.dart';
import '../data/network/inventory_service.dart';

enum ItemListStatus { initial, loading, success, error }

class ItemListProvider extends ChangeNotifier {
  final InventoryService _service;
  final String portfolioId;
  final String selectedSedeId;

  ItemListStatus status = ItemListStatus.initial;
  List<SupplyItemWithCurrentStock> items = [];
  String errorMessage = '';

  ItemListProvider(this._service, this.portfolioId, this.selectedSedeId);

  int get branchId => int.tryParse(selectedSedeId) ?? 1;

  Future<void> loadItems() async {
    status = ItemListStatus.loading;
    notifyListeners();

    try {
      final baseItems = await _service.getSupplyItemsByBranch(branchId);

      final itemsWithStock = await Future.wait(baseItems.map((item) async {
        try {
          final stock = await _service.getCurrentStock(branchId, item.id);
          return SupplyItemWithCurrentStock(item: item, currentStock: stock);
        } catch (e) {
          return SupplyItemWithCurrentStock(item: item, currentStock: 0.0);
        }
      }));

      items = itemsWithStock;
      status = ItemListStatus.success;
    } catch (e) {
      errorMessage = e.toString();
      status = ItemListStatus.error;
    }
    notifyListeners();
  }
}