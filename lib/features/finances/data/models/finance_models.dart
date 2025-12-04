class CreatePurchaseOrderRequest {
  final int branchId;
  final int providerId;
  final int supplyItemId;
  final double quantity;
  final double unitPrice;
  final String purchaseDate;
  final String? expirationDate;
  final String? notes;

  CreatePurchaseOrderRequest({
    required this.branchId,
    required this.providerId,
    required this.supplyItemId,
    required this.quantity,
    required this.unitPrice,
    required this.purchaseDate,
    this.expirationDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'providerId': providerId,
    'supplyItemId': supplyItemId,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'purchaseDate': purchaseDate,
    'expirationDate': expirationDate,
    'notes': notes,
  };
}

class PurchaseOrderResource {
  final int id;
  final int branchId;
  final int providerId;
  final String providerName;
  final String providerPhone;
  final String providerEmail;
  final int supplyItemId;
  final String supplyItemName;
  final double unitPrice;
  final double quantity;
  final double totalAmount;
  final String purchaseDate;
  final String? expirationDate;
  final String status;
  final String? notes;

  PurchaseOrderResource({
    required this.id,
    required this.branchId,
    required this.providerId,
    required this.providerName,
    required this.providerPhone,
    required this.providerEmail,
    required this.supplyItemId,
    required this.supplyItemName,
    required this.unitPrice,
    required this.quantity,
    required this.totalAmount,
    required this.purchaseDate,
    this.expirationDate,
    required this.status,
    this.notes,
  });

  factory PurchaseOrderResource.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderResource(
      id: json['id'],
      branchId: json['branchId'],
      providerId: json['providerId'],
      providerName: json['providerName'],
      providerPhone: json['providerPhone'] ?? '',
      providerEmail: json['providerEmail'] ?? '',
      supplyItemId: json['supplyItemId'],
      supplyItemName: json['supplyItemName'] ?? '',
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      purchaseDate: json['purchaseDate'],
      expirationDate: json['expirationDate'],
      status: json['status'],
      notes: json['notes'],
    );
  }
}

// ==========================================
//               SALES MODELS
// ==========================================

class SaleItemRequest {
  final int productId;
  final int quantity;
  final double unitPrice;

  SaleItemRequest({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
    'unitPrice': unitPrice,
  };
}

class CreateSaleRequest {
  final int customerId;
  final int branchId;
  final List<SaleItemRequest> items;
  final String? notes;

  CreateSaleRequest({
    required this.customerId,
    required this.branchId,
    required this.items,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'customerId': customerId,
    'branchId': branchId,
    'items': items.map((i) => i.toJson()).toList(),
    'notes': notes,
  };
}

class SaleItemResource {
  final int productId;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  SaleItemResource({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory SaleItemResource.fromJson(Map<String, dynamic> json) {
    return SaleItemResource(
      productId: json['productId'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}

class SaleResource {
  final int id;
  final int customerId;
  final int branchId;
  final List<SaleItemResource> items;
  final double totalAmount;
  final String saleDate; // Formato ISO devuelto por backend
  final String status;
  final String? notes;

  SaleResource({
    required this.id,
    required this.customerId,
    required this.branchId,
    required this.items,
    required this.totalAmount,
    required this.saleDate,
    required this.status,
    this.notes,
  });

  factory SaleResource.fromJson(Map<String, dynamic> json) {
    return SaleResource(
      id: json['id'],
      customerId: json['customerId'],
      branchId: json['branchId'],
      items: (json['items'] as List)
          .map((i) => SaleItemResource.fromJson(i))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      saleDate: json['saleDate'],
      status: json['status'],
      notes: json['notes'],
    );
  }
}