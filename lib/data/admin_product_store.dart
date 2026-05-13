import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/admin_product_model.dart';
import '../services/cloudflare_product_api.dart';

class AdminProductProvider extends ChangeNotifier {
  static const String _productsKey = 'admin_products';
  static const String _totalRevenueKey = 'admin_total_revenue';
  static const String _revenueByCategoryKey = 'admin_revenue_by_category';
  static const String _customizationTrendsKey = 'admin_customization_trends';
  static const String _salesEventsKey = 'admin_sales_events';

  final List<AdminProductModel> products = [];

  double totalRevenue = 0;

  final Map<String, double> revenueByCategory = {};

  final Map<String, int> customizationTrends = {};

  final List<AdminSaleEvent> salesEvents = [];

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

  Future<bool> purchaseVariant({
    required AdminProductModel product,
    required AdminProductVariant variant,
  }) async {
    final productIndex = products.indexWhere((item) => item.id == product.id);

    if (productIndex == -1) {
      return false;
    }

    final storedProduct = products[productIndex];
    final variantIndex = storedProduct.variants.indexWhere(
      (item) => item.id == variant.id,
    );

    if (variantIndex == -1) {
      return false;
    }

    final storedVariant = storedProduct.variants[variantIndex];

    if (storedVariant.stockQuantity <= 0) {
      return false;
    }

    storedVariant.stockQuantity -= 1;

    totalRevenue += storedVariant.price;

    salesEvents.add(
      AdminSaleEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        productId: storedProduct.id,
        variantId: storedVariant.id,
        category: storedProduct.category,
        amount: storedVariant.price,
        quantity: 1,
        createdAt: DateTime.now(),
      ),
    );

    revenueByCategory[storedProduct.category] =
        (revenueByCategory[storedProduct.category] ?? 0) + storedVariant.price;

    if (storedProduct.isCustomizable ||
        storedProduct.category == 'bulk' ||
        storedProduct.category == 'mix') {
      final key = storedVariant.attributes.isNotEmpty
          ? storedVariant.attributes.entries
                .map((entry) => '${entry.key}: ${entry.value}')
                .join(' | ')
          : storedVariant.title;

      customizationTrends[key] = (customizationTrends[key] ?? 0) + 1;
    }

    await saveData();
    notifyListeners();

    if (!backendSyncEnabled) {
      return true;
    }

    try {
      final updatedProduct = await _api.purchase(
        productId: product.id,
        variantId: variant.id,
        quantity: 1,
      );

      final localProductIndex = products.indexWhere(
        (item) => item.id == updatedProduct.id,
      );

      if (localProductIndex != -1) {
        products[localProductIndex] = updatedProduct;
        await saveData();
      }

      lastBackendError = null;
      notifyListeners();
    } catch (error) {
      lastBackendError = error.toString();
      notifyListeners();
    }

    return true;
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
}
