import 'package:isar/isar.dart';

part 'product.g.dart';

@collection
class Product {
  Product();

  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String remoteId; // e.g., 'colored_box'

  late String section; // icons, daily, gifting, specialty
  
  late String nameAr;
  late String nameEn;
  late String imageUrl;
  
  List<ProductVariant>? variants;

  // The Master Toggles
  late bool hasVariants; // Controls S/M/L visibility
  late bool isGendered; // Controls Boy/Girl visibility
  late bool isCustomizable; // Controls filling grid visibility
  late bool isSoldByWeight; // Controls kg logic vs pieces logic
  late bool isFixedPrice; // Controls Total bar visibility
  late bool isContactOnly; // Controls Cart button visibility

  // Additional Data
  List<String>? genderOptions;
  String? unit; // kg, box, etc.
  String? gender; // boy, girl, etc.
  
  // Stock per branch
  BranchStock? branchStock;

  late DateTime lastUpdated;

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
      ..remoteId = json['remoteId']
      ..section = json['section']
      ..nameAr = json['nameAr']
      ..nameEn = json['nameEn']
      ..imageUrl = json['imageUrl']
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
