import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'isar_provider.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/featured_template.dart';
import 'wishlist_provider.dart';
import 'package:isar/isar.dart';

/// Provides all categories sorted by display order
final categoriesProvider = StreamProvider<List<Category>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.categorys.where().sortByDisplayOrder().watch(fireImmediately: true);
});

/// Provides featured templates for the Home Screen carousel
final featuredTemplatesProvider = StreamProvider<List<FeaturedTemplate>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.featuredTemplates.where().watch(fireImmediately: true);
});

/// Provides products filtered by section (icons, daily, gifting, specialty)
final productsBySectionProvider = StreamProvider.family<List<Product>, String>((ref, section) {
  final isar = ref.watch(isarProvider);
  return isar.products.filter().sectionEqualTo(section).watch(fireImmediately: true);
});

/// Provides a single product by its remote ID
final productByIdProvider = FutureProvider.family<Product?, String>((ref, id) async {
  final isar = ref.watch(isarProvider);
  return await isar.products.filter().remoteIdEqualTo(id).findFirst();
});

/// Provides multiple products by their remote IDs (for collections)
final productsByIdsProvider = FutureProvider.family<List<Product>, List<String>>((ref, ids) async {
  final isar = ref.watch(isarProvider);
  if (ids.isEmpty) return [];
  
  // Isar doesn't have a native 'anyOf' for list of strings easily without multiple filters
  // but we can just find all and filter in memory since collections are small (max 5-10)
  final all = await isar.products.where().findAll();
  return all.where((p) => ids.contains(p.remoteId)).toList();
});

/// Provides products currently in the user's wishlist
final wishlistProductsProvider = StreamProvider<List<Product>>((ref) {
  final wishlistIds = ref.watch(wishlistProvider);
  if (wishlistIds.isEmpty) return Stream.value([]);
  
  final isar = ref.watch(isarProvider);
  // Watch all products and filter locally for maximum reactivity without flashing
  return isar.products.where().watch(fireImmediately: true).map((all) {
    return all.where((p) => wishlistIds.contains(p.remoteId)).toList();
  });
});

