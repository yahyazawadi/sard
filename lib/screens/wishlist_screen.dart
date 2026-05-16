import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/wishlist_provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import '../routes/app_routes.dart';
import '../custom/app_theme.dart';
import '../utils/snackbar_utils.dart';
import 'main_wrapper_screen.dart';
import '../l10n/app_localizations.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  Future<bool> _confirmRemove(BuildContext context, Product product) async {
    final prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return false;

    final skipConfirm = prefs.getBool('skip_wishlist_remove_confirm') ?? false;

    if (skipConfirm) return true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _WishlistRemoveDialog(
        productName: product.getName(Localizations.localeOf(context).languageCode),
      ),
    );

    return confirmed ?? false;
  }

  void _handleAdd(
    BuildContext context,
    WidgetRef ref,
    Product product, {
    bool removeFromWishlist = false,
  }) {
    final theme = Theme.of(context);
    final variants = product.variants ?? [];
    if (variants.length > 1) {
      // Show variant picker
      showModalBottomSheet(
        context: context,
        backgroundColor: theme.scaffoldBackgroundColor,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          final searchBg = theme.brightness == Brightness.light
              ? Colors.grey.shade200
              : theme.colorScheme.surfaceContainerHighest;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: searchBg,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.selectSize,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...variants.asMap().entries.map((entry) {
                    final index = entry.key;
                    final variant = entry.value;
                    return ListTile(
                      title: Text(variant.size),
                      trailing: Text(
                        '${variant.price} ₪',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        ref
                            .read(cartProvider.notifier)
                            .addToCart(product, variantIndex: index);

                        if (removeFromWishlist) {
                          ref
                              .read(wishlistProvider.notifier)
                              .toggleWishlist(product.remoteId);
                        }

                        Navigator.pop(context);
                        final lang = AppLocalizations.of(context)!.localeName;
                        SardSnackBar.show(
                          context,
                          removeFromWishlist
                              ? "${product.getName(lang)} ${AppLocalizations.of(context)!.movedToCart}"
                              : "${product.getName(lang)} ${AppLocalizations.of(context)!.addedToCart}",
                          action: SnackBarAction(
                            label: AppLocalizations.of(context)!.viewCart,
                            onPressed: () =>
                                ref
                                        .read(mainWrapperPageProvider.notifier)
                                        .state =
                                    2,
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // Add directly
      ref.read(cartProvider.notifier).addToCart(product);
      if (removeFromWishlist) {
        ref.read(wishlistProvider.notifier).toggleWishlist(product.remoteId);
      }
      final lang = AppLocalizations.of(context)!.localeName;
      SardSnackBar.show(
        context,
        removeFromWishlist
            ? "${product.getName(lang)} ${AppLocalizations.of(context)!.movedToCart}"
            : "${product.getName(lang)} ${AppLocalizations.of(context)!.addedToCart}",
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.viewCart,
          onPressed: () => ref.read(mainWrapperPageProvider.notifier).state = 2,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final wishlistIds = ref.watch(wishlistProvider);
    final productsAsync = ref.watch(wishlistProductsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.getIconColor(theme),
                size: 20,
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  final history = ref.read(tabHistoryProvider);
                  if (history.length > 1) {
                    final newHistory = List<int>.from(history)
                      ..removeLast();
                    ref.read(tabHistoryProvider.notifier).state = newHistory;
                    ref.read(mainWrapperPageProvider.notifier).state =
                        newHistory.last;
                  } else {
                    context.go(AppRoutes.home);
                  }
                }
              },
            ),
            title: Text(AppLocalizations.of(context)!.myWishlist, style: theme.textTheme.titleLarge),
          ),
          if (wishlistIds.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_outline_rounded,
                      size: 80,
                      color: AppTheme.gradientStart.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.wishlistEmpty,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Material(
                      color: AppTheme.gradientStart,
                      borderRadius: BorderRadius.circular(
                        AppTheme.buttonRadius,
                      ),
                      child: InkWell(
                        onTap: () {
                          ref.read(mainWrapperPageProvider.notifier).state = 0;
                        },
                        borderRadius: BorderRadius.circular(
                          AppTheme.buttonRadius,
                        ),
                        child: Container(
                          width: 220,
                          height: 54,
                          alignment: Alignment.center,
                          child: Text(
                            AppLocalizations.of(context)!.exploreProducts,
                            style: const TextStyle(
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
          else
            productsAsync.when(
              skipLoadingOnReload: true,
              data: (allProducts) {
                final products = allProducts
                    .where((p) => wishlistIds.contains(p.remoteId))
                    .toList();
                if (products.isEmpty && wishlistIds.isNotEmpty) {
                  // This case might happen during transitions, show a loader or just wait
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = products[index];
                      return Dismissible(
                        key: Key('wishlist_grid_${product.remoteId}'),
                        direction: DismissDirection.horizontal,
                        resizeDuration: const Duration(milliseconds: 150),
                        movementDuration: const Duration(milliseconds: 150),
                        dismissThresholds: const {
                          DismissDirection.startToEnd: 0.3,
                          DismissDirection.endToStart: 0.3,
                        },
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            final variants = product.variants ?? [];
                            if (variants.length > 1) {
                              _handleAdd(
                                context,
                                ref,
                                product,
                                removeFromWishlist: true,
                              );
                              return false;
                            }
                            return true;
                          } else {
                            return await _confirmRemove(context, product);
                          }
                        },
                        onDismissed: (direction) {
                          if (direction == DismissDirection.startToEnd) {
                            ref.read(cartProvider.notifier).addToCart(product);
                            ref
                                .read(wishlistProvider.notifier)
                                .toggleWishlist(product.remoteId);
                            final languageCode = AppLocalizations.of(context)!.localeName;
                            SardSnackBar.show(
                              context,
                              "${product.getName(languageCode)} ${AppLocalizations.of(context)!.movedToCart}",
                              action: SnackBarAction(
                                label: AppLocalizations.of(context)!.viewCart,
                                onPressed: () =>
                                    ref
                                            .read(
                                              mainWrapperPageProvider.notifier,
                                            )
                                            .state =
                                        2,
                              ),
                            );
                          } else {
                            ref
                                .read(wishlistProvider.notifier)
                                .toggleWishlist(product.remoteId);
                            final languageCode = AppLocalizations.of(context)!.localeName;
                            SardSnackBar.show(
                              context,
                              "${product.getName(languageCode)} ${AppLocalizations.of(context)!.removed}",
                              action: SnackBarAction(
                                label: AppLocalizations.of(context)!.undo,
                                onPressed: () => ref
                                    .read(wishlistProvider.notifier)
                                    .toggleWishlist(product.remoteId),
                              ),
                            );
                          }
                        },
                        background: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.gradientStart.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppTheme.cardRadius,
                            ),
                            border: Border.all(
                              color: AppTheme.gradientStart.withValues(
                                alpha: 0.4,
                              ),
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 16),
                          child: const Icon(
                            Icons.shopping_bag_rounded,
                            color: AppTheme.gradientStart,
                            size: 24,
                          ),
                        ),
                        secondaryBackground: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppTheme.cardRadius,
                            ),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                        child: _WishlistItemCard(
                          product: product,
                          theme: theme,
                          onRemove: () => _confirmRemove(context, product),
                          onAddToCart: () => _handleAdd(context, ref, product),
                        ),
                      );
                    }, childCount: products.length),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) =>
                  SliverFillRemaining(child: Center(child: Text(AppLocalizations.of(context)!.errorLoading(e.toString())))),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

class _WishlistItemCard extends StatelessWidget {
  final Product product;
  final ThemeData theme;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  const _WishlistItemCard({
    required this.product,
    required this.theme,
    required this.onRemove,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final variants = product.variants ?? [];
    double displayPrice = 0.0;

    if (variants.isNotEmpty) {
      final smallVariant = variants.firstWhere(
        (v) => v.size.toLowerCase().contains('small'),
        orElse: () {
          final nonZero = variants.where((v) => v.price > 0).toList();
          if (nonZero.isNotEmpty) {
            return nonZero.reduce((a, b) => a.price < b.price ? a : b);
          }
          return variants.first;
        },
      );
      displayPrice = smallVariant.price;
    } else if (product.isBulkProduct && (product.bulkBoxes?.isNotEmpty ?? false)) {
      final nonZeroBoxes = product.bulkBoxes!.where((b) => b.price > 0).toList();
      if (nonZeroBoxes.isNotEmpty) {
        displayPrice = nonZeroBoxes.reduce((a, b) => a.price < b.price ? a : b).price;
      }
    }

    final gender = product.gender;
    final onCardColor = AppTheme.getOnCardColor(theme);

    return GestureDetector(
      onTap: () {
        context.push(
          '${AppRoutes.productDetail}?id=${product.remoteId}',
          extra: product,
        );
      },
      child: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(theme),
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            border: Border.all(color: AppTheme.getCardBorderColor(theme), width: 1.5),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppTheme.cardRadius),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Hero(
                        tag: 'product_wish_${product.remoteId}',
                        child: product.imageUrl.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: product.imageUrl,
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
                                placeholder: (_, __) => Container(
                                  color: AppTheme.getCardColor(theme),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: AppTheme.getCardColor(theme),
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: AppTheme.accentGold.withValues(alpha: 0.4),
                                    size: 32,
                                  ),
                                ),
                              )
                            : Image.asset(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
                                cacheWidth: 600,
                              ),
                      ),
                    ),
                    if (gender != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: gender == 'boy'
                                ? Colors.blue.withValues(alpha: 0.8)
                                : Colors.pink.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            gender == 'boy'
                                ? Icons.male_rounded
                                : Icons.female_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    // Heart Icon (Top Left)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor.withValues(
                                alpha: 0.7,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Colors.red,
                              size: 18,
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onRemove,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  height: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.getName(languageCode),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: onCardColor,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${displayPrice.toStringAsFixed(0)} ₪',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: onCardColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          // Send to Cart Symbol (Actionable)
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.getCardColor(theme),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.buttonRadius / 2,
                                  ),
                                  border: Border.all(
                                    color: AppTheme.getButtonBorderColor(theme),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      color: onCardColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: onCardColor,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                              Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: onAddToCart,
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.buttonRadius / 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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

class _WishlistRemoveDialog extends StatefulWidget {
  final String productName;

  const _WishlistRemoveDialog({required this.productName});

  @override
  State<_WishlistRemoveDialog> createState() => _WishlistRemoveDialogState();
}

class _WishlistRemoveDialogState extends State<_WishlistRemoveDialog> {
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
              child: const Text("❤️", style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.removeFromWishlistTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "${AppLocalizations.of(context)!.removeFromWishlistBody1}${widget.productName}${AppLocalizations.of(context)!.removeFromWishlistBody2}",
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
                      AppLocalizations.of(context)!.keep,
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
                        await prefs.setBool(
                          'skip_wishlist_remove_confirm',
                          true,
                        );
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
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
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
