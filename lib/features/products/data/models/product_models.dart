
enum ProductStatus { ACTIVE, ARCHIVED }

class ProductIngredientResource {
  final int supplyItemId;
  final String? name;
  final String? unit;
  final double quantity;

  ProductIngredientResource({
    required this.supplyItemId,
    this.name,
    this.unit,
    required this.quantity,
  });

  factory ProductIngredientResource.fromJson(Map<String, dynamic> json) {
    return ProductIngredientResource(
      supplyItemId: json['supplyItemId'],
      name: json['name'],
      unit: json['unit'],
      quantity: (json['quantity'] as num).toDouble(),
    );
  }
}

class ProductResource {
  final int id;
  final int branchId;
  final String name;
  final double costPrice;
  final double salePrice;
  final double profitMargin;
  final ProductStatus status;
  final List<ProductIngredientResource> ingredients;

  ProductResource({
    required this.id,
    required this.branchId,
    required this.name,
    required this.costPrice,
    required this.salePrice,
    required this.profitMargin,
    required this.status,
    required this.ingredients,
  });

  factory ProductResource.fromJson(Map<String, dynamic> json) {
    return ProductResource(
      id: json['id'],
      branchId: json['branchId'],
      name: json['name'],
      costPrice: (json['costPrice'] as num).toDouble(),
      salePrice: (json['salePrice'] as num).toDouble(),
      profitMargin: (json['profitMargin'] as num).toDouble(),
      status: ProductStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['status'],
          orElse: () => ProductStatus.ACTIVE
      ),
      ingredients: (json['ingredients'] as List)
          .map((i) => ProductIngredientResource.fromJson(i))
          .toList(),
    );
  }
}

class CreateProductRequest {
  final int branchId;
  final String name;
  final double costPrice;
  final double profitMargin;

  CreateProductRequest({
    required this.branchId,
    required this.name,
    required this.costPrice,
    required this.profitMargin,
  });

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'name': name,
    'costPrice': costPrice,
    'profitMargin': profitMargin,
  };
}

class UpdateProductRequest {
  final String name;
  final double costPrice;
  final double profitMargin;

  UpdateProductRequest({
    required this.name,
    required this.costPrice,
    required this.profitMargin,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'costPrice': costPrice,
    'profitMargin': profitMargin,
  };
}

class AddIngredientRequest {
  final int supplyItemId;
  final double quantity;

  AddIngredientRequest({required this.supplyItemId, required this.quantity});

  Map<String, dynamic> toJson() => {
    'supplyItemId': supplyItemId,
    'quantity': quantity,
  };
}