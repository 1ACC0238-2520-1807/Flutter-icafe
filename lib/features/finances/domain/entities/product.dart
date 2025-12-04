class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int branchId;
  final int stock;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.branchId,
    required this.stock,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      branchId: (json['branchId'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
