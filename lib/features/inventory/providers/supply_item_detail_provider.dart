import 'package:flutter/foundation.dart';
import '../data/models/inventory_models.dart';
import '../data/network/inventory_service.dart';
import '../../contacts/data/models/contact_models.dart';
import '../../contacts/data/network/contacts_service.dart';

class SupplyItemDetailProvider extends ChangeNotifier {
  final InventoryService _inventoryService;
  final ContactsService _contactsService;
  final String portfolioId;
  final int supplyItemId;

  bool isLoading = false;
  bool isDeleting = false;
  String? errorMessage;

  SupplyItemResource? supplyItem;
  ProviderResource? provider;

  SupplyItemDetailProvider({
    required InventoryService inventoryService,
    required ContactsService contactsService,
    required this.portfolioId,
    required this.supplyItemId,
  })  : _inventoryService = inventoryService,
        _contactsService = contactsService {
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Cargar el insumo
      supplyItem = await _inventoryService.getSupplyItemById(supplyItemId);

      // Cargar el proveedor
      if (supplyItem != null) {
        final providers = await _contactsService.getProviders(portfolioId);
        provider = providers.firstWhere(
          (p) => p.id == supplyItem!.providerId,
          orElse: () => ProviderResource(
            id: supplyItem!.providerId,
            nameCompany: 'Proveedor #${supplyItem!.providerId}',
            email: '',
            phoneNumber: '',
            ruc: '',
          ),
        );
      }
    } catch (e) {
      errorMessage = 'Error al cargar el insumo: $e';
      debugPrint(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadData();
  }

  Future<bool> deleteSupplyItem() async {
    if (supplyItem == null) return false;

    isDeleting = true;
    notifyListeners();

    try {
      await _inventoryService.deleteSupplyItem(supplyItemId);
      return true;
    } catch (e) {
      errorMessage = 'Error al eliminar el insumo: $e';
      debugPrint(errorMessage);
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }

  String formatUnit(String unit) {
    switch (unit.toUpperCase()) {
      case 'GRAMOS':
        return 'Gramos';
      case 'KILOGRAMOS':
        return 'Kilogramos';
      case 'MILILITROS':
        return 'Mililitros';
      case 'LITROS':
        return 'Litros';
      case 'UNIDADES':
        return 'Unidades';
      default:
        return unit;
    }
  }

  String formatUnitShort(String unit) {
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
        return unit.toLowerCase();
    }
  }
}
