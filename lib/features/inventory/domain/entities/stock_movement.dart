class StockMovement {
  final int id;
  final int supplyItemId;
  final int branchId;
  final String type; // ENTRADA, SALIDA
  final double quantity;
  final String origin;
  final DateTime movementDate;

  StockMovement({
    required this.id,
    required this.supplyItemId,
    required this.branchId,
    required this.type,
    required this.quantity,
    required this.origin,
    required this.movementDate,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: (json['id'] as num?)?.toInt() ?? 0,
      supplyItemId: (json['supplyItemId'] as num?)?.toInt() ?? 0,
      branchId: (json['branchId'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? 'ENTRADA',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      origin: json['origin'] as String? ?? '',
      movementDate: json['movementDate'] != null
          ? DateTime.parse(json['movementDate'] as String)
          : DateTime.now(),
    );
  }

  bool get isEntrada => type.toUpperCase() == 'ENTRADA';
  bool get isSalida => type.toUpperCase() == 'SALIDA';
}
