class Sale {
  final int id;
  final int? customerId;
  final int branchId;
  final List<SaleItem> items;
  final double totalAmount;
  final DateTime saleDate;
  final String status;
  final String? notes;

  Sale({
    required this.id,
    this.customerId,
    required this.branchId,
    required this.items,
    required this.totalAmount,
    required this.saleDate,
    required this.status,
    this.notes,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    List<SaleItem> itemsList = [];
    if (json['items'] != null) {
      itemsList = (json['items'] as List)
          .map((item) => SaleItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return Sale(
      id: (json['id'] as num?)?.toInt() ?? 0,
      customerId: (json['customerId'] as num?)?.toInt(),
      branchId: (json['branchId'] as num?)?.toInt() ?? 0,
      items: itemsList,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      saleDate: json['saleDate'] != null 
          ? DateTime.parse(json['saleDate'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'Pending',
      notes: json['notes'] as String?,
    );
  }
}

class SaleItem {
  final int productId;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  SaleItem({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
