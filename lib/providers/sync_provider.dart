import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'isar_provider.dart';
import '../models/category.dart';
import '../models/filling.dart';
import '../models/product.dart';
import '../models/featured_template.dart';
import 'dart:convert';
import 'package:flutter/widgets.dart'; // For debugPrint
import 'package:http/http.dart' as http;

final syncProvider = Provider((ref) => SyncEngine(ref));


class SyncEngine {
  final Ref ref;
  SyncEngine(this.ref);

  Isar get isar => ref.read(isarProvider);

  Future<void> performInitialSeed({bool forceRemote = false}) async {
    try {
      await isar.writeTxn(() async {
        await isar.categorys.clear();
        await isar.products.clear();
        await isar.featuredTemplates.clear();
      });

      final List<dynamic> allProductsRaw = [];
      final List<dynamic> allFeaturedRaw = [];

      try {
        final response = await http.get(Uri.parse('https://sard-products-api.s12219814.workers.dev/products')).timeout(const Duration(seconds: 10));
        debugPrint('!!! SyncEngine: Cloudflare Response: ${response.statusCode}');
        if (response.statusCode == 200) {
          final dynamic data = json.decode(response.body);
          if (data is List) {
            allProductsRaw.addAll(data);
            debugPrint('!!! SyncEngine: Data is List. Products: ${allProductsRaw.length}');
          } else if (data is Map) {
            debugPrint('!!! SyncEngine: Data is Map. Keys: ${data.keys.toList()}');
            if (data['products'] != null) {
              allProductsRaw.addAll(data['products']);
            }
            // Check for featured sections in multiple common keys
            final featuredKeys = ['featured_sections', 'featured', 'featuredSections', 'sections'];
            for (final key in featuredKeys) {
              if (data[key] != null && data[key] is List) {
                allFeaturedRaw.addAll(data[key]);
                debugPrint('!!! SyncEngine: Found featured sections in key: $key');
                break;
              }
            }
          }
          
          // Fallback: search for featured_sections in a list if it was a list or Map failed to find them
          if (allFeaturedRaw.isEmpty) {
            final listToSearch = data is List ? data : (data is Map && data['products'] is List ? data['products'] : []);
            for (var item in listToSearch) {
              if (item is Map && (item.containsKey('featured_sections') || item.containsKey('featured'))) {
                final f = item['featured_sections'] ?? item['featured'];
                if (f is List) {
                  allFeaturedRaw.addAll(f);
                  debugPrint('!!! SyncEngine: Found featured sections NESTED in products list');
                  break;
                }
              }
            }
          }

          // HARDCODED FALLBACK (from USER provided JSON)
          if (allFeaturedRaw.isEmpty) {
            debugPrint('!!! SyncEngine: Using hardcoded fallback for featured sections');
            allFeaturedRaw.add({
              "id": "1778889640250",
              "title_ar": "اختيارنا",
              "title_en": "our choice",
              "image_url": "https://sard-products-api.s12219814.workers.dev/images/products/1778889612420-09509e81-dates.png",
              "product_ids": [
                "1778797715220_943200",
                "1778881980187_704154",
                "1778869234463_114441"
              ]
            });
          }
          debugPrint('!!! SyncEngine: Extracted ${allProductsRaw.length} products and ${allFeaturedRaw.length} featured sections');
        } else {
          debugPrint('!!! SyncEngine: Cloudflare fetch failed with status: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('!!! SyncEngine: Cloudflare fetch failed: $e');
      }

      // Remove local fallbacks to ensure we are strictly using Cloudflare data
      if (allProductsRaw.isEmpty) {
        debugPrint('!!! SyncEngine: No products found on Cloudflare. Not falling back to local data to avoid legacy categories.');
      }

      // 1. Process Products
      final products = allProductsRaw.map((rawItem) {
        final item = rawItem is Map && rawItem.containsKey('product') ? rawItem['product'] : rawItem;
        debugPrint('!!! SyncEngine: Processing item: ${item['id']}');
        final p = Product()
          ..remoteId = item['id'] ?? ''
          ..section = item['category'] ?? item['section'] ?? 'other'
          ..nameAr = item['title_ar'] ?? item['name']?['ar'] ?? item['name_ar'] ?? ''
          ..nameEn = item['title_en'] ?? item['title'] ?? item['name']?['en'] ?? item['name_en'] ?? ''
          ..descriptionAr = item['description_ar'] ?? ''
          ..descriptionEn = item['description_en'] ?? item['description'] ?? ''
          ..imageUrl = item['main_image'] ?? item['image_url'] ?? 'assets/images/allchocolatetype3to2.jpg'
          ..hasVariants = (item['variants'] as List?)?.isNotEmpty ?? false
          ..isGendered = item['gender'] != null || item['gender_options'] != null || item['is_gendered'] == true
          ..isCustomizable = item['is_customizable'] ?? item['fillings_enabled'] ?? false
          ..isSoldByWeight = item['category'] == 'bulk' || item['unit'] == 'kg' || item['is_sold_by_weight'] == true
          ..isFixedPrice = item['is_fixed_price'] ?? (item['variants'] == null || (item['variants'] as List).isEmpty)
          ..isContactOnly = item['is_contact_only'] ?? false
          ..isDietFriendly = item['is_diet_friendly'] ?? false
          ..isNew = item['is_new'] ?? false
          ..unit = item['unit']
          ..gender = item['gender']
          ..lastUpdated = DateTime.now();

        if (item['variants'] != null && (item['variants'] as List).isNotEmpty) {
          p.variants = (item['variants'] as List).map((v) {
            final attrs = v['attributes'];
            String? sizeVal;
            String? typeVal;
            
            if (attrs is Map) {
              final lowerCaseAttrs = attrs.map((k, v) => MapEntry(k.toString().toLowerCase(), v));
              sizeVal = lowerCaseAttrs['size']?.toString();
              typeVal = lowerCaseAttrs['type']?.toString() ?? 
                        lowerCaseAttrs['flavor']?.toString() ?? 
                        lowerCaseAttrs['chocolate type']?.toString();
            } else if (attrs is List) {
              for (var attr in attrs) {
                if (attr is Map) {
                  final name = attr['name']?.toString().toLowerCase();
                  final val = attr['value']?.toString();
                  if (name == 'size') sizeVal = val;
                  if (name == 'type' || name == 'flavor' || name == 'chocolate type') typeVal = val;
                }
              }
            }

            return ProductVariant()
              ..size = sizeVal ?? v['title'] ?? v['label'] ?? 'Default'
              ..type = typeVal
              ..price = (v['price'] as num?)?.toDouble() ?? 0.0
              ..pieces = v['piece_count'] ?? v['pieces']
              ..imageUrl = v['image']?.toString() ?? v['image_url']?.toString()
              ..prefilledMixJson = v['prefilled_mix'] != null ? json.encode(v['prefilled_mix']) : null;
          }).toList();
        } else if (item['price'] != null) {
          p.variants = [ProductVariant()..size = 'Default'..price = (item['price'] as num).toDouble()];
        } else {
          p.variants = [];
        }

        if (item['bulk_config'] != null) {
          final bc = item['bulk_config'];
          if (bc['boxes'] != null) {
            p.bulkBoxes = (bc['boxes'] as List).map((b) => BulkBox()
              ..name = b['title_en'] ?? b['name'] ?? ''
              ..price = (b['price'] as num?)?.toDouble() ?? 0.0
              ..pieceCount = (b['weight_g'] as num?)?.toInt() ?? 0
            ).toList();
          }
          if (bc['pre_made_templates'] != null) {
            p.preMadeTemplates = (bc['pre_made_templates'] as List).map((t) => PreMadeTemplate.fromJson(t)).toList();
          }
        }

        if (item['branch_stock'] != null) {
          final stock = item['branch_stock'];
          p.branchStock = BranchStock()..nablus = stock['nablus']..bethlehem = stock['bethlehem']..ramallah = stock['ramallah'];
        }
        return p;
      }).toList();

      // 2. Process Featured
      debugPrint('!!! SyncEngine: Processing ${allFeaturedRaw.length} raw featured sections');
      final featured = allFeaturedRaw.map((item) {
        final remoteId = item['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
        debugPrint('!!! SyncEngine: Mapping featured: $remoteId');
        return FeaturedTemplate()
          ..remoteId = remoteId
          ..titleEn = item['title_en'] ?? item['title'] ?? ''
          ..titleAr = item['title_ar'] ?? ''
          ..title = item['title_en'] ?? item['title'] ?? ''
          ..subtitle = item['description_en'] ?? item['subtitle'] ?? ''
          ..bannerUrl = item['image_url'] ?? item['banner_url'] ?? item['image'] ?? ''
          ..productIds = item['product_ids'] != null ? List<String>.from(item['product_ids']) : [];
      }).toList();

      // 3. Dynamically Generate Categories from Products
      final uniqueSections = products.map((p) => p.section).toSet().toList();
      
      // Sort: 'bulk' first, then others alphabetically
      uniqueSections.sort((a, b) {
        if (a.toLowerCase() == 'bulk') return -1;
        if (b.toLowerCase() == 'bulk') return 1;
        return a.compareTo(b);
      });

      final List<Category> categories = [];
      int order = 0;
      for (final sec in uniqueSections) {
        if (sec.isEmpty) continue;
        
        // Try to find a nice name
        String nameEn = sec[0].toUpperCase() + sec.substring(1);
        String nameAr = sec;
        
        // Manual mapping for common ones if we want better names
        switch (sec.toLowerCase()) {
          case 'icons': nameAr = 'أيقونات'; break;
          case 'daily': nameAr = 'يومي'; break;
          case 'gifting': nameAr = 'هدايا'; break;
          case 'specialty': nameAr = 'تخصص'; break;
          case 'bulk': nameAr = 'بالكيلو'; break;
          case 'bars': nameAr = 'ألواح'; break;
          case 'spoons': nameAr = 'ملاعق'; break;
          case 'truffles': nameAr = 'ترايفل'; break;
          case 'box': nameAr = 'صناديق'; break;
          case 'collections': nameAr = 'مجموعات'; break;
          case 'specials': nameAr = 'عروض خاصة'; break;
          case 'new-arrivals': nameAr = 'وصل حديثاً'; break;
          case 'accessories': nameAr = 'إكسسوارات'; break;
        }

        categories.add(Category()
          ..remoteId = sec
          ..nameEn = nameEn
          ..nameAr = nameAr
          ..imageUrl = '' // We can't really guess this, but we can use first product's image as fallback
          ..displayOrder = order++);
      }
      
      // Attempt to get icons/images for categories from a static map or first product
      for (var cat in categories) {
        try {
          final firstProd = products.firstWhere((p) => p.section == cat.remoteId);
          cat.imageUrl = firstProd.imageUrl;
        } catch (_) {}
      }

      await isar.writeTxn(() async {
        await isar.products.putAll(products);
        await isar.featuredTemplates.putAll(featured);
        await isar.categorys.putAll(categories);
      });

      debugPrint('!!! SyncEngine: Seeding complete. Products: ${products.length}, Categories: ${categories.length}, Featured: ${featured.length}');
      if (products.isEmpty) {
        debugPrint('!!! SyncEngine WARNING: No products were found! Screen will be empty.');
      }
    } catch (e) {
      debugPrint('!!! SyncEngine: Error during seed: $e');
    }
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
