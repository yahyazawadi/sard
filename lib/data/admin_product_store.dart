import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img_pkg;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/admin_product_model.dart';
import '../services/cloudflare_product_api.dart';

class AdminProductProvider extends ChangeNotifier {
  static const String _productsKey = 'admin_products';
  static const String _totalRevenueKey = 'admin_total_revenue';
  static const String _revenueByCategoryKey = 'admin_revenue_by_category';
  static const String _customizationTrendsKey = 'admin_customization_trends';
  static const String _salesEventsKey = 'admin_sales_events';
  static const String _featuredSectionsKey = 'admin_featured_sections';

  final List<AdminProductModel> products = [];

  double totalRevenue = 0;

  final Map<String, double> revenueByCategory = {};

  final Map<String, int> customizationTrends = {};

  final List<AdminSaleEvent> salesEvents = [];
  final List<AdminFeaturedSection> featuredSections = [];

  final CloudflareProductApi _api = CloudflareProductApi();

  bool backendSyncEnabled = true;
  String? lastBackendError;

  AdminProductProvider() {
    loadData();
  }

  double get dailyRevenue {
    final now = DateTime.now();

    return salesEvents
        .where(
          (event) =>
              event.createdAt.year == now.year &&
              event.createdAt.month == now.month &&
              event.createdAt.day == now.day,
        )
        .fold(0, (sum, event) => sum + event.amount);
  }

  double get weeklyRevenue {
    final now = DateTime.now();

    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    return salesEvents
        .where(
          (event) =>
              event.createdAt.isAfter(startOfWeek) ||
              event.createdAt.isAtSameMomentAs(startOfWeek),
        )
        .fold(0, (sum, event) => sum + event.amount);
  }

  double get monthlyRevenue {
    final now = DateTime.now();

    return salesEvents
        .where(
          (event) =>
              event.createdAt.year == now.year &&
              event.createdAt.month == now.month,
        )
        .fold(0, (sum, event) => sum + event.amount);
  }

  double get totalInventoryKg {
    double totalGrams = 0;

    for (final product in products) {
      for (final variant in product.variants) {
        totalGrams += variant.weightG * variant.stockQuantity;
      }
    }

    return totalGrams / 1000;
  }

  int get totalVariants {
    int count = 0;

    for (final product in products) {
      count += product.variants.length;
    }

    return count;
  }

  int get activeVariants {
    int count = 0;

    for (final product in products) {
      count += product.variants
          .where((variant) => variant.stockQuantity > 0)
          .length;
    }

    return count;
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final productsJson = prefs.getString(_productsKey);
    final revenueByCategoryJson = prefs.getString(_revenueByCategoryKey);
    final customizationTrendsJson = prefs.getString(_customizationTrendsKey);
    final salesEventsJson = prefs.getString(_salesEventsKey);

    totalRevenue = prefs.getDouble(_totalRevenueKey) ?? 0;

    products.clear();

    if (productsJson != null && productsJson.isNotEmpty) {
      final decodedProducts = jsonDecode(productsJson) as List<dynamic>;

      products.addAll(
        decodedProducts.map(
          (item) => AdminProductModel.fromJson(Map<String, dynamic>.from(item)),
        ),
      );
    }

    revenueByCategory.clear();

    if (revenueByCategoryJson != null && revenueByCategoryJson.isNotEmpty) {
      final decodedRevenue =
          jsonDecode(revenueByCategoryJson) as Map<String, dynamic>;

      decodedRevenue.forEach((key, value) {
        revenueByCategory[key] = (value as num).toDouble();
      });
    }

    customizationTrends.clear();

    if (customizationTrendsJson != null && customizationTrendsJson.isNotEmpty) {
      final decodedTrends =
          jsonDecode(customizationTrendsJson) as Map<String, dynamic>;

      decodedTrends.forEach((key, value) {
        customizationTrends[key] = (value as num).toInt();
      });
    }

    salesEvents.clear();

    if (salesEventsJson != null && salesEventsJson.isNotEmpty) {
      final decodedSalesEvents = jsonDecode(salesEventsJson) as List<dynamic>;

      salesEvents.addAll(
        decodedSalesEvents.map(
          (item) => AdminSaleEvent.fromJson(Map<String, dynamic>.from(item)),
        ),
      );
    }

    final featuredSectionsJson = prefs.getString(_featuredSectionsKey);
    featuredSections.clear();
    if (featuredSectionsJson != null && featuredSectionsJson.isNotEmpty) {
      final decodedFeatured = jsonDecode(featuredSectionsJson) as List<dynamic>;
      featuredSections.addAll(
        decodedFeatured.map(
          (item) => AdminFeaturedSection.fromJson(Map<String, dynamic>.from(item)),
        ),
      );
    }

    notifyListeners();

    if (!backendSyncEnabled) {
      return;
    }

    try {
      final backendProducts = await _api.getProducts();

      lastBackendError = null;

      if (backendProducts.isNotEmpty) {
        products
          ..clear()
          ..addAll(backendProducts);
        await saveData();
      }

      notifyListeners();
    } catch (error) {
      lastBackendError = error.toString();
      notifyListeners();
    }
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    final productsJson = jsonEncode(
      products.map((product) => product.toJson()).toList(),
    );

    final salesEventsJson = jsonEncode(
      salesEvents.map((event) => event.toJson()).toList(),
    );

    await prefs.setString(_productsKey, productsJson);
    await prefs.setDouble(_totalRevenueKey, totalRevenue);
    await prefs.setString(_revenueByCategoryKey, jsonEncode(revenueByCategory));
    await prefs.setString(
      _customizationTrendsKey,
      jsonEncode(customizationTrends),
    );
    await prefs.setString(_salesEventsKey, salesEventsJson);

    final featuredJson = jsonEncode(
      featuredSections.map((s) => s.toJson()).toList(),
    );
    await prefs.setString(_featuredSectionsKey, featuredJson);
  }

