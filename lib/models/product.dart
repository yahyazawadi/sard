import 'package:isar/isar.dart';

part 'product.g.dart';

@collection
class Product {
  Product();

  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String remoteId = ''; // e.g., 'colored_box'

  String section = ''; // icons, daily, gifting, specialty
  
  String nameAr = '';
  String nameEn = '';
  String imageUrl = '';
  
  List<ProductVariant>? variants;

  // The Master Toggles
  bool hasVariants = false; 
  bool isGendered = false; 
  bool isCustomizable = false; 
  bool isSoldByWeight = false; 
  bool isFixedPrice = false; 
  bool isContactOnly = false; 

  // Additional Data
  List<String>? genderOptions;
  String? unit; 
  String? gender; 
  
  // Stock per branch
  BranchStock? branchStock;

  DateTime lastUpdated = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'remoteId': remoteId,
      'section': section,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'imageUrl': imageUrl,
      'variants': variants?.map((v) => v.toJson()).toList(),
      'hasVariants': hasVariants,
      'isGendered': isGendered,
      'isCustomizable': isCustomizable,
      'isSoldByWeight': isSoldByWeight,
      'isFixedPrice': isFixedPrice,
      'isContactOnly': isContactOnly,
      'genderOptions': genderOptions,
      'unit': unit,
      'gender': gender,
      'branchStock': branchStock?.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product()
      ..remoteId = json['remoteId'] ?? json['id'] ?? ''
      ..section = json['section'] ?? ''
      ..nameAr = json['nameAr'] ?? json['name_ar'] ?? ''
      ..nameEn = json['nameEn'] ?? json['name_en'] ?? ''
      ..imageUrl = json['imageUrl'] ?? json['image_url'] ?? ''
      ..variants = json['variants'] != null 
          ? (json['variants'] as List).map((v) => ProductVariant.fromJson(v)).toList()
          : null
      ..hasVariants = json['hasVariants'] ?? false
      ..isGendered = json['isGendered'] ?? false
      ..isCustomizable = json['isCustomizable'] ?? false
      ..isSoldByWeight = json['isSoldByWeight'] ?? false
      ..isFixedPrice = json['isFixedPrice'] ?? false
      ..isContactOnly = json['isContactOnly'] ?? false
      ..genderOptions = json['genderOptions'] != null ? List<String>.from(json['genderOptions']) : null
      ..unit = json['unit']
      ..gender = json['gender']
      ..branchStock = json['branchStock'] != null ? BranchStock.fromJson(json['branchStock']) : null
      ..lastUpdated = json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now();
  }
}

@embedded
class ProductVariant {
  ProductVariant();

  String size = 'Default'; // Small, Medium, Large, or Default
  double price = 0.0;
  int? pieces;
  String? prefilledMixJson;

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'price': price,
      'pieces': pieces,
      'prefilledMixJson': prefilledMixJson,
    };
  }

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant()
      ..size = json['size']
      ..price = json['price']
      ..pieces = json['pieces']
      ..prefilledMixJson = json['prefilledMixJson'];
  }
}

@embedded
class BranchStock {
  BranchStock();
  int? nablus;
  int? bethlehem;
  int? ramallah;

  Map<String, dynamic> toJson() {
    return {
      'nablus': nablus,
      'bethlehem': bethlehem,
      'ramallah': ramallah,
    };
  }

  factory BranchStock.fromJson(Map<String, dynamic> json) {
    return BranchStock()
      ..nablus = json['nablus']
      ..bethlehem = json['bethlehem']
      ..ramallah = json['ramallah'];
  }
}
