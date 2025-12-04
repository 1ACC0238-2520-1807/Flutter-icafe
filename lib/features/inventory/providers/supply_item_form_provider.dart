import 'package:flutter/foundation.dart';
import '../data/models/inventory_models.dart';
import '../data/network/inventory_service.dart';
import '../../contacts/data/models/contact_models.dart';
import '../../contacts/data/network/contacts_service.dart';

class SupplyItemFormProvider extends ChangeNotifier {
  final InventoryService _inventoryService;
  final ContactsService _contactsService;
  final String portfolioId;
  final int branchId;
  final int? supplyItemId;

  bool isLoading = false;
  String? errorMessage;

  // Datos del formulario
  String name = '';
  String unitPrice = '';
  String stock = '';
  String? _expiredDate;
  UnitMeasureType? _selectedUnit;
  ProviderResource? _selectedProvider;

  // Lista de proveedores disponibles
  List<ProviderResource> availableProviders = [];

  // Getters y setters con notificación
  String? get expiredDate => _expiredDate;
  set expiredDate(String? value) {
    _expiredDate = value;
    notifyListeners();
  }

  UnitMeasureType? get selectedUnit => _selectedUnit;
  set selectedUnit(UnitMeasureType? value) {
    _selectedUnit = value;
    notifyListeners();
  }

  ProviderResource? get selectedProvider => _selectedProvider;
  set selectedProvider(ProviderResource? value) {
    _selectedProvider = value;
    notifyListeners();
  }

  SupplyItemFormProvider({
    required InventoryService inventoryService,
    required ContactsService contactsService,
    required this.portfolioId,
    required this.branchId,
    this.supplyItemId,
  })  : _inventoryService = inventoryService,
        _contactsService = contactsService {
    _init();
  }

  Future<void> _init() async {
    isLoading = true;
    notifyListeners();

    try {
      // Cargar proveedores
      availableProviders = await _contactsService.getProviders(portfolioId);

      // Si es edición, cargar los datos del insumo
      if (supplyItemId != null) {
        final item = await _inventoryService.getSupplyItemById(supplyItemId!);
        name = item.name;
        unitPrice = item.unitPrice == item.unitPrice.toInt()
            ? item.unitPrice.toInt().toString()
            : item.unitPrice.toString();
        stock = item.stock == item.stock.toInt()
            ? item.stock.toInt().toString()
            : item.stock.toString();
        _expiredDate = item.expiredDate;
        
        // Buscar la unidad
        _selectedUnit = UnitMeasureType.values.firstWhere(
          (u) => u.toString().split('.').last == item.unit,
          orElse: () => UnitMeasureType.UNIDADES,
        );
        
        // Buscar el proveedor
        _selectedProvider = availableProviders.firstWhere(
          (p) => p.id == item.providerId,
          orElse: () => availableProviders.isNotEmpty ? availableProviders.first : throw Exception('No providers'),
        );
      }
    } catch (e) {
      errorMessage = 'Error cargando datos: $e';
      debugPrint(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveSupplyItem({
    required String itemName,
    required String itemUnitPrice,
    required String itemStock,
  }) async {
    // Validaciones
    final price = double.tryParse(itemUnitPrice);
    final stockQty = double.tryParse(itemStock);

    if (itemName.isEmpty) {
      errorMessage = 'El nombre es obligatorio';
      notifyListeners();
      return false;
    }

    if (price == null || price <= 0) {
      errorMessage = 'El precio debe ser un número válido mayor a 0';
      notifyListeners();
      return false;
    }

    if (stockQty == null || stockQty < 0) {
      errorMessage = 'El stock debe ser un número válido';
      notifyListeners();
      return false;
    }

    if (_selectedUnit == null) {
      errorMessage = 'Selecciona una unidad de medida';
      notifyListeners();
      return false;
    }

    if (_selectedProvider == null) {
      errorMessage = 'Selecciona un proveedor';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (supplyItemId == null) {
        // Crear nuevo insumo
        final request = CreateSupplyItemRequest(
          providerId: _selectedProvider!.id,
          branchId: branchId,
          name: itemName,
          unit: _selectedUnit.toString().split('.').last,
          unitPrice: price,
          stock: stockQty,
          expiredDate: _expiredDate,
        );
        debugPrint('Creating supply item: ${request.toJson()}');
        await _inventoryService.createSupplyItem(request);
      } else {
        // Actualizar insumo existente
        final request = UpdateSupplyItemRequest(
          name: itemName,
          unitPrice: price,
          stock: stockQty,
          expiredDate: _expiredDate,
        );
        debugPrint('Updating supply item $supplyItemId: ${request.toJson()}');
        await _inventoryService.updateSupplyItem(supplyItemId!, request);
      }

      return true;
    } catch (e) {
      errorMessage = 'Error guardando insumo: $e';
      debugPrint(errorMessage);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
