import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/product_builder_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productBuilderProvider.notifier).initProduct(widget.product);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productBuilderProvider);
    final notifier = ref.read(productBuilderProvider.notifier);

    // Guard against uninitialized state
    if (state.product == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // --- Hero Image ---
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                      onPressed: () => Navigator.pop(context),
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
                        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                        onPressed: () {
                          // Go to cart
                        },
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    widget.product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // --- Product Details ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.nameEn.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'serif',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "A luxurious collection, custom-built or pre-mixed with legendary fillings.",
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            "₪ ",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            state.totalPrice.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // --- Master Toggle 1: hasVariants (S/M/L) ---
                      if (widget.product.hasVariants && widget.product.variants != null) ...[
                        Row(
                          children: widget.product.variants!.map((v) {
                            final isSelected = state.selectedVariant?.size == v.size;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  if (state.isEdited) {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Change Size?"),
                                        content: const Text("Changing the box size will reset your custom mix. Are you sure?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.tertiary),
                                            child: const Text("YES, RESET", style: TextStyle(color: Colors.white)),
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
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: isSelected ? Theme.of(context).colorScheme.tertiary : Colors.grey.shade300,
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        v.size.toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                                          color: isSelected ? Theme.of(context).colorScheme.tertiary : Colors.black87,
                                          fontFamily: 'serif',
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      if (v.pieces != null)
                                        Text(
                                          "(${v.pieces} PCS)",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isSelected ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.8) : Colors.grey.shade500,
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
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: state.selectedGender == 'boy' ? Colors.blue : Colors.blue.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "IT'S A BOY 👦",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: state.selectedGender == 'boy' ? Colors.white : Colors.blue.shade900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => notifier.selectGender('girl'),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: state.selectedGender == 'girl' ? Colors.pink : Colors.pink.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "IT'S A GIRL 👧",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: state.selectedGender == 'girl' ? Colors.white : Colors.pink.shade900,
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
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("SELECTED FILLINGS", style: TextStyle(fontWeight: FontWeight.bold)),
                                        TextButton(
                                          onPressed: () => _showFillingsBottomSheet(context, state, notifier),
                                          child: Text("Edit Mix", style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.bold)),
                                        )
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
                                          final fillingId = state.selectedFillings.keys.elementAt(index);
                                          final count = state.selectedFillings[fillingId]!;
                                          final name = _getMockFillingName(fillingId);

                                          return Container(
                                            width: 80,
                                            margin: const EdgeInsets.only(right: 12),
                                            child: Column(
                                              children: [
                                                Stack(
                                                  alignment: Alignment.topRight,
                                                  children: [
                                                    Image.asset('assets/images/filling.png', height: 50),
                                                    Container(
                                                      padding: const EdgeInsets.all(4),
                                                      decoration: const BoxDecoration(
                                                        color: Color(0xFF49D4D0),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Text("$count", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  name,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
                        onTap: state.isSelectionValid ? () {} : null,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(state.isSelectionValid ? 1.0 : 0.5),
                            borderRadius: BorderRadius.circular(24),
                            border: state.isSelectionValid && state.isBoxFull
                                ? Border.all(color: Theme.of(context).colorScheme.tertiary, width: 2) // Gold glow
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "ADD TO CART (${state.product?.isCustomizable == true ? '${state.currentPieces}/${state.maxPieces} PIECES, ' : ''}₪ ${state.totalPrice.toStringAsFixed(2)})",
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
              const SliverToBoxAdapter(child: SizedBox(height: 40)), // Bottom padding
            ],
          ),
        ],
      ),
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

  void _showFillingsBottomSheet(BuildContext context, ProductBuilderState state, ProductBuilderNotifier notifier) {
    // Capture modal context here so closing the sheet doesn't pop the whole page
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.01, // Allow going near-zero so snap physics can trigger auto-close
              maxChildSize: 0.95,
              expand: false,
              snap: true,
              snapSizes: const [0.4, 0.95], // No snap at bottom, so hard drag → goes to minChildSize → triggers close
              builder: (_, scrollController) {
                return StatefulBuilder(
                  builder: (_, setSheetState) {
                    return NotificationListener<DraggableScrollableNotification>(
                      onNotification: (notification) {
                        // Only close when the sheet has been dragged to near-zero
                        // (well past both snap points). This prevents false triggers
                        // during normal snapping from expanded → compact.
                        if (notification.extent <= 0.05) {
                          Navigator.of(modalContext).pop();
                        }
                        setSheetState(() {});
                        return false;
                      },
                      child: Consumer(
                        builder: (ctx, ref, child) {
                          final sheetState = ref.watch(productBuilderProvider);

                          return LayoutBuilder(
                            builder: (ctx, constraints) {
                              final isExpanded = constraints.maxHeight > MediaQuery.of(ctx).size.height * 0.45;

                              return Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                ),
                                // The scrollController MUST cover the full visible surface.
                                // Putting everything (including handle + header) inside this
                                // scroll view means ANY upward drag on the sheet expands it.
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  child: ConstrainedBox(
                                    // Fill the full sheet height so compact mode has no
                                    // internal content to scroll — drags go straight to the sheet.
                                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Drag handle
                                        Container(
                                          margin: const EdgeInsets.symmetric(vertical: 12),
                                          width: 40,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        // Piece counter header
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text("Customize Mix", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                              Text(
                                                "${sheetState.currentPieces}/${sheetState.maxPieces}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: sheetState.currentPieces > sheetState.maxPieces
                                                      ? Colors.red
                                                      : Theme.of(ctx).colorScheme.tertiary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Divider(height: 1),

                                        // Content — switches between compact and full
                                        AnimatedCrossFade(
                                          duration: const Duration(milliseconds: 250),
                                          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                          // MODE 1: compact horizontal list
                                          firstChild: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                child: Text("Swipe up to expand...", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                              ),
                                              SizedBox(
                                                height: 110,
                                                child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                  itemCount: 10,
                                                  itemBuilder: (context, index) {
                                                    final fillingId = 'fill_$index';
                                                    final name = _getMockFillingName(fillingId);
                                                    final count = sheetState.selectedFillings[fillingId] ?? 0;
                                                    return Container(
                                                      width: 90,
                                                      margin: const EdgeInsets.only(right: 10),
                                                      child: _buildFillingCard(context, fillingId, name, count, notifier, isCompact: true),
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                            ],
                                          ),
                                          // MODE 2: full grid
                                          secondChild: GridView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              childAspectRatio: 0.65,
                                              crossAxisSpacing: 12,
                                              mainAxisSpacing: 16,
                                            ),
                                            itemCount: 10,
                                            itemBuilder: (context, index) {
                                              final fillingId = 'fill_$index';
                                              final name = _getMockFillingName(fillingId);
                                              final count = sheetState.selectedFillings[fillingId] ?? 0;
                                              return _buildFillingCard(context, fillingId, name, count, notifier, isCompact: false);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),

            // --- Pinned Save Button with white backing ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
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
                      onPressed: () => Navigator.of(modalContext).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: const Text("SAVE SELECTIONS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFillingCard(BuildContext context, String fillingId, String name, int count, ProductBuilderNotifier notifier, {bool isCompact = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: count > 0 ? Theme.of(context).colorScheme.tertiary : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // filling.png always shown
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/filling.png', height: isCompact ? 32 : 36, width: 50, fit: BoxFit.contain),
                  // cover.png below filling.png — only in full card mode
                  if (!isCompact) ...([
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 28,
                      width: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          'assets/images/cover.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(height: 28, width: 50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
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
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(7)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => notifier.removeFilling(fillingId),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.remove, size: 14),
                  ),
                ),
                Text("$count", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                GestureDetector(
                  onTap: () => notifier.addFilling(fillingId),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.add, size: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
