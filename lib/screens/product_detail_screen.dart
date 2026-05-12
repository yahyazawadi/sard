import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/product_builder_provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../screens/main_wrapper_screen.dart';
import 'package:go_router/go_router.dart';
import '../utils/snackbar_utils.dart';
import '../custom/app_theme.dart';
import '../providers/wishlist_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/sard_background.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;
  final CartItem? editingItem;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.editingItem,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );

    Future.microtask(() {
      if (!mounted) return;
      if (widget.editingItem != null) {
        ref
            .read(productBuilderProvider.notifier)
            .initFromCartItem(widget.editingItem!);
      } else {
        ref.read(productBuilderProvider.notifier).initProduct(widget.product);
      }
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppTheme.getOnCardColor(theme).withValues(alpha: 0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(productBuilderProvider);
    final isWishlisted = ref.watch(wishlistProvider).contains(widget.product.remoteId);
    final notifier = ref.read(productBuilderProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final lang = l10n.localeName;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SardBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 480,
              pinned: true,
              stretch: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.3),
                    child: IconButton(
                      icon: Icon(
                        isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isWishlisted ? Colors.redAccent : Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        ref
                            .read(wishlistProvider.notifier)
                            .toggleWishlist(widget.product.remoteId);
                        SardSnackBar.show(
                          context,
                          isWishlisted
                              ? l10n.removedFromWishlist(widget.product.getName(lang))
                              : l10n.addedToWishlist(widget.product.getName(lang)),
                        );
                      },
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                background: Hero(
                  tag: 'product_${widget.product.remoteId}',
                  child: Image.asset(
                    widget.product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.getName(lang),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.getOnCardColor(theme),
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '₪ ${state.totalPrice.toStringAsFixed(2)}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppTheme.accentGold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          l10n.productDescriptionDefault,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.getOnCardColor(theme)
                                .withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 32),

                        if (widget.product.hasVariants && widget.product.variants != null) ...[
                          _buildSectionHeader(context, l10n.selectSize),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: widget.product.variants!.map((v) {
                              final isSelected = state.selectedVariant?.size == v.size;
                              return InkWell(
                                onTap: () => notifier.selectVariant(v),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.buttonRadius),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.getCardColor(theme)
                                        : theme.scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.buttonRadius,
                                    ),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.accentGold
                                          : AppTheme.getCardBorderColor(theme),
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? AppTheme.goldShadow
                                        : null,
                                  ),
                                  child: Text(
                                    v.size,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.getOnCardColor(theme),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 32),
                        ],

                        if (widget.product.isGendered) ...[
                          _buildSectionHeader(context, l10n.customizeMix),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => notifier.selectGender('boy'),
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.cardRadius),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 20),
                                    decoration: BoxDecoration(
                                      color: state.selectedGender == 'boy'
                                          ? AppTheme.getCardColor(theme)
                                          : theme.scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.cardRadius,
                                      ),
                                      border: Border.all(
                                        color: state.selectedGender == 'boy'
                                            ? Colors.blueAccent
                                            : AppTheme.getCardBorderColor(theme),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.face_rounded,
                                          color: state.selectedGender == 'boy'
                                              ? Colors.white
                                              : Colors.blueAccent,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          l10n.boy,
                                          style:
                                              theme.textTheme.titleSmall?.copyWith(
                                            color: state.selectedGender == 'boy'
                                                ? Colors.white
                                                : AppTheme.getOnCardColor(theme),
                                            fontWeight:
                                                state.selectedGender == 'boy'
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: () => notifier.selectGender('girl'),
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.cardRadius),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 20),
                                    decoration: BoxDecoration(
                                      color: state.selectedGender == 'girl'
                                          ? AppTheme.getCardColor(theme)
                                          : theme.scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.cardRadius,
                                      ),
                                      border: Border.all(
                                        color: state.selectedGender == 'girl'
                                            ? Colors.pinkAccent
                                            : AppTheme.getCardBorderColor(theme),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.face_3_rounded,
                                          color: state.selectedGender == 'girl'
                                              ? Colors.white
                                              : Colors.pinkAccent,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          l10n.girl,
                                          style:
                                              theme.textTheme.titleSmall?.copyWith(
                                            color: state.selectedGender == 'girl'
                                                ? Colors.white
                                                : AppTheme.getOnCardColor(theme),
                                            fontWeight:
                                                state.selectedGender == 'girl'
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
          border: Border(
            top: BorderSide(
              color: AppTheme.gradientStart.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 54,
              width: 130,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                border: Border.all(color: AppTheme.gradientStart, width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: state.quantity > 1
                              ? () => ref.read(productBuilderProvider.notifier).setQuantity(state.quantity - 1)
                              : null,
                          child: Center(
                            child: Icon(
                              Icons.remove_rounded,
                              size: 22,
                              color: state.quantity > 1
                                  ? AppTheme.gradientStart
                                  : AppTheme.gradientStart.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => ref.read(productBuilderProvider.notifier).setQuantity(state.quantity + 1),
                          child: const Center(
                            child: Icon(
                              Icons.add_rounded,
                              size: 22,
                              color: AppTheme.gradientStart,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  IgnorePointer(
                    child: Transform.translate(
                      offset: const Offset(0, 4.0),
                      child: Text(
                        '${state.quantity}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.gradientStart,
                          fontSize: 18,
                          height: 1.0,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  if (widget.product.isGendered &&
                      state.selectedGender == null) {
                    SardSnackBar.show(
                      context,
                      l10n.selectGenderError,
                    );
                    return;
                  }
                  if (widget.product.isCustomizable &&
                      !state.isSelectionValid) {
                    SardSnackBar.show(
                      context,
                      l10n.completeMixError(state.currentPieces, state.maxPieces),
                    );
                    return;
                  }
                  if (!state.isSelectionValid) {
                    SardSnackBar.show(
                      context,
                      l10n.completeRequirementsError,
                    );
                    return;
                  }

                  final variantIndex =
                      widget.product.variants?.indexWhere(
                        (v) => v.size == state.selectedVariant?.size,
                      ) ??
                      0;

                  if (widget.editingItem != null) {
                    ref
                        .read(cartProvider.notifier)
                        .updateCartItem(
                          CartItem(
                            id: widget.editingItem!.id,
                            product: widget.product,
                            selectedVariantIndex: variantIndex >= 0
                                ? variantIndex
                                : 0,
                            selectedGender: state.selectedGender,
                            selectedWeight: state.selectedWeight,
                            selectedFillings: state.selectedFillings,
                            quantity: state.quantity,
                          ),
                        );
                    SardSnackBar.show(context, l10n.changesSaved);
                    context.pop();
                  } else {
                    ref
                        .read(cartProvider.notifier)
                        .addToCart(
                          widget.product,
                          variantIndex: variantIndex >= 0 ? variantIndex : 0,
                          gender: state.selectedGender,
                          weight: state.selectedWeight,
                          fillings: state.selectedFillings,
                          quantity: state.quantity,
                        );
                    SardSnackBar.show(
                      context,
                      l10n.addedToCartSnackbar(widget.product.getName(lang)),
                      action: SnackBarAction(
                        label: l10n.viewCart,
                        onPressed: () {
                          ref.read(mainWrapperPageProvider.notifier).state = 2;
                          context.pop();
                        },
                      ),
                    );
                  }
                },
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(theme),
                    borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                    border: Border.all(color: AppTheme.accentGold, width: 1.5),
                    boxShadow: AppTheme.goldShadow,
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.editingItem != null
                            ? l10n.saveChanges
                            : l10n.addToCartWithDetails(
                                state.product?.isCustomizable == true 
                                    ? '${state.currentPieces}/${state.maxPieces} ${l10n.pcs}, ' 
                                    : '', 
                                state.totalPrice.toStringAsFixed(2)),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
