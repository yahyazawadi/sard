import 'dart:convert';
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
  String descriptionAr = '';
  String descriptionEn = '';
  String imageUrl = '';

  List<ProductVariant>? variants;

  // The Master Toggles
  bool hasVariants = false;
  bool isGendered = false;
  bool isCustomizable = false;
  bool isSoldByWeight = false;
  bool isFixedPrice = false;
  bool isContactOnly = false;
  bool isDietFriendly = false;
  bool isNew = false;

  // Additional Data
  List<String>? genderOptions;
  String? unit;
  String? gender;

  // Bulk / Box config (from Cloudflare bulk_config)
  List<BulkBox>? bulkBoxes;
  List<PreMadeTemplate>? preMadeTemplates;

  // Stock per branch
  BranchStock? branchStock;

  DateTime lastUpdated = DateTime.now();

  /// True when this product uses bulk_config boxes instead of classic variants
  @ignore
  bool get isBulkProduct => bulkBoxes != null && bulkBoxes!.isNotEmpty;

  String getName(String languageCode) {
    if (languageCode == 'ar' && nameAr.isNotEmpty) return nameAr;
    return nameEn;
  }

  String getDescription(String languageCode) {
    if (languageCode == 'ar' && descriptionAr.isNotEmpty) return descriptionAr;
    return descriptionEn;
  }

  String getSection(String languageCode) {
    if (languageCode == 'ar') {
      switch (section.toLowerCase()) {
        case 'daily': return 'يومي';
        case 'gifting': return 'هدايا';
        case 'specialty': return 'تخصص';
        case 'whole': return 'كاملة';
        case 'traditional': return 'تقليدي';
        case 'bulk': return 'بالكيلو';
        default: return section;
      }
    }
    return section;
  }

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
      'isDietFriendly': isDietFriendly,
      'isNew': isNew,
      'genderOptions': genderOptions,
      'unit': unit,
      'gender': gender,
      'bulkBoxes': bulkBoxes?.map((b) => b.toJson()).toList(),
      'preMadeTemplates': preMadeTemplates?.map((t) => t.toJson()).toList(),
      'branchStock': branchStock?.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final product = Product()
      ..remoteId = json['remoteId'] ?? json['id'] ?? ''
      ..section = json['section'] ?? json['category'] ?? ''
      ..nameAr = json['nameAr'] ?? json['title_ar'] ?? ''
      ..nameEn = json['nameEn'] ?? json['title_en'] ?? json['title'] ?? ''
      ..descriptionAr = json['description_ar'] ?? json['descriptionAr'] ?? ''
      ..descriptionEn = json['description_en'] ?? json['descriptionEn'] ?? json['description'] ?? ''
      ..imageUrl = json['imageUrl'] ?? json['image_url'] ?? json['main_image'] ?? ''
      ..hasVariants = json['hasVariants'] ?? false
      ..isGendered = json['isGendered'] ?? false
      ..isCustomizable = (json['is_customizable'] ?? json['isCustomizable']) == true
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

    // Parse classic variants
    if (json['variants'] != null && (json['variants'] as List).isNotEmpty) {
      product.variants = (json['variants'] as List)
          .map((v) => ProductVariant.fromJson(v))
          .toList();
    }

    // Parse bulk_config
    final bulkConfig = json['bulk_config'];
    if (bulkConfig != null) {
      if (bulkConfig['boxes'] != null) {
        product.bulkBoxes = (bulkConfig['boxes'] as List)
            .map((b) => BulkBox.fromJson(b))
            .toList();
      }
      if (bulkConfig['pre_made_templates'] != null) {
        product.preMadeTemplates = (bulkConfig['pre_made_templates'] as List)
            .map((t) => PreMadeTemplate.fromJson(t))
            .toList();
      }
    }

    return product;
  }
}

// ────────────────────────────────────────────────
// Classic Variant (Small / Medium / Large boxes with piece count)
// ────────────────────────────────────────────────

@embedded
class ProductVariant {
  ProductVariant();

  String size = 'Default'; // Small, Medium, Large, or Default
  String? type; // e.g., Milk, Dark, White
  double price = 0.0;
  int? pieces;
  String? prefilledMixJson;
  String? imageUrl;

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'type': type,
      'price': price,
      'pieces': pieces,
      'prefilledMixJson': prefilledMixJson,
      'imageUrl': imageUrl,
    };
  }

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant()
      ..size = json['size'] ?? json['label'] ?? 'Default'
      ..type = json['type']
      ..price = (json['price'] as num?)?.toDouble() ?? 0.0
      ..pieces = json['pieces'] ?? json['piece_count']
      ..prefilledMixJson = json['prefilledMixJson']
      ..imageUrl = json['imageUrl'] ?? json['image_url'];
  }
}

// ────────────────────────────────────────────────
// Bulk Box (weight-based box config from Cloudflare)
// ────────────────────────────────────────────────

@embedded
class BulkBox {
  BulkBox();

  String name = '';
  int pieceCount = 0;
  double price = 0.0;



  Map<String, dynamic> toJson() => {
        'name': name,
        'pieceCount': pieceCount,
        'price': price,
      };

  factory BulkBox.fromJson(Map<String, dynamic> json) {
    return BulkBox()
      ..name = json['name'] ?? json['title_en'] ?? json['titleEn'] ?? ''
      ..pieceCount = (json['piece_count'] ?? json['pieceCount'] ?? 0).toInt()
      ..price = (json['price'] as num?)?.toDouble() ?? 0.0;
  }
}

// ────────────────────────────────────────────────
// Pre-Made Template (e.g. "Whole Dark 70%")
// ────────────────────────────────────────────────

@embedded
class PreMadeTemplate {
  PreMadeTemplate();

  String nameEn = '';
  String nameAr = '';

  /// JSON-encoded map of partition key to TemplatePartition
  /// (stored as string because Isar doesn't support nested Map objects)
  String? partitionsJson;

  String getName(String lang) {
    if (lang == 'ar' && nameAr.isNotEmpty) return nameAr;
    return nameEn;
  }

  Map<String, dynamic> toJson() => {
        'nameEn': nameEn,
        'nameAr': nameAr,
        'partitionsJson': partitionsJson,
      };

  factory PreMadeTemplate.fromJson(Map<String, dynamic> json) {
    final t = PreMadeTemplate()
      ..nameEn = json['name_en'] ?? json['nameEn'] ?? json['name'] ?? ''
      ..nameAr = json['name_ar'] ?? json['nameAr'] ?? '';

    if (json['partitions'] != null) {
      final partitionsMap = json['partitions'] as Map<String, dynamic>;
      final entries = <Map<String, dynamic>>[];
      partitionsMap.forEach((key, value) {
        entries.add({
          'key': key,
          'nameEn': value['name_en'] ?? value['nameEn'] ?? key,
          'nameAr': value['name_ar'] ?? value['nameAr'] ?? key,
          'ratio': (value['ratio'] as num?)?.toDouble() ?? 1.0,
          'items': value['items'] ?? [],
        });
      });
      t.partitionsJson = jsonEncode(entries);
    }

    return t;
  }

  /// Decode the stored partitions back into a usable list
  @ignore
  List<Map<String, dynamic>> get partitions {
    if (partitionsJson == null || partitionsJson!.isEmpty) return [];
    try {
      final decoded = jsonDecode(partitionsJson!);
      if (decoded is List) return decoded.cast<Map<String, dynamic>>();
    } catch (_) {}
    return [];
  }
}

// ────────────────────────────────────────────────
// Branch Stock
// ────────────────────────────────────────────────

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


