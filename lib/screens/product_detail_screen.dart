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
import 'package:cached_network_image/cached_network_image.dart';
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
          color: AppTheme.getIconColor(theme),
        ),
      ),
    );
  }

  // ── 3-button box size selector ──────────────────────────────────────────────
  Widget _buildBoxSizeSelector(
    BuildContext context,
    ProductBuilderState state,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final boxes = widget.product.bulkBoxes!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, l10n.selectSize),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: boxes.map((box) {
            final isSelected = state.selectedBulkBox?.name == box.name;
            // Strip trailing ' Box' / ' box' from the display label
            final label = box.name
                .replaceAll(RegExp(r'\s*[Bb]ox\s*$'), '')
                .trim();
            return SizedBox(
              width: 100,
              height: 64,
              child: ElevatedButton(
                onPressed: () =>
                    ref.read(productBuilderProvider.notifier).selectBulkBox(box),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? AppTheme.getIconColor(theme)
                      : theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                  foregroundColor: isSelected
                      ? (theme.brightness == Brightness.dark
                          ? AppTheme.darkCocoa
                          : AppTheme.highContrastGold)
                      : theme.colorScheme.onSurface,
                  elevation: isSelected ? 4 : 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.buttonRadius),
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.getIconColor(theme)
                          : AppTheme.getIconColor(theme).withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₪ ${box.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: isSelected
                            ? (theme.brightness == Brightness.dark
                                ? AppTheme.darkCocoa
                                : AppTheme.highContrastGold)
                            : (theme.brightness == Brightness.dark
                                ? AppTheme.getIconColor(theme)
                                : AppTheme.darkCocoa),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Collapsible template lines ───────────────────────────────────────────────
  Widget _buildTemplateLines(BuildContext context, ProductBuilderState state) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = l10n.localeName;
    final templates = widget.product.preMadeTemplates ?? [];
    if (templates.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        _buildSectionHeader(
          context,
          l10n.selectSize == 'Select Size' ? 'Choose Subtype' : 'اختر النوع',
        ),
        const SizedBox(height: 8),
        ...templates.map((template) {
          final isSelected = state.selectedTemplate?.nameEn == template.nameEn;
          return _TemplateLine(
            template: template,
            lang: lang,
            isSelected: isSelected,
            theme: theme,
            onTap: () => ref
                .read(productBuilderProvider.notifier)
                .selectTemplate(template),
          );
        }),
      ],
    );
  }

  // ── Classic variant Wrap ────────────────────────────────────────────────────
  Widget _buildVariantWrap(BuildContext context, ProductBuilderState state) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, l10n.selectSize),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.product.variants!.map((v) {
            final isSelected = state.selectedVariant?.size == v.size;
            return InkWell(
              onTap: () =>
                  ref.read(productBuilderProvider.notifier).selectVariant(v),
              borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.getCardColor(theme)
                      : theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.getIconColor(theme)
                        : AppTheme.getCardBorderColor(theme),
                    width: 1.5,
                  ),
                  boxShadow: isSelected ? AppTheme.goldShadow : null,
                ),
                child: Text(
                  v.size,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? (theme.brightness == Brightness.dark
                            ? AppTheme.darkCocoa
                            : AppTheme.highContrastGold)
                        : theme.colorScheme.onSurface,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(productBuilderProvider);
    final isWishlisted = ref
        .watch(wishlistProvider)
        .contains(widget.product.remoteId);
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
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
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
                              ? l10n.removedFromWishlist(
                                  widget.product.getName(lang),
                                )
                              : l10n.addedToWishlist(
                                  widget.product.getName(lang),
                                ),
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
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Builder(
                      builder: (context) {
                        // Always show the main product image at the top header
                        List<String> images = [widget.product.imageUrl];

                        return PageView.builder(
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            final img = images[index];
                            return Hero(
                              tag: index == 0
                                  ? 'product_${widget.product.remoteId}'
                                  : 'product_img_${index}_${widget.product.remoteId}',
                              child: img.startsWith('http')
                                  ? CachedNetworkImage(
                                      imageUrl: img,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.black12,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                            'assets/images/allchocolatetype3to2.jpg',
                                            fit: BoxFit.cover,
                                          ),
                                    )
                                  : Image.asset(img, fit: BoxFit.cover),
                            );
                          },
                        );
                      },
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                            stops: const [0.0, 0.2, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.getName(lang),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '₪ ${state.totalPrice.toStringAsFixed(2)}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.brightness == Brightness.dark
                                    ? AppTheme.getIconColor(theme)
                                    : AppTheme.darkCocoa,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          widget.product.getDescription(lang),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Bars: 2 rows (Type & Size) ─────────────────────────
                        if (widget.product.section == 'bars')
                          _buildBarSelectors(context, state),

                        // ── Bulk product: 3-button box + collapsible templates ──
                        if (widget.product.isBulkProduct) ...[
                          _buildBoxSizeSelector(context, state),
                          _buildTemplateLines(context, state),
                          const SizedBox(height: 32),
                        ],

                        // ── Classic variants (if not bars) ──────────────────────
                        if (!widget.product.isBulkProduct &&
                            widget.product.section != 'bars' &&
                            widget.product.hasVariants &&
                            widget.product.variants != null)
                          _buildVariantWrap(context, state),

                        // ── Gendered (Boy / Girl) ───────────────────────────────
                        if (widget.product.isGendered) ...[
                          _buildSectionHeader(context, l10n.customizeMix),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _GenderButton(
                                  label: l10n.boy,
                                  icon: Icons.face_rounded,
                                  color: Colors.blueAccent,
                                  isSelected: state.selectedGender == 'boy',
                                  onTap: () => notifier.selectGender('boy'),
                                  theme: theme,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _GenderButton(
                                  label: l10n.girl,
                                  icon: Icons.face_3_rounded,
                                  color: Colors.pinkAccent,
                                  isSelected: state.selectedGender == 'girl',
                                  onTap: () => notifier.selectGender('girl'),
                                  theme: theme,
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
            // Quantity stepper
            Container(
              height: 56,
              width: 140,
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                border: Border.all(
                  color: AppTheme.getIconColor(theme).withValues(alpha: 0.3),
                  width: 1.5,
                ),
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
                              ? () => ref
                                    .read(productBuilderProvider.notifier)
                                    .setQuantity(state.quantity - 1)
                              : null,
                          child: Center(
                            child: Icon(
                              Icons.remove_rounded,
                              size: 22,
                              color: state.quantity > 1
                                  ? AppTheme.getIconColor(theme)
                                  : AppTheme.getIconColor(theme).withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => ref
                              .read(productBuilderProvider.notifier)
                              .setQuantity(state.quantity + 1),
                          child: Center(
                            child: Icon(
                              Icons.add_rounded,
                              size: 22,
                              color: AppTheme.getIconColor(theme),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  IgnorePointer(
                    child: Transform.translate(
                      offset: const Offset(0, 1.0),
                      child: Text(
                        '${state.quantity}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Add to Cart
            Expanded(
              child: InkWell(
                onTap: () {
                  if (widget.product.isGendered &&
                      state.selectedGender == null) {
                    SardSnackBar.show(context, l10n.selectGenderError);
                    return;
                  }
                  if (widget.product.isCustomizable &&
                      !state.isSelectionValid) {
                    SardSnackBar.show(
                      context,
                      l10n.completeMixError(
                        state.currentPieces,
                        state.maxPieces,
                      ),
                    );
                    return;
                  }
                  if (!state.isSelectionValid) {
                    SardSnackBar.show(context, l10n.completeRequirementsError);
                    return;
                  }

                  final variantIndex =
                      widget.product.variants?.indexWhere(
                        (v) =>
                            (v.size == state.selectedVariant?.size) &&
                            (v.type == state.selectedVariant?.type),
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
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.getIconColor(theme),
                    borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                    boxShadow: AppTheme.goldShadow,
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.editingItem != null
                            ? l10n.saveChanges
                            : l10n.addToCartWithDetails(
                                widget.product.isCustomizable == true
                                    ? '${state.currentPieces}/${state.maxPieces} ${l10n.pcs}, '
                                    : '',
                                state.totalPrice.toStringAsFixed(2),
                              ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.brightness == Brightness.dark
                              ? AppTheme.darkCocoa
                              : AppTheme.highContrastGold,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
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

  Widget _buildBarSelectors(BuildContext context, ProductBuilderState state) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(productBuilderProvider.notifier);
    final variants = widget.product.variants ?? [];

    final types = variants
        .map((v) => v.type)
        .where((t) => t != null && t.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    final sizes = variants
        .map((v) => v.size)
        .where((s) => s.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    final filteredVariants = variants.where((v) {
      final typeMatch =
          state.selectedType == null || v.type == state.selectedType;
      final sizeMatch =
          state.selectedSize == null || v.size == state.selectedSize;
      return typeMatch && sizeMatch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (types.isNotEmpty) ...[
          _buildDetailSectionHeader(context, l10n.chocolateType),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: types.map((type) {
              final isSelected = state.selectedType == type;
              return SizedBox(
                width: 100,
                height: 64,
                child: ElevatedButton(
                  onPressed: () => notifier.selectType(type),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? AppTheme.getIconColor(theme)
                        : theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                    foregroundColor: isSelected
                        ? (theme.brightness == Brightness.dark
                            ? AppTheme.darkCocoa
                            : AppTheme.highContrastGold)
                        : theme.colorScheme.onSurface,
                    elevation: isSelected ? 4 : 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.buttonRadius,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.getIconColor(theme)
                            : AppTheme.getIconColor(theme).withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Text(
                    type,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
        if (sizes.isNotEmpty && sizes.toSet().difference(types.toSet()).isNotEmpty) ...[
          _buildDetailSectionHeader(context, l10n.selectSize),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sizes.map((size) {
              final isSelected = state.selectedSize == size;
              return SizedBox(
                width: 100,
                height: 64,
                child: ElevatedButton(
                  onPressed: () => notifier.selectSize(size),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? AppTheme.getIconColor(theme)
                        : theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                    foregroundColor: isSelected
                        ? (theme.brightness == Brightness.dark
                            ? AppTheme.darkCocoa
                            : AppTheme.highContrastGold)
                        : theme.colorScheme.onSurface,
                    elevation: isSelected ? 4 : 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.buttonRadius,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.getIconColor(theme)
                            : AppTheme.getIconColor(theme).withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Text(
                    size,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
        // Show the filtered variants visually below the buttons
        if (filteredVariants.isNotEmpty) ...[
          _buildDetailSectionHeader(context, "Variant Preview"),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: filteredVariants.map((v) {
              final imgUrl = v.imageUrl ?? widget.product.imageUrl;
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.getIconColor(theme).withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  image: DecorationImage(
                    image: imgUrl.startsWith('http')
                        ? CachedNetworkImageProvider(imgUrl)
                        : AssetImage(imgUrl) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ],
    );
  }

  Widget _buildDetailSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelLarge?.copyWith(
        color: AppTheme.getIconColor(theme),
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }
}

// ── Collapsible template line ──────────────────────────────────────────────────

class _TemplateLine extends StatefulWidget {
  final PreMadeTemplate template;
  final String lang;
  final bool isSelected;
  final ThemeData theme;
  final VoidCallback onTap;

  const _TemplateLine({
    required this.template,
    required this.lang,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  State<_TemplateLine> createState() => _TemplateLineState();
}

class _TemplateLineState extends State<_TemplateLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _expandAnim;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final name = widget.template.getName(widget.lang);
    final partitions = widget.template.partitions;

    return Column(
      children: [
        InkWell(
          onTap: () {
            widget.onTap();
            if (partitions.isNotEmpty) _toggle();
          },
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppTheme.getIconColor(theme)
                  : theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.isSelected
                    ? AppTheme.getIconColor(theme)
                    : AppTheme.getCardBorderColor(theme),
                width: widget.isSelected ? 2 : 1.5,
              ),
              boxShadow: widget.isSelected ? AppTheme.goldShadow : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isSelected
                        ? (theme.brightness == Brightness.dark
                            ? AppTheme.darkCocoa
                            : AppTheme.highContrastGold)
                        : Colors.transparent,
                    border: Border.all(
                      color: widget.isSelected
                          ? (theme.brightness == Brightness.dark
                              ? AppTheme.darkCocoa
                              : AppTheme.highContrastGold)
                          : AppTheme.getCardBorderColor(theme),
                      width: 2,
                    ),
                  ),
                  child: widget.isSelected
                      ? Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: theme.brightness == Brightness.dark
                              ? AppTheme.highContrastGold
                              : AppTheme.darkCocoa,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: widget.isSelected
                          ? (theme.brightness == Brightness.dark
                              ? AppTheme.darkCocoa
                              : AppTheme.highContrastGold)
                          : (theme.brightness == Brightness.dark
                              ? AppTheme.getIconColor(theme)
                              : AppTheme.textPrimaryLight),
                      fontWeight: widget.isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (partitions.isNotEmpty)
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnim),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.isSelected
                          ? (theme.brightness == Brightness.dark
                              ? AppTheme.darkCocoa
                              : AppTheme.highContrastGold)
                          : (theme.brightness == Brightness.dark
                              ? AppTheme.getIconColor(theme).withValues(alpha: 0.6)
                              : AppTheme.primaryTeal.withValues(alpha: 0.6)),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnim,
          child: Padding(
            padding: const EdgeInsets.only(left: 0, right: 0, top: 4, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: partitions
                  .map(
                    (p) => _PartitionLine(
                      partition: p,
                      lang: widget.lang,
                      theme: theme,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _PartitionLine extends StatefulWidget {
  final Map<String, dynamic> partition;
  final String lang;
  final ThemeData theme;

  const _PartitionLine({
    required this.partition,
    required this.lang,
    required this.theme,
  });

  @override
  State<_PartitionLine> createState() => _PartitionLineState();
}

class _PartitionLineState extends State<_PartitionLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _expandAnim;
  bool _expanded = false;
  TextEditingController? _percentCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    
    final ratio = (widget.partition['ratio'] as num?)?.toDouble() ?? 1.0;
    _percentCtrl = TextEditingController(text: '${(ratio * 100).toStringAsFixed(0)}');
  }

  @override
  void didUpdateWidget(_PartitionLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.partition['ratio'] != oldWidget.partition['ratio']) {
      final ratio = (widget.partition['ratio'] as num?)?.toDouble() ?? 1.0;
      if (_percentCtrl != null && _percentCtrl!.text != '${(ratio * 100).toStringAsFixed(0)}') {
        _percentCtrl!.text = '${(ratio * 100).toStringAsFixed(0)}';
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _percentCtrl?.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.partition;
    final theme = widget.theme;

    final pName = widget.lang == 'ar'
        ? (p['nameAr'] ?? p['nameEn'] ?? '')
        : (p['nameEn'] ?? '');
    final ratio = (p['ratio'] as num?)?.toDouble() ?? 1.0;
    
    // Lazy initialization for hot-reload resilience
    _percentCtrl ??= TextEditingController(text: '${(ratio * 100).toStringAsFixed(0)}');
    
    final items = (p['items'] as List?) ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withValues(
            alpha: _expanded ? 0.8 : 0.4,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _expanded
                ? AppTheme.getIconColor(theme).withValues(alpha: 0.5)
                : AppTheme.getCardBorderColor(theme),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: items.isNotEmpty ? _toggle : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.getIconColor(theme),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 36,
                            child: TextField(
                              controller: _percentCtrl,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.brightness == Brightness.dark
                                    ? AppTheme.darkCocoa
                                    : AppTheme.highContrastGold,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                              ),
                              onChanged: (val) {
                                // Handled purely locally for UI presentation
                              },
                            ),
                          ),
                          Text(
                            '%',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.brightness == Brightness.dark
                                  ? AppTheme.darkCocoa
                                  : AppTheme.highContrastGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        pName.toString(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (items.isNotEmpty)
                      RotationTransition(
                        turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnim),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white70
                              : AppTheme.primaryTeal,
                          size: 24,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (items.isNotEmpty)
              SizeTransition(
                sizeFactor: _expandAnim,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 4,
                    bottom: 8,
                  ),
                  child: Column(
                    children: items.map((item) {
                      // item['image'] is the correct field — but ensure it's a
                      // direct image URL (e.g. i.ibb.co/...), NOT a viewer page (ibb.co/...)
                      final imgUrl = item['image'] ??
                          item['image_url'] ??
                          item['imageUrl'] ??
                          item['main_image'];
                      if (imgUrl == null || imgUrl.toString().isEmpty)
                        return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.getIconColor(theme).withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.5),
                                child: imgUrl.toString().startsWith('http')
                                    ? CachedNetworkImage(
                                        imageUrl: imgUrl.toString(),
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                              color: Colors.black12,
                                              child: const Center(
                                                child: SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(
                                              Icons.error_outline,
                                              size: 20,
                                            ),
                                      )
                                    : Image.asset(
                                        imgUrl.toString(),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.lang == 'ar'
                                    ? (item['name_ar'] ?? item['name'] ?? '')
                                    : (item['name_en'] ?? item['name'] ?? ''),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Gender button ──────────────────────────────────────────────────────────────

class _GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _GenderButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.getCardColor(theme)
              : theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(
            color: isSelected ? color : AppTheme.getCardBorderColor(theme),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected
                    ? (theme.brightness == Brightness.dark
                        ? AppTheme.darkCocoa
                        : AppTheme.highContrastGold)
                    : color,
                size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isSelected
                    ? (theme.brightness == Brightness.dark
                        ? AppTheme.darkCocoa
                        : AppTheme.highContrastGold)
                    : AppTheme.getOnCardColor(theme),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
