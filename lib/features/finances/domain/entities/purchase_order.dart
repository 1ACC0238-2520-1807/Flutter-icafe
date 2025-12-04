class PurchaseOrder {
  final int id;
  final int branchId;
  final int? providerId;
  final String? providerName;
  final String? providerEmail;
  final String? providerPhone;
  final String? providerRuc;
  final int? supplyItemId;
  final double unitPrice;
  final double quantity;
  final double totalAmount;
  final DateTime purchaseDate;
  final DateTime? expirationDate;
  final String status;
  final String? notes;

  PurchaseOrder({
    required this.id,
    required this.branchId,
    this.providerId,
    this.providerName,
    this.providerEmail,
    this.providerPhone,
    this.providerRuc,
    this.supplyItemId,
    required this.unitPrice,
    required this.quantity,
    required this.totalAmount,
    required this.purchaseDate,
    this.expirationDate,
    required this.status,
    this.notes,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: (json['id'] as num?)?.toInt() ?? 0,
      branchId: (json['branchId'] as num?)?.toInt() ?? 0,
      providerId: (json['providerId'] as num?)?.toInt(),
      providerName: json['providerName'] as String?,
      providerEmail: json['providerEmail'] as String?,
      providerPhone: json['providerPhone'] as String?,
      providerRuc: json['providerRuc'] as String?,
      supplyItemId: (json['supplyItemId'] as num?)?.toInt(),
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      purchaseDate: json['purchaseDate'] != null 
          ? DateTime.parse(json['purchaseDate'] as String)
          : DateTime.now(),
      expirationDate: json['expirationDate'] != null 
          ? DateTime.parse(json['expirationDate'] as String)
          : null,
      status: json['status'] as String? ?? 'PENDING',
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'providerId': providerId,
      'supplyItemId': supplyItemId,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'purchaseDate': purchaseDate.toIso8601String().split('T')[0],
      'expirationDate': expirationDate?.toIso8601String().split('T')[0],
      'status': status,
      'notes': notes,
    };
  }
}
