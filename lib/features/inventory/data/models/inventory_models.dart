enum UnitMeasureType { GRAMOS, KILOGRAMOS, LITROS, MILILITROS, UNIDADES }
enum TransactionType { ENTRADA, SALIDA }

class SupplyItemResource {
  final int id;
  final int providerId;
  final int branchId;
  final String name;
  final String unit;
  final double unitPrice;
  final double stock;
  final String buyDate;
  final String? expiredDate;

  SupplyItemResource({
    required this.id,
    required this.providerId,
    required this.branchId,
    required this.name,
    required this.unit,
    required this.unitPrice,
    required this.stock,
    required this.buyDate,
    this.expiredDate,
  });

  factory SupplyItemResource.fromJson(Map<String, dynamic> json) {
    return SupplyItemResource(
      id: json['id'],
      providerId: json['providerId'],
      branchId: json['branchId'],
      name: json['name'],
      unit: json['unit'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      stock: (json['stock'] as num).toDouble(),
      buyDate: json['buyDate'],
      expiredDate: json['expiredDate'],
    );
  }
}

// Equivalente a CreateSupplyItemRequest
class CreateSupplyItemRequest {
  final int providerId;
  final int branchId;
  final String name;
  final String unit;
  final double unitPrice;
  final double stock;
  final String? expiredDate;

  CreateSupplyItemRequest({
    required this.providerId,
    required this.branchId,
    required this.name,
    required this.unit,
    required this.unitPrice,
    required this.stock,
    this.expiredDate,
  });

  Map<String, dynamic> toJson() => {
    'providerId': providerId,
    'branchId': branchId,
    'name': name,
    'unit': unit,
    'unitPrice': unitPrice,
    'stock': stock,
    'expiredDate': expiredDate,
  };
}

class UpdateSupplyItemRequest {
  final String name;
  final double unitPrice;
  final double stock;
  final String? expiredDate;

  UpdateSupplyItemRequest({
    required this.name,
    required this.unitPrice,
    required this.stock,
    this.expiredDate,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'unitPrice': unitPrice,
    'stock': stock,
    'expiredDate': expiredDate,
  };
}

class InventoryTransactionResource {
  final int id;
  final int supplyItemId;
  final int branchId;
  final TransactionType type;
  final double quantity;
  final String origin;
  final String movementDate;

  InventoryTransactionResource({
    required this.id,
    required this.supplyItemId,
    required this.branchId,
    required this.type,
    required this.quantity,
    required this.origin,
    required this.movementDate,
  });

  factory InventoryTransactionResource.fromJson(Map<String, dynamic> json) {
    return InventoryTransactionResource(
      id: json['id'],
      supplyItemId: json['supplyItemId'],
      branchId: json['branchId'],
      type: TransactionType.values.firstWhere((e) => e.toString().split('.').last == json['type']),
      quantity: (json['quantity'] as num).toDouble(),
      origin: json['origin'],
      movementDate: json['movementDate'],
    );
  }
}

class CreateInventoryTransactionResource {
  final int supplyItemId;
  final int branchId;
  final TransactionType type;
  final double quantity;
  final String origin;

  CreateInventoryTransactionResource({
    required this.supplyItemId,
    required this.branchId,
    required this.type,
    required this.quantity,
    required this.origin,
  });

  Map<String, dynamic> toJson() => {
    'supplyItemId': supplyItemId,
    'branchId': branchId,
    'type': type.toString().split('.').last,
    'quantity': quantity,
    'origin': origin,
  };
}

class SupplyItemWithCurrentStock {
  final SupplyItemResource item;
  final double currentStock;

  SupplyItemWithCurrentStock({required this.item, required this.currentStock});
}