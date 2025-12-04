
enum ProductStatus { ACTIVE, ARCHIVED }

class ProductIngredientResource {
  final int ingredientId;
  final String? name;
  final String? unit;
  final double quantity;

  ProductIngredientResource({
    required this.ingredientId,
    this.name,
    this.unit,
    required this.quantity,
  });

  /// Crea una copia con nombre y unidad actualizados
  ProductIngredientResource copyWith({String? name, String? unit}) {
    return ProductIngredientResource(
      ingredientId: ingredientId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      quantity: quantity,
    );
  }

  factory ProductIngredientResource.fromJson(Map<String, dynamic> json) {
    return ProductIngredientResource(
      ingredientId: json['ingredientId'] ?? json['supplyItemId'] ?? 0,
      name: json['name'],
      unit: json['unit'],
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
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
      id: json['id'] ?? 0,
      branchId: json['branchId'] ?? 0,
      name: json['name'] ?? '',
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      salePrice: (json['salePrice'] as num?)?.toDouble() ?? 0.0,
      profitMargin: (json['profitMargin'] as num?)?.toDouble() ?? 0.0,
      status: ProductStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['status'],
          orElse: () => ProductStatus.ACTIVE
      ),
      ingredients: json['ingredients'] != null 
          ? (json['ingredients'] as List)
              .map((i) => ProductIngredientResource.fromJson(i))
              .toList()
          : [],
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