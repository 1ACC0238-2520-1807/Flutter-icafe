import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../data/models/inventory_models.dart';
import '../data/network/inventory_service.dart';

class InventoryMovementsProvider extends ChangeNotifier {
  final InventoryService _service;
  final String portfolioId;
  final String selectedSedeId;

  bool isLoading = false;
  String? errorMessage;

  List<InventoryTransactionResource> movements = [];
  InventoryTransactionResource? selectedMovement;

  Map<int, SupplyItemResource> supplyItemDetails = {};

  InventoryMovementsProvider(this._service, this.portfolioId, this.selectedSedeId) {
    loadMovements();
  }

  int get branchId => int.tryParse(selectedSedeId) ?? 1;

  Future<void> loadMovements() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {

      final loadedMovements = await _service.getAllStockMovementsByBranch(branchId);

      loadedMovements.sort((a, b) => b.movementDate.compareTo(a.movementDate));
      movements = loadedMovements;

      final supplyItems = await _service.getSupplyItemsByBranch(branchId);
      supplyItemDetails = {for (var item in supplyItems) item.id: item};

      if (movements.isNotEmpty) {
        selectedMovement = movements.first;
      } else {
        selectedMovement = null;
      }

    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        errorMessage = "El servicio de movimientos no está disponible en este momento.";
      } else if (e.response?.statusCode == 404) {
        errorMessage = "No se encontró el endpoint de movimientos.";
      } else {
        errorMessage = "Error de conexión: ${e.message}";
      }
      movements = [];
    } catch (e) {
      errorMessage = "Error al cargar movimientos: $e";
      movements = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectMovement(InventoryTransactionResource movement) {
    selectedMovement = movement;
    notifyListeners();
  }
}