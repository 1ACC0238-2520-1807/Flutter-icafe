class PurchaseOrder {
  final int id;
  final int? supplierId;
  final int branchId;
  final List<PurchaseOrderItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final String status;
  final String? notes;

  PurchaseOrder({
    required this.id,
    this.supplierId,
    required this.branchId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    this.notes,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    List<PurchaseOrderItem> itemsList = [];
    if (json['items'] != null) {
      itemsList = (json['items'] as List)
          .map((item) => PurchaseOrderItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return PurchaseOrder(
      id: (json['id'] as num?)?.toInt() ?? 0,
      supplierId: (json['supplierId'] as num?)?.toInt(),
      branchId: (json['branchId'] as num?)?.toInt() ?? 0,
      items: itemsList,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      orderDate: json['orderDate'] != null 
          ? DateTime.parse(json['orderDate'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'Pending',
      notes: json['notes'] as String?,
    );
  }
}

class PurchaseOrderItem {
  final int productId;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  PurchaseOrderItem({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
