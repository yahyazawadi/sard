import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../providers/catalog_provider.dart';
import '../providers/cart_provider.dart';
import '../custom/app_theme.dart';
import 'product_detail_screen.dart';
import '../l10n/app_localizations.dart';

class ProductDetailLoader extends ConsumerWidget {
  final String productId;
  final CartItem? editingItem;
  final String? cartItemId;

  const ProductDetailLoader({
    super.key,
    required this.productId,
    this.editingItem,
    this.cartItemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));
    final cart = ref.watch(cartProvider);
    
    // Try to find the item if we have an ID but no object
    CartItem? recoveredItem = editingItem;
    if (recoveredItem == null && cartItemId != null) {
      try {
        recoveredItem = cart.firstWhere((item) => item.id == cartItemId);
      } catch (_) {
        // Not found
      }
    }

    return productAsync.when(
      data: (product) {
        if (product == null) {
          return Scaffold(
            body: Center(child: Text(AppLocalizations.of(context)!.productNotFound)),
          );
        }
        return ProductDetailScreen(
          product: product,
          editingItem: recoveredItem,
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.gradientStart,
          ),
        ),
      ),
      error: (e, s) => Scaffold(
        body: Center(child: Text(AppLocalizations.of(context)!.errorLoading(e.toString()))),
      ),
    );
  }
}
