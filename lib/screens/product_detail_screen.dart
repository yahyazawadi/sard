import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/product_builder_provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import '../utils/snackbar_utils.dart';
import '../custom/app_theme.dart';

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
  late AnimationController _bottomSheetController;
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _bottomSheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Slower, smoother entry
    );

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

    // Initialize state asynchronously to avoid mid-transition rebuild exceptions
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

    // Delay the entry animation until the Hero transition is mostly done
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _bottomSheetController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(productBuilderProvider);
    final notifier = ref.read(productBuilderProvider.notifier);

    // Guard against uninitialized state handled implicitly because product fields are used from widget.product

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // --- Hero Image ---
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: theme.appBarTheme.backgroundColor,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        context.push(AppRoutes.cart);
                      },
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
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
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.nameEn.toUpperCase(),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "A luxurious collection, custom-built or pre-mixed with legendary fillings.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              "₪ ",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              state.totalPrice.toStringAsFixed(2),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // --- Master Toggle 1: hasVariants (S/M/L) ---
                        if (widget.product.hasVariants &&
                            widget.product.variants != null) ...[
                          Row(
                            children: widget.product.variants!.map((v) {
                              final isSelected =
                                  state.selectedVariant?.size == v.size;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    if (state.isEdited) {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Change Size?"),
                                          content: const Text(
                                            "Changing the box size will reset your custom mix. Are you sure?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text(
                                                "CANCEL",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Theme.of(
                                                  context,
                                                ).colorScheme.tertiary,
                                              ),
                                              child: const Text(
                                                "YES, RESET",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        notifier.selectVariant(v);
                                      }
                                    } else {
                                      notifier.selectVariant(v);
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? theme.colorScheme.tertiary
                                                .withValues(alpha: 0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.buttonRadius,
                                      ),
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.colorScheme.tertiary
                                            : Colors.grey.shade300,
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          v.size.toUpperCase(),
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.w900
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? theme.colorScheme.tertiary
                                                : Colors.black87,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        if (v.pieces != null)
                                          Text(
                                            "(${v.pieces} PCS)",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isSelected
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .tertiary
                                                        .withValues(alpha: 0.8)
                                                  : Colors.grey.shade500,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // --- Master Toggle 2: isGendered (Boy/Girl) ---
                        if (widget.product.isGendered) ...[
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => notifier.selectGender('boy'),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: state.selectedGender == 'boy'
                                          ? theme.colorScheme.primary
                                                .withValues(alpha: 0.15)
                                          : theme
                                                .colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.cardRadius,
                                      ),
                                      border: Border.all(
                                        color: state.selectedGender == 'boy'
                                            ? theme.colorScheme.primary
                                            : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "BOY",
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: state.selectedGender == 'boy'
                                                ? theme.colorScheme.primary
                                                : theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => notifier.selectGender('girl'),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: state.selectedGender == 'girl'
                                          ? const Color(0xFFFCE4EC)
                                          : theme
                                                .colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.cardRadius,
                                      ),
                                      border: Border.all(
                                        color: state.selectedGender == 'girl'
                                            ? const Color(0xFFE91E63)
                                            : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "GIRL",
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                state.selectedGender == 'girl'
                                                ? const Color(0xFFC2185B)
                                                : theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        // --- Master Toggle 3: isCustomizable (Fillings Grid) ---
                        if (widget.product.isCustomizable) ...[
                          const Divider(height: 32),
                          // Custom selections expanded
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "SELECTED FILLINGS",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => _showFillingsBottomSheet(
                                        context,
                                        state,
                                        notifier,
                                      ),
                                      child: Text(
                                        "Edit Mix",
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.tertiary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Horizontally scrollable selected fillings
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: state.selectedFillings.length,
                                    itemBuilder: (context, index) {
                                      final fillingId = state
                                          .selectedFillings
                                          .keys
                                          .elementAt(index);
                                      final count =
                                          state.selectedFillings[fillingId]!;
                                      final name = _getMockFillingName(
                                        fillingId,
                                      );

                                      return Container(
                                        width: 80,
                                        margin: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        child: Column(
                                          children: [
                                            Stack(
                                              alignment: Alignment.topRight,
                                              children: [
                                                Image.asset(
                                                  'assets/images/filling.png',
                                                  height: 50,
                                                  cacheWidth: 200,
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Color(
                                                          0xFF49D4D0,
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: Text(
                                                    "$count",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              name,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),

                        // --- Add to Cart Button (Moved from bottom bar) ---
                        InkWell(
                          onTap: state.isSelectionValid
                              ? () {
                                  final variantIndex =
                                      widget.product.variants?.indexWhere(
                                        (v) =>
                                            v.size ==
                                            state.selectedVariant?.size,
                                      ) ??
                                      0;

                                  if (widget.editingItem != null) {
                                    // Update existing item
                                    ref
                                        .read(cartProvider.notifier)
                                        .updateCartItem(
                                          CartItem(
                                            id: widget.editingItem!.id,
                                            product: widget.product,
                                            selectedVariantIndex:
                                                variantIndex >= 0
                                                ? variantIndex
                                                : 0,
                                            selectedGender:
                                                state.selectedGender,
                                            selectedWeight:
                                                state.selectedWeight,
                                            selectedFillings:
                                                state.selectedFillings,
                                            quantity:
                                                widget.editingItem!.quantity,
                                          ),
                                        );
                                    SardSnackBar.show(
                                      context,
                                      "Changes saved successfully",
                                    );
                                    context.pop(); // Go back to cart
                                  } else {
                                    // Add new item
                                    ref
                                        .read(cartProvider.notifier)
                                        .addToCart(
                                          widget.product,
                                          variantIndex: variantIndex >= 0
                                              ? variantIndex
                                              : 0,
                                          gender: state.selectedGender,
                                          weight: state.selectedWeight,
                                          fillings: state.selectedFillings,
                                        );
                                    SardSnackBar.show(
                                      context,
                                      "${widget.product.nameEn} added to cart",
                                      action: SnackBarAction(
                                        label: "VIEW CART",
                                        onPressed: () =>
                                            context.push(AppRoutes.cart),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: state.isSelectionValid ? 1.0 : 0.5,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppTheme.buttonRadius,
                              ),
                              border: Border.all(
                                color: theme.colorScheme.tertiary,
                                width: 2,
                              ), // Permanent Gold border
                              boxShadow: state.isSelectionValid
                                  ? AppTheme.goldShadow
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              widget.editingItem != null
                                  ? "SAVE CHANGES"
                                  : "ADD TO CART (${state.product?.isCustomizable == true ? '${state.currentPieces}/${state.maxPieces} PIECES, ' : ''}₪ ${state.totalPrice.toStringAsFixed(2)})",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SafeArea(top: false, child: SizedBox(height: 60)),
            ),
          ],
        ),
      ],
    );
  }

  String _getMockFillingName(String id) {
    final mockNames = {
      'fill_0': 'Pistachio Dream',
      'fill_1': 'Nutella Swirl',
      'fill_2': 'Lotus Crunch',
      'fill_3': 'Dark Truffle',
      'fill_4': 'Hazelnut',
      'fill_5': 'White Chocolate',
      'fill_6': 'Caramel Salt',
      'fill_7': 'Berry Mix',
      'fill_8': 'Coffee Bean',
      'fill_9': 'Almond Crisp',
    };
    return mockNames[id] ?? 'Special Mix';
  }

  void _showFillingsBottomSheet(
    BuildContext context,
    ProductBuilderState state,
    ProductBuilderNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      transitionAnimationController: _bottomSheetController,
      builder: (modalContext) => _FillingsSheetContent(
        state: state,
        notifier: notifier,
        onClose: () {
          if (modalContext.mounted) {
            Navigator.pop(modalContext);
          }
        },
      ),
    );
  }
}

class _FillingsSheetContent extends StatefulWidget {
  final ProductBuilderState state;
  final ProductBuilderNotifier notifier;
  final VoidCallback onClose;

  const _FillingsSheetContent({
    required this.state,
    required this.notifier,
    required this.onClose,
  });

  @override
  State<_FillingsSheetContent> createState() => _FillingsSheetContentState();
}

class _FillingsSheetContentState extends State<_FillingsSheetContent> {
  bool _isClosing = false;
  bool _isExpanded = false;

  String _getMockFillingName(String id) {
    const mockNames = {
      'fill_0': 'Milk Chocolate',
      'fill_1': 'Pistachio Cream',
      'fill_2': 'Sea Salt Caramel',
      'fill_3': 'Dark Truffle',
      'fill_4': 'Hazelnut',
      'fill_5': 'White Chocolate',
      'fill_6': 'Caramel Salt',
      'fill_7': 'Berry Mix',
      'fill_8': 'Coffee Bean',
      'fill_9': 'Almond Crisp',
    };
    return mockNames[id] ?? 'Special Mix';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.01,
          maxChildSize: 0.95,
          expand: false,
          snap: true,
          snapSizes: const [0.4, 0.95],
          builder: (_, scrollController) {
            return NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                if (notification.extent <= 0.05 && !_isClosing) {
                  _isClosing = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.onClose();
                  });
                } else if (notification.extent > 0.45 && !_isExpanded) {
                  setState(() => _isExpanded = true);
                } else if (notification.extent <= 0.45 && _isExpanded) {
                  setState(() => _isExpanded = false);
                }
                return false;
              },
              child: Consumer(
                builder: (ctx, ref, child) {
                  final sheetState = ref.watch(productBuilderProvider);
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: CustomScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Customize Mix",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${sheetState.currentPieces}/${sheetState.maxPieces}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            sheetState.currentPieces >
                                                sheetState.maxPieces
                                            ? Colors.red
                                            : Theme.of(
                                                ctx,
                                              ).colorScheme.tertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Divider(height: 1),
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 250),
                                crossFadeState: _isExpanded
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                firstChild: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        "Swipe up to expand...",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 110,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        itemCount: 10,
                                        itemBuilder: (context, index) {
                                          final fillingId = 'fill_$index';
                                          final name = _getMockFillingName(
                                            fillingId,
                                          );
                                          final count =
                                              sheetState
                                                  .selectedFillings[fillingId] ??
                                              0;
                                          return Container(
                                            width: 90,
                                            margin: const EdgeInsets.only(
                                              right: 10,
                                            ),
                                            child: _buildFillingCard(
                                              context,
                                              fillingId,
                                              name,
                                              count,
                                              widget.notifier,
                                              isCompact: true,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                                secondChild: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    12,
                                    12,
                                    120,
                                  ),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 0.65,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                  itemCount: 10,
                                  itemBuilder: (context, index) {
                                    final fillingId = 'fill_$index';
                                    final name = _getMockFillingName(fillingId);
                                    final count =
                                        sheetState
                                            .selectedFillings[fillingId] ??
                                        0;
                                    return _buildFillingCard(
                                      context,
                                      fillingId,
                                      name,
                                      count,
                                      widget.notifier,
                                      isCompact: false,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SliverFillRemaining(hasScrollBody: false),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: RepaintBoundary(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: widget.onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "SAVE SELECTIONS",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFillingCard(
    BuildContext context,
    String fillingId,
    String name,
    int count,
    ProductBuilderNotifier notifier, {
    bool isCompact = false,
  }) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: count > 0
                ? Theme.of(context).colorScheme.tertiary
                : Colors.grey.shade200,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // filling.png always shown
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        'assets/images/filling.png',
                        height: isCompact ? 60 : 50,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        cacheWidth: 200,
                      ),
                    ),
                    // cover.png below filling.png — only in full card mode
                    if (!isCompact)
                      ...([
                        const SizedBox(height: 2),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              'assets/images/cover.png',
                              fit: BoxFit.contain,
                              cacheWidth: 200,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(
                                    height: 50,
                                    width: double.infinity,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ]),
                  ],
                ),
              ),
            ),

            // +/- controls
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(7),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => notifier.removeFilling(fillingId),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.remove_rounded, size: 14),
                    ),
                  ),
                  Text(
                    "$count",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => notifier.addFilling(fillingId),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.add_rounded, size: 14),
                    ),
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
