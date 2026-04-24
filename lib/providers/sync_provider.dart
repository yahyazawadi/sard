import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'isar_provider.dart';
import '../models/category.dart';
import '../models/filling.dart';
import '../models/product.dart';
import '../models/featured_template.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart'; // For debugPrint

final syncProvider = Provider((ref) => SyncEngine(ref));


class SyncEngine {
  final Ref ref;
  SyncEngine(this.ref);

  Isar get isar => ref.read(isarProvider);

  Future<void> performInitialSeed() async {
    debugPrint('!!! SyncEngine: Starting manual seed...');

    await isar.writeTxn(() async {
      // Clear existing to avoid "Unique index violated"
      await isar.categorys.clear();
      await isar.products.clear();
      await isar.featuredTemplates.clear();

      // 1. Seed Categories from JSON
      try {
        final String catJson = await rootBundle.loadString('assets/data/categories.json');
        final List<dynamic> catList = json.decode(catJson);
        final categories = catList.map((item) => Category()
          ..remoteId = item['id']
          ..nameEn = item['name_en']
          ..nameAr = item['name_ar']
          ..imageUrl = item['image_url']
          ..displayOrder = item['display_order']).toList();
        await isar.categorys.putAll(categories);
      } catch (e) {
        debugPrint('Error seeding categories: $e');
      }

      // 2. Load and Seed Featured Templates from JSON
      try {
        final String featJson = await rootBundle.loadString('assets/data/featured_enrollment.json');
        final List<dynamic> featList = json.decode(featJson);
        final featured = featList.map((item) => FeaturedTemplate()
          ..remoteId = item['id']
          ..title = item['title']
          ..subtitle = item['subtitle']
          ..bannerUrl = item['banner_url']
          ..targetProductId = item['target_product_id']
          ..preselectedVariant = item['preselected_variant']
          ..isCustomizable = item['is_customizable'] ?? true
          ..productIds = item['product_ids'] != null ? List<String>.from(item['product_ids']) : null).toList();
        await isar.featuredTemplates.putAll(featured);
      } catch (e) {
        debugPrint('Error seeding featured templates: $e');
      }

      // 3. Load and Seed Products from ALL JSON files
      final productFiles = [
        'assets/data/catalog.json',
        'assets/data/traditional_sweets.json',
        'assets/data/daily_treats.json',
        'assets/data/special_gifting.json',
        'assets/data/specialty_diet.json',
      ];

      for (final file in productFiles) {
        try {
          final String jsonStr = await rootBundle.loadString(file);
          final List<dynamic> jsonList = json.decode(jsonStr);
          final products = jsonList.map((item) {
            final p = Product()
              ..remoteId = item['id']
              ..section = item['section']
              // Handle both name formats
              ..nameAr = item['name']?['ar'] ?? item['name_ar'] ?? ''
              ..nameEn = item['name']?['en'] ?? item['name_en'] ?? ''
              ..imageUrl = item['image_url'] ?? 'assets/images/chocophoto.png'
              ..hasVariants = item['variants'] != null
              ..isGendered = item['gender'] != null || item['gender_options'] != null || item['is_gendered'] == true
              ..isCustomizable = item['fillings_enabled'] ?? item['is_customizable'] ?? false
              ..isSoldByWeight = item['unit'] == 'kg' || item['is_sold_by_weight'] == true
              ..isFixedPrice = item['is_fixed_price'] ?? (item['variants'] == null)
              ..isContactOnly = item['is_contact_only'] ?? false
              ..unit = item['unit']
              ..gender = item['gender']
              ..lastUpdated = DateTime.now();
            
            if (item['variants'] != null) {
              p.variants = (item['variants'] as List).map((v) => ProductVariant()
                ..size = v['label'] ?? v['size'] ?? 'Default'
                ..price = (v['price'] as num).toDouble()
                ..pieces = v['piece_count'] ?? v['pieces']
                ..prefilledMixJson = v['prefilled_mix'] != null ? json.encode(v['prefilled_mix']) : null
              ).toList();
            } else if (item['price'] != null) {
              p.variants = [
                ProductVariant()
                  ..size = 'Default'
                  ..price = (item['price'] as num).toDouble()
              ];
            } else {
              p.variants = [];
            }

            if (item['branch_stock'] != null) {
              final stock = item['branch_stock'];
              p.branchStock = BranchStock()
                ..nablus = stock['nablus']
                ..bethlehem = stock['bethlehem']
                ..ramallah = stock['ramallah'];
            }

            return p;
          }).toList();
          await isar.products.putAll(products);
          debugPrint('!!! SyncEngine: Successfully seeded ${products.length} products from $file');
        } catch (e) {
          debugPrint('!!! SyncEngine: Error seeding products from $file: $e');
        }
      }
      debugPrint('!!! SyncEngine: Seeding complete.');
    });
  }

  Future<void> clearAllData() async {
    await isar.writeTxn(() async {
      await isar.products.clear();
      await isar.fillings.clear();
      await isar.categorys.clear();
      await isar.featuredTemplates.clear();
    });
  }
}
