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
      debugPrint('📦 Cargando insumos para branchId: $branchId');
      final baseItems = await _service.getSupplyItemsByBranch(branchId);
      debugPrint('📦 Insumos obtenidos: ${baseItems.length}');

      // Usar el stock que ya viene en el modelo en lugar de hacer otra llamada
      final itemsWithStock = baseItems.map((item) {
        return SupplyItemWithCurrentStock(item: item, currentStock: item.stock);
      }).toList();

      items = itemsWithStock;
      status = ItemListStatus.success;
      debugPrint('✅ Items cargados: ${items.length}');
    } catch (e) {
      debugPrint('❌ Error cargando items: $e');
      errorMessage = e.toString();
      status = ItemListStatus.error;
    }
    notifyListeners();
  }
}