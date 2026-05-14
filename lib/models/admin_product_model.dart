class AdminProductOption {
  final String name;
  final List<String> values;

  AdminProductOption({required this.name, required this.values});

  Map<String, dynamic> toJson() {
    return {'name': name, 'values': values};
  }

  factory AdminProductOption.fromJson(Map<String, dynamic> json) {
    return AdminProductOption(
      name: json['name'] ?? '',
      values: List<String>.from(json['values'] ?? []),
    );
  }
}

class AdminProductVariant {
  final String id;
  final String title;
  double price;
  double weightG;
  String? image;
  final List<String> images;
  final Map<String, String> attributes;
  int stockQuantity;

  AdminProductVariant({
    required this.id,
    required this.title,
    required this.price,
    required this.weightG,
    this.image,
    required this.images,
    required this.attributes,
    required this.stockQuantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'weight_g': weightG,
      'image': image,
      'images': images,
      'attributes': attributes,
      'stock_quantity': stockQuantity,
    };
  }

  factory AdminProductVariant.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];

    return AdminProductVariant(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
      weightG: (json['weight_g'] as num? ?? 0).toDouble(),
      image: json['image']?.toString(),
      images: rawImages is List
          ? rawImages
                .map((item) => item.toString().trim())
                .where((item) => item.isNotEmpty)
                .toList()
          : rawImages is String && rawImages.trim().isNotEmpty
          ? rawImages
                .split(',')
                .map((item) => item.trim())
                .where((item) => item.isNotEmpty)
                .toList()
          : <String>[],
      attributes: Map<String, String>.from(json['attributes'] ?? {}),
      stockQuantity: (json['stock_quantity'] as num? ?? 0).toInt(),
    );
  }
}

class AdminBulkConfig {
  final double pricePerKg;
  final double minOrderWeightG;
  final List<Map<String, dynamic>> preMadeTemplates;

  AdminBulkConfig({
    required this.pricePerKg,
    required this.minOrderWeightG,
    required this.preMadeTemplates,
  });

  Map<String, dynamic> toJson() {
    return {
      'price_per_kg': pricePerKg,
      'min_order_weight_g': minOrderWeightG,
      'pre_made_templates': preMadeTemplates,
    };
  }

  factory AdminBulkConfig.fromJson(Map<String, dynamic> json) {
    final templates = json['pre_made_templates'] as List<dynamic>? ?? [];

    return AdminBulkConfig(
      pricePerKg: (json['price_per_kg'] as num? ?? 0).toDouble(),
      minOrderWeightG: (json['min_order_weight_g'] as num? ?? 0).toDouble(),
      preMadeTemplates: templates
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
    );
  }
}

class AdminProductMetadata {
  final bool isNewArrival;
  final double caloriesPer100g;

  AdminProductMetadata({
    required this.isNewArrival,
    required this.caloriesPer100g,
  });

  Map<String, dynamic> toJson() {
    return {
      'is_new_arrival': isNewArrival,
      'calories_per_100g': caloriesPer100g,
    };
  }

  factory AdminProductMetadata.fromJson(Map<String, dynamic> json) {
    return AdminProductMetadata(
      isNewArrival: json['is_new_arrival'] ?? false,
      caloriesPer100g: (json['calories_per_100g'] as num? ?? 0).toDouble(),
    );
  }
}

class AdminProductModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final String descriptionAr;
  final String descriptionEn;
  final String mainImage;
  final bool isDietFriendly;
  final bool isCustomizable;
  final List<AdminProductOption> options;
  final List<AdminProductVariant> variants;
  final AdminBulkConfig? bulkConfig;
  final AdminProductMetadata metadata;

  AdminProductModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.mainImage,
    required this.isDietFriendly,
    required this.isCustomizable,
    required this.options,
    required this.variants,
    this.bulkConfig,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'product': {
        'id': id,
        'title': title,
        'category': category,
        'description': descriptionEn,
        'description_ar': descriptionAr,
        'description_en': descriptionEn,
        'main_image': mainImage,
        'is_diet_friendly': isDietFriendly,
        'is_customizable': isCustomizable,
        'options': options.map((option) => option.toJson()).toList(),
        'variants': variants.map((variant) => variant.toJson()).toList(),
        'bulk_config': bulkConfig?.toJson(),
        'metadata': metadata.toJson(),
      },
    };
  }

  factory AdminProductModel.fromJson(Map<String, dynamic> json) {
    final productJson = json.containsKey('product')
        ? Map<String, dynamic>.from(json['product'])
        : json;
    final oldDescription = productJson['description'] ?? '';

    return AdminProductModel(
      id: productJson['id'] ?? '',
      title: productJson['title'] ?? '',
      category: productJson['category'] ?? '',
      description: productJson['description'] ?? productJson['description_en'] ?? '',
      descriptionAr: productJson['description_ar'] ?? '',
      descriptionEn: productJson['description_en'] ?? oldDescription,
      mainImage: productJson['main_image'] ?? '',
      isDietFriendly: productJson['is_diet_friendly'] ?? false,
      isCustomizable: productJson['is_customizable'] ?? false,
      options: (productJson['options'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                AdminProductOption.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      variants: (productJson['variants'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                AdminProductVariant.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      bulkConfig: productJson['bulk_config'] == null
          ? null
          : AdminBulkConfig.fromJson(
              Map<String, dynamic>.from(productJson['bulk_config']),
            ),
      metadata: AdminProductMetadata.fromJson(
        Map<String, dynamic>.from(productJson['metadata'] ?? {}),
      ),
    );
  }
}

class AdminSaleEvent {
  final String id;
  final String productId;
  final String variantId;
  final String category;
  final double amount;
  final int quantity;
  final DateTime createdAt;

  AdminSaleEvent({
    required this.id,
    required this.productId,
    required this.variantId,
    required this.category,
    required this.amount,
    required this.quantity,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'variant_id': variantId,
      'category': category,
      'amount': amount,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AdminSaleEvent.fromJson(Map<String, dynamic> json) {
    return AdminSaleEvent(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      variantId: json['variant_id'] ?? '',
      category: json['category'] ?? '',
      amount: (json['amount'] as num? ?? 0).toDouble(),
      quantity: (json['quantity'] as num? ?? 1).toInt(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
