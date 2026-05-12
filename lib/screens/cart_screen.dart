import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../routes/app_routes.dart';
import '../custom/app_theme.dart';
import '../models/cart_item.dart';
import '../utils/snackbar_utils.dart';
import 'main_wrapper_screen.dart';
import '../widgets/sard_primary_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
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
    if (!context.mounted) return;
    final skipConfirm = prefs.getBool('skip_cart_remove_confirm') ?? false;

    bool? confirmed = false;

    if (skipConfirm) {
      confirmed = true;
    } else {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (context) =>
            _RemoveConfirmationDialog(productName: item.product.getName(AppLocalizations.of(context)!.localeName)),
      );
    }

    if (confirmed == true) {
      ref.read(cartProvider.notifier).removeItemById(item.id);
      if (context.mounted) {
        final languageCode = AppLocalizations.of(context)!.localeName;
        SardSnackBar.show(
          context,
          "${item.product.getName(languageCode)} ${AppLocalizations.of(context)!.removed}",
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.undo,
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
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            // ── App Bar ──
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
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
              title: Text(AppLocalizations.of(context)!.myCart, style: theme.textTheme.titleLarge),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                        color: AppTheme.gradientStart.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.cartEmpty,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Material(
                        color: AppTheme.gradientStart,
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                        child: InkWell(
                          onTap: () {
                            ref.read(mainWrapperPageProvider.notifier).state = 0;
                          },
                          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                          child: Container(
                            width: 220,
                            height: 54,
                            alignment: Alignment.center,
                            child: Text(
                              AppLocalizations.of(context)!.exploreProducts,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontSize: 14,
                              ),
                            ),
                          ),
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
                      "$totalItems ${totalItems == 1 ? AppLocalizations.of(context)!.item : AppLocalizations.of(context)!.items}",
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
                          direction: DismissDirection.horizontal,
                          resizeDuration: const Duration(milliseconds: 150),
                          movementDuration: const Duration(milliseconds: 150),
                          dismissThresholds: const {
                            DismissDirection.startToEnd: 0.3,
                            DismissDirection.endToStart: 0.3,
                          },
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              // Delete confirmation
                              final prefs = await SharedPreferences.getInstance();
                              if (!context.mounted) return false;
                              if (prefs.getBool('skip_cart_remove_confirm') ?? false) {
                                return true;
                              }
                              return await showDialog<bool>(
                                context: context,
                                builder: (ctx) => _RemoveConfirmationDialog(
                                  productName: item.product.getName(AppLocalizations.of(context)!.localeName),
                                ),
                              );
                            } else {
                              // Add to Favorites (No confirmation needed usually)
                              return true;
                            }
                          },
                          onDismissed: (direction) {
                            if (direction == DismissDirection.startToEnd) {
                              // Deleted
                              ref.read(cartProvider.notifier).removeItemById(item.id);
                              final lang = AppLocalizations.of(context)!.localeName;
                              SardSnackBar.show(
                                context,
                                "${item.product.getName(lang)} ${AppLocalizations.of(context)!.removed}",
                                action: SnackBarAction(
                                  label: AppLocalizations.of(context)!.undo,
                                  onPressed: () => ref.read(cartProvider.notifier).restoreItem(item),
                                ),
                              );
                            } else {
                              // Moved to Wishlist
                              ref.read(wishlistProvider.notifier).addToWishlist(item.product.remoteId);
                              ref.read(cartProvider.notifier).removeItemById(item.id);
                              final lang = AppLocalizations.of(context)!.localeName;
                              SardSnackBar.show(
                                context,
                                "${item.product.getName(lang)} ${AppLocalizations.of(context)!.movedToWishlist}",
                                action: SnackBarAction(
                                  label: AppLocalizations.of(context)!.undo,
                                  onPressed: () {
                                    ref.read(wishlistProvider.notifier).toggleWishlist(item.product.remoteId);
                                    ref.read(cartProvider.notifier).restoreItem(item);
                                  },
                                ),
                              );
                            }
                          },
                          // Swipe Right (Start to End) -> Delete
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.4), width: 2),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 24),
                            child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 28),
                          ),
                          // Swipe Left (End to Start) -> Favorite
                          secondaryBackground: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.gradientStart.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                              border: Border.all(color: AppTheme.gradientStart.withValues(alpha: 0.4), width: 2),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            child: const Icon(Icons.favorite_rounded, color: Colors.red, size: 28),
                          ),
                          child: _CartItemCard(
                            item: item,
                            theme: theme,
                            colorScheme: colorScheme,
                            onDelete: () => _confirmDelete(context, ref, item),
                            onDecrement: () {
                              if (item.quantity > 1) {
                                cartNotifier.updateQuantity(
                                  item.id,
                                  item.quantity - 1,
                                );
                              } else {
                                _confirmDelete(context, ref, item);
                              }
                            },
                            onIncrement: () => cartNotifier.updateQuantity(
                              item.id,
                              item.quantity + 1,
                            ),
                            onEdit: () {
                              context.push(
                                '${AppRoutes.productDetail}?id=${item.product.remoteId}&editCartItemId=${item.id}',
                                extra: {
                                  'product': item.product,
                                  'editingItem': item,
                                },
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
    final languageCode = AppLocalizations.of(context)!.localeName;
    final lineTotal = item.variant.price * item.quantity;
    final onCardColor = AppTheme.getOnCardColor(theme);

    return Container(
      height: 110,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(theme),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.getCardBorderColor(theme), width: 1.5),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius - 1.5),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Root Gesture for Editing (Background layer)
            Positioned.fill(
              child: GestureDetector(
                onTap: onEdit,
                behavior: HitTestBehavior.opaque,
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
                        padding: const EdgeInsets.fromLTRB(0, 6, 12, 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8), // Padding for title
                            Text(
                              item.product.getName(languageCode),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: onCardColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item.variant.size,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: onCardColor.withValues(alpha: 0.6),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "₪ ${lineTotal.toStringAsFixed(2)}",
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: onCardColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Delete Button (Foreground layer)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onDelete,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: onCardColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),

            // 3. Quantity Pill (Visual only)
            Positioned(
              bottom: 6,
              right: 12,
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(theme),
                  borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                  border: Border.all(
                    color: AppTheme.getButtonBorderColor(theme),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.remove_rounded, size: 14, color: onCardColor),
                    ),
                    Transform.translate(
                      offset: const Offset(0, 2),
                      child: Text(
                        "${item.quantity}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: onCardColor,
                          fontSize: 12,
                          height: 1.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.add_rounded, size: 14, color: onCardColor),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Ghost Hitboxes (Topmost layer, currently visible for debugging)
            Positioned(
              bottom: 0,
              right: 52, // Overlap left of pill
              child: GestureDetector(
                onTap: onDecrement,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 55,
                  height: 50,
                  color: Colors.transparent,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0, // Overlap right of pill
              child: GestureDetector(
                onTap: onIncrement,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 52,
                  height: 50,
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
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
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
        border: Border.all(
          color: AppTheme.getCardBorderColor(theme),
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
                Text(
                  AppLocalizations.of(context)!.subtotal,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.shipping,
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
              child: Divider(
                color: theme.colorScheme.outlineVariant,
                height: 1,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.total,
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
            SardPrimaryButton(label: AppLocalizations.of(context)!.goToPayment, onTap: onCheckout),
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
  State<_RemoveConfirmationDialog> createState() =>
      _RemoveConfirmationDialogState();
}

class _RemoveConfirmationDialogState extends State<_RemoveConfirmationDialog> {
  bool _dontAskAgain = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
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
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.removeItemConfirmTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "${AppLocalizations.of(context)!.removeItemConfirmBody1}${widget.productName}${AppLocalizations.of(context)!.removeItemConfirmBody2}",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
                      onChanged: (val) =>
                          setState(() => _dontAskAgain = val ?? false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.dontAskAgain,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
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
                        borderRadius: BorderRadius.circular(
                          AppTheme.buttonRadius,
                        ),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(context)!.remove,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                        strutStyle: StrutStyle(
                          height: 1.0,
                          forceStrutHeight: true,
                        ),
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
