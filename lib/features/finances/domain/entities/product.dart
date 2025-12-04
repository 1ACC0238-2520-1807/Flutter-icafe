class Product {
  final int id;
  final String name;
  final int branchId;
  final double costPrice;
  final double salePrice;
  final double profitMargin;
  final String status;

  Product({
    required this.id,
    required this.name,
    required this.branchId,
    required this.costPrice,
    required this.salePrice,
    required this.profitMargin,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      branchId: (json['branchId'] as num?)?.toInt() ?? 0,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      salePrice: (json['salePrice'] as num?)?.toDouble() ?? 0.0,
      profitMargin: (json['profitMargin'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }
}
