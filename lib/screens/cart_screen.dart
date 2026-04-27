import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../routes/app_routes.dart';
import '../custom/app_theme.dart';
import '../models/cart_item.dart';
import '../utils/snackbar_utils.dart';
import 'main_wrapper_screen.dart';
import '../widgets/sard_primary_button.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CartItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("REMOVE", style: TextStyle(color: Colors.white)),
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
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final subtotal = cartItems.fold(
      0.0,
      (sum, item) => sum + (item.variant.price * item.quantity),
    );
    final total = subtotal + 5.0;
    final totalItems = cartItems.fold(0, (sum, item) => sum + item.quantity);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          final history = ref.read(tabHistoryProvider);
          if (history.length > 1) {
            final newHistory = List<int>.from(history)..removeLast();
            ref.read(tabHistoryProvider.notifier).state = newHistory;
            ref.read(mainWrapperPageProvider.notifier).state = newHistory.last;
          } else {
            context.go(AppRoutes.home);
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            // ── App Bar (matching ProductDetailScreen style) ──
            SliverAppBar(
              pinned: true,
              backgroundColor: theme.appBarTheme.backgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.gradientStart,
                  size: 20,
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    final history = ref.read(tabHistoryProvider);
                    if (history.length > 1) {
                      final newHistory = List<int>.from(history)..removeLast();
                      ref.read(tabHistoryProvider.notifier).state = newHistory;
                      ref.read(mainWrapperPageProvider.notifier).state =
                          newHistory.last;
                    } else {
                      context.go(AppRoutes.home);
                    }
                  }
                },
              ),
              title: Text('My Cart', style: theme.textTheme.titleLarge),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_checkout,
                      color: AppTheme.gradientStart,
                      size: 26,
                    ),
                    onPressed: () => context.push(AppRoutes.checkout),
                  ),
                ),
              ],
            ),

            // ── Body ──
            if (cartItems.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Your cart is empty",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Start adding some chocolates!",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // ── Item Count Header ──
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: Text(
                      "$totalItems ${totalItems == 1 ? 'Item' : 'Items'}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Cart Items List ──
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = cartItems[index];
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(
                                  "Remove Item?",
                                  style: Theme.of(ctx).textTheme.titleLarge,
                                ),
                                content: Text(
                                  "Remove '${item.product.nameEn}' from your cart?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text(
                                      "CANCEL",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text(
                                      "REMOVE",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            return confirmed ?? false;
                          },
                          onDismissed: (_) {
                            ref
                                .read(cartProvider.notifier)
                                .removeItemById(item.id);
                            SardSnackBar.show(
                              context,
                              "${item.product.nameEn} removed from cart",
                            );
                          },
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(
                                AppTheme.cardRadius,
                              ),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          child: _CartItemCard(
                            item: item,
                            theme: theme,
                            colorScheme: colorScheme,
                            onDelete: () => _confirmDelete(context, ref, item),
                            onDecrement: () => cartNotifier.updateQuantity(
                              item.id,
                              item.quantity - 1,
                            ),
                            onIncrement: () => cartNotifier.updateQuantity(
                              item.id,
                              item.quantity + 1,
                            ),
                            onEdit: () {
                              context.push(
                                '${AppRoutes.productDetail}?editCartItemId=${item.id}',
                                extra: item.product,
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }, childCount: cartItems.length),
                ),
              ),

              // ── Spacer for bottom summary ──
              const SliverToBoxAdapter(child: SizedBox(height: 220)),
            ],
          ],
        ),

        // ── Bottom Summary Bar (matching ProductDetailScreen's bottom bar) ──
        bottomSheet: cartItems.isEmpty
            ? null
            : _CartSummaryBar(
                subtotal: subtotal,
                total: total,
                theme: theme,
                colorScheme: colorScheme,
                onCheckout: () => context.push(AppRoutes.checkout),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cart Item Card — Matches ProductDetailScreen's visual language
// ─────────────────────────────────────────────────────────────────────────────
class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final VoidCallback onDelete;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onEdit;

  const _CartItemCard({
    required this.item,
    required this.theme,
    required this.colorScheme,
    required this.onDelete,
    required this.onDecrement,
    required this.onIncrement,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final lineTotal = item.variant.price * item.quantity;
    final onCardColor = AppTheme.getOnCardColor(theme);

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: AppTheme.getCardGradient(theme),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(
            color: AppTheme.accentGold,
            width: 1.5,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            // ── Product Image ──
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                item.product.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),

            // ── Product Info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Delete
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.product.nameEn,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: onCardColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: onDelete,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: onCardColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Variant info
                  Text(
                    item.variant.size,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: onCardColor.withValues(alpha: 0.6),
                    ),
                  ),

                  // Fillings summary (if customizable)
                  if (item.selectedFillings != null &&
                      item.selectedFillings!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        "${item.selectedFillings!.values.fold(0, (a, b) => a + b)} fillings",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: onCardColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Price + Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        "₪ ${lineTotal.toStringAsFixed(2)}",
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: onCardColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      // Quantity Selector
                      Container(
                        height: 34,
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(
                            AppTheme.buttonRadius,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: onDecrement,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                child: Icon(
                                  Icons.remove_rounded,
                                  size: 16,
                                  color: AppTheme.gradientStart,
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                "${item.quantity}",
                                strutStyle: const StrutStyle(
                                  fontSize: 13,
                                  height: 1.0,
                                  forceStrutHeight: true,
                                ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.gradientStart,
                                  fontSize: 13,
                                  height: 1.0,
                                  leadingDistribution:
                                      TextLeadingDistribution.even,
                                ),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: onIncrement,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                child: Icon(
                                  Icons.add_rounded,
                                  size: 16,
                                  color: AppTheme.gradientStart,
                                ),
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cart Summary Bar — Matches ProductDetailScreen's bottom action bar
// ─────────────────────────────────────────────────────────────────────────────
class _CartSummaryBar extends StatelessWidget {
  final double subtotal;
  final double total;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final VoidCallback onCheckout;

  const _CartSummaryBar({
    required this.subtotal,
    required this.total,
    required this.theme,
    required this.colorScheme,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Subtotal",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  "₪ ${subtotal.toStringAsFixed(2)}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Shipping
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Shipping",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  "₪ 5.00",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Divider(color: Colors.grey.shade300, height: 1),
            ),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "₪ ${total.toStringAsFixed(2)}",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Checkout Button (matching ProductDetailScreen's Add to Cart button)
            SardPrimaryButton(
              label: 'GO TO PAYMENT',
              onTap: onCheckout,
            ),
          ],
        ),
      ),
    );
  }
}
