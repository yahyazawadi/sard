import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../routes/app_routes.dart';
import '../custom/app_theme.dart';
import '../models/cart_item.dart';
import '../utils/snackbar_utils.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CartItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Remove Item?",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            content: Text(
              "Are you sure you want to remove '${item.product.nameEn}' from your cart?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "CANCEL",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  "REMOVE",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      ref.read(cartProvider.notifier).removeItemById(item.id);
      if (context.mounted) {
        SardSnackBar.show(context, "${item.product.nameEn} removed from cart");
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    final subtotal = cartItems.fold(
      0.0,
      (sum, item) => sum + (item.variant.price * item.quantity),
    );
    final total = subtotal + 5.0; // Shipping included
    final totalItems = cartItems.fold(0, (sum, item) => sum + item.quantity);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
          ),
          title: Text('My Cart', style: Theme.of(context).textTheme.titleLarge),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        size: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () => context.push(AppRoutes.checkout),
            ),
          ],
        ),
        body:
            cartItems.isEmpty
                ? Center(
                  child: Text(
                    "Your cart is empty",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$totalItems Items",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    item.product.imageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.product.nameEn,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              size: 18,
                                              color: Colors.grey,
                                            ),
                                            onPressed:
                                                () => _confirmDelete(
                                                  context,
                                                  ref,
                                                  item,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        item.variant.size,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "₪ ${item.variant.price.toStringAsFixed(2)}",
                                            style: TextStyle(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.remove,
                                                    size: 16,
                                                  ),
                                                  onPressed:
                                                      () => cartNotifier
                                                          .updateQuantity(
                                                            item.id,
                                                            item.quantity - 1,
                                                          ),
                                                ),
                                                Text(
                                                  "${item.quantity}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.add,
                                                    size: 16,
                                                  ),
                                                  onPressed:
                                                      () => cartNotifier
                                                          .updateQuantity(
                                                            item.id,
                                                            item.quantity + 1,
                                                          ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Subtotal",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "₪ ${subtotal.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Shipping",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "₪ 5.00",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "₪ ${total.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => context.push(AppRoutes.checkout),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.buttonRadius,
                                  ),
                                  side: BorderSide(
                                    color: colorScheme.tertiary,
                                    width: 2,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Go To Payment",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
