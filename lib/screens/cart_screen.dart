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
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final skipConfirm = prefs.getBool('skip_cart_remove_confirm') ?? false;

    bool? confirmed = false;
    
    if (skipConfirm) {
      confirmed = true;
    } else {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => _RemoveConfirmationDialog(productName: item.product.nameEn),
      );
    }

    if (confirmed == true) {
      ref.read(cartProvider.notifier).removeItemById(item.id);
      if (context.mounted) {
        SardSnackBar.show(
          context, 
          "${item.product.nameEn} removed",
          action: SnackBarAction(
            label: "undo",
            onPressed: () => ref.read(cartProvider.notifier).restoreItem(item),
          ),
        );
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
            // ── App Bar ──
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
                            final prefs = await SharedPreferences.getInstance();
                            if (prefs.getBool('skip_cart_remove_confirm') ?? false) {
                              return true;
                            }
                            return await showDialog<bool>(
                              context: context,
                              builder: (ctx) => _RemoveConfirmationDialog(productName: item.product.nameEn),
                            );
                          },
                          onDismissed: (_) {
                            ref
                                .read(cartProvider.notifier)
                                .removeItemById(item.id);
                            SardSnackBar.show(
                              context,
                              "${item.product.nameEn} removed",
                              action: SnackBarAction(
                                label: "undo",
                                onPressed: () => ref.read(cartProvider.notifier).restoreItem(item),
                              ),
                            );
                          },
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(
                                AppTheme.cardRadius,
                              ),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.4),
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red,
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

              const SliverToBoxAdapter(child: SizedBox(height: 220)),
            ],
          ],
        ),
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
        height: 110,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: AppTheme.getCardGradient(theme),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(color: AppTheme.accentGold, width: 1.5),
          boxShadow: AppTheme.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius - 1.5),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                height: double.infinity,
                child: Image.asset(
                  item.product.imageUrl,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                              maxLines: 1,
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
                      Text(
                        item.variant.size,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: onCardColor.withValues(alpha: 0.6),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "₪ ${lineTotal.toStringAsFixed(2)}",
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: onCardColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(
                                AppTheme.buttonRadius,
                              ),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: onDecrement,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Icon(Icons.remove_rounded, size: 14, color: AppTheme.gradientStart),
                                  ),
                                ),
                                Text(
                                  "${item.quantity}",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.gradientStart,
                                    fontSize: 12,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: onIncrement,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Icon(Icons.add_rounded, size: 14, color: AppTheme.gradientStart),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Subtotal", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500)),
                Text("₪ ${subtotal.toStringAsFixed(2)}", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Shipping", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500)),
                Text("₪ 5.00", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Divider(color: theme.colorScheme.outlineVariant, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text("₪ ${total.toStringAsFixed(2)}", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 18),
            SardPrimaryButton(label: 'GO TO PAYMENT', onTap: onCheckout),
          ],
        ),
      ),
    );
  }
}

class _RemoveConfirmationDialog extends StatefulWidget {
  final String productName;

  const _RemoveConfirmationDialog({required this.productName});

  @override
  State<_RemoveConfirmationDialog> createState() => _RemoveConfirmationDialogState();
}

class _RemoveConfirmationDialogState extends State<_RemoveConfirmationDialog> {
  bool _dontAskAgain = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cardRadius)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 32),
            ),
            const SizedBox(height: 20),
            Text("Remove Item?", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              "Are you sure you want to remove '${widget.productName}' from your cart?",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => setState(() => _dontAskAgain = !_dontAskAgain),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _dontAskAgain,
                      activeColor: AppTheme.gradientStart,
                      onChanged: (val) => setState(() => _dontAskAgain = val ?? false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text("Don't ask again", style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("CANCEL", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      if (_dontAskAgain) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('skip_cart_remove_confirm', true);
                      }
                      if (context.mounted) Navigator.pop(context, true);
                    },
                    borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.25), width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "REMOVE",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                        strutStyle: StrutStyle(height: 1.0, forceStrutHeight: true),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