  Future<void> addProduct(AdminProductModel product) async {
    products.add(product);
    await saveData();
    notifyListeners();

    if (!backendSyncEnabled) {
      return;
    }

    try {
      await _api.createProduct(product);
      lastBackendError = null;
      notifyListeners();
    } catch (error) {
      lastBackendError = error.toString();
      notifyListeners();
    }
  }

  Future<void> updateProduct({
    required AdminProductModel oldProduct,
    required AdminProductModel newProduct,
  }) async {
    final index = products.indexOf(oldProduct);

    if (index == -1) {
      return;
    }

    products[index] = newProduct;
    await saveData();
    notifyListeners();

    if (!backendSyncEnabled) {
      return;
    }

    try {
      await _api.updateProduct(newProduct);
      lastBackendError = null;
      notifyListeners();
    } catch (error) {
      lastBackendError = error.toString();
      notifyListeners();
    }
  }

  Future<void> deleteProduct(AdminProductModel product) async {
    products.remove(product);
    await saveData();
    notifyListeners();

    if (!backendSyncEnabled) {
      return;
    }

    try {
      await _api.deleteProduct(product.id);
      lastBackendError = null;
      notifyListeners();
    } catch (error) {
      lastBackendError = error.toString();
      notifyListeners();
    }
  }



  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_productsKey);
    await prefs.remove(_totalRevenueKey);
    await prefs.remove(_revenueByCategoryKey);
    await prefs.remove(_customizationTrendsKey);
    await prefs.remove(_salesEventsKey);

    products.clear();
    totalRevenue = 0;
    revenueByCategory.clear();
    customizationTrends.clear();
    salesEvents.clear();

    notifyListeners();
  }

  Future<void> addFeaturedSection(AdminFeaturedSection section) async {
    featuredSections.add(section);
    await saveData();
    notifyListeners();
  }

  Future<void> updateFeaturedSection(AdminFeaturedSection section) async {
    final index = featuredSections.indexWhere((s) => s.id == section.id);
    if (index != -1) {
      featuredSections[index] = section;
      await saveData();
      notifyListeners();
    }
  }

  Future<void> deleteFeaturedSection(String id) async {
    featuredSections.removeWhere((s) => s.id == id);
    await saveData();
    notifyListeners();
  }

  Future<void> optimizeToWebP(AdminProductModel product) async {
    try {
      // 1. Optimize Main Image
      String newMainImage = product.mainImage;
      if (newMainImage.isNotEmpty && !newMainImage.contains('.webp')) {
        newMainImage = await _optimizeSingleImage(product.mainImage, 'main_${product.id}');
      }

      // 2. Optimize Variant Images
      List<AdminProductVariant> newVariants = [];
      for (var variant in product.variants) {
        String? newVariantImage = variant.image;
        if (newVariantImage != null && 
            newVariantImage.isNotEmpty && 
            !newVariantImage.contains('.webp')) {
          newVariantImage = await _optimizeSingleImage(newVariantImage, 'variant_${product.id}_${variant.id}');
        }
        newVariants.add(variant.copyWith(image: newVariantImage));
      }

      // 3. Update the product in backend
      final updatedProduct = product.copyWith(
        mainImage: newMainImage,
        variants: newVariants,
      );
      await updateProduct(oldProduct: product, newProduct: updatedProduct);
      
      notifyListeners();
    } catch (e) {
      lastBackendError = 'Optimization failed: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<String> _optimizeSingleImage(String url, String namePrefix) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image from $url');
      }
      
      // Decode image using pure Dart (no native dependency)
      final image = img_pkg.decodeImage(response.bodyBytes);
      if (image == null) {
        throw Exception('Failed to decode image data from $url');
      }

      Uint8List finalBytes;
      String extension;

      // The `image` package does NOT have a WebP encoder, only a decoder.
      // So we must use JPG for compression, but PNG if the image needs transparency.
      if (image.hasAlpha) {
        // Keep as PNG to preserve transparent backgrounds
        finalBytes = Uint8List.fromList(img_pkg.encodePng(image));
        extension = 'png';
      } else {
        // Compress as JPG (quality 85 is a good balance of size and quality)
        finalBytes = Uint8List.fromList(img_pkg.encodeJpg(image, quality: 85));
        extension = 'jpg';
      }

      final fileName = '${namePrefix}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      return await _api.uploadImageBytes(
        bytes: finalBytes,
        filename: fileName,
      );
    } catch (e) {
      throw Exception('Error optimizing $namePrefix: $e');
    }
  }
}
