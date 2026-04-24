import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalog_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import '../models/featured_template.dart';
import '../models/category.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../providers/settings_provider.dart';
import '../providers/sync_provider.dart';
import 'collection_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  List<dynamic> _uiFilters = [];
  bool _isFeaturedExpanded = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuredKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadFilters();
    // Auto-sync products on first load (e.g. after login)
    Future.microtask(() => ref.read(syncProvider).performInitialSeed());
  }

  Future<void> _loadFilters() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/ui_navigation.json',
      );
      setState(() {
        _uiFilters = json.decode(jsonString);
      });
    } catch (e) {
      debugPrint('Error loading UI filters: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final featuredAsync = ref.watch(featuredTemplatesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // 1. Logo App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/iconSARD.png', height: 40),
                  const Text(
                    ' v2',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  IconButton(
                    icon: const Icon(Icons.sync, size: 16, color: Colors.grey),
                    onPressed: () async {
                      await ref.read(syncProvider).performInitialSeed();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Syncing data from JSON...'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            // 2. Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'search for chocolate, truffle...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Filter Pills
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _uiFilters.length,
                  itemBuilder: (context, index) {
                    final filter = _uiFilters[index];
                    return _FilterPill(
                      label: filter['label'],
                      isActive: filter['is_active'] ?? false,
                    );
                  },
                ),
              ),
            ),

            // 4. Featured Section
            if (_searchQuery.isEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Featured',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
              ),
              featuredAsync.when(
                data: (templates) {
                  final showAll = templates.length > 2;
                  final itemHeight = 240.0;
                  final itemMargin = 16.0;
                  final totalItemBlock = itemHeight + itemMargin;

                  final collapsedHeight = (itemHeight * 1.3) + itemMargin;
                  final expandedHeight = (totalItemBlock * templates.length);

                  final currentHeight = _isFeaturedExpanded
                      ? expandedHeight
                      : collapsedHeight;
                  const buttonHeight = 64.0; // Total height of button area

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        key: _featuredKey,
                        // Height includes the main content + half the button height for overlap
                        height:
                            (templates.length <= 2
                                ? (totalItemBlock * templates.length)
                                : currentHeight) +
                            8.0, // Reduced from buttonHeight / 2 (32.0) to tighten gap
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            // The List Container
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.fastLinearToSlowEaseIn,
                              height: templates.length <= 2
                                  ? (totalItemBlock * templates.length)
                                  : currentHeight,
                              clipBehavior: Clip.hardEdge,
                              decoration: const BoxDecoration(),
                              child: OverflowBox(
                                alignment: Alignment.topCenter,
                                minHeight: 0,
                                maxHeight: double.infinity,
                                child: Column(
                                  children: [
                                    ...templates.map(
                                      (t) => Container(
                                        height: itemHeight,
                                        width: double.infinity,
                                        margin: EdgeInsets.only(
                                          bottom: itemMargin,
                                        ),
                                        child: _FeaturedCard(template: t),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // The Overlapping Button
                            if (showAll)
                              Positioned(
                                // Position the center of the line exactly at the bottom of the container
                                top:
                                    (templates.length <= 2
                                        ? (totalItemBlock * templates.length)
                                        : currentHeight) -
                                    (buttonHeight / 2),
                                left: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    if (!_scrollController.hasClients) return;

                                    final wasExpanded = _isFeaturedExpanded;
                                    double? targetOffset;

                                    // Capture target BEFORE state change for a stable snapshot
                                    if (wasExpanded) {
                                      final RenderBox? renderBox =
                                          _featuredKey.currentContext
                                                  ?.findRenderObject()
                                              as RenderBox?;
                                      if (renderBox != null) {
                                        final position = renderBox
                                            .localToGlobal(Offset.zero);
                                        targetOffset =
                                            _scrollController.offset +
                                            position.dy -
                                            20;
                                      }
                                    }

                                    setState(
                                      () => _isFeaturedExpanded =
                                          !_isFeaturedExpanded,
                                    );

                                    if (wasExpanded && targetOffset != null) {
                                      _scrollController.animateTo(
                                        targetOffset.clamp(
                                          0,
                                          _scrollController
                                              .position
                                              .maxScrollExtent,
                                        ),
                                        duration: const Duration(
                                          milliseconds: 600,
                                        ),
                                        curve: Curves.fastLinearToSlowEaseIn,
                                      );
                                    }
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    height: buttonHeight,
                                    color: Colors.transparent,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Divider(
                                          color: Colors.grey.shade300,
                                          thickness: 1,
                                        ),
                                        AnimatedRotation(
                                          turns: _isFeaturedExpanded ? 0.5 : 0,
                                          duration: const Duration(
                                            milliseconds: 600,
                                          ),
                                          curve: Curves
                                              .easeOutBack, // Slight overshoot for a organic feel
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.08),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 240,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (e, s) => const SliverToBoxAdapter(child: SizedBox()),
              ),
            ],

            // 5. Dynamic Categories & Products (or Search Results)
            categoriesAsync.when(
              data: (categories) => SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = categories[index];
                  return _CategorySection(
                    category: category,
                    searchQuery: _searchQuery,
                  );
                }, childCount: categories.length),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, s) => SliverFillRemaining(
                child: Center(child: Text('Error loading catalog: $e')),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isActive;
  const _FilterPill({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary.withOpacity(0.8)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final FeaturedTemplate template;
  const _FeaturedCard({required this.template});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: AssetImage(template.bannerUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.center,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              template.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CollectionScreen(template: template),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'try now',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends ConsumerWidget {
  final Category category;
  final String searchQuery;
  const _CategorySection({required this.category, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(
      productsBySectionProvider(category.remoteId),
    );
    final settings = ref.watch(settingsProvider);
    final branch = settings.selectedBranch;

    return productsAsync.when(
      data: (products) {
        final filteredProducts = products.where((p) {
          // 1. Stock Filtering
          final stock = p.branchStock;
          int branchStockCount = 0;
          if (stock != null) {
            if (branch == 'nablus') branchStockCount = stock.nablus ?? 0;
            if (branch == 'bethlehem') branchStockCount = stock.bethlehem ?? 0;
            if (branch == 'ramallah') branchStockCount = stock.ramallah ?? 0;
          } else {
            branchStockCount = 99; // Assume in stock if no stock data
          }

          if (branchStockCount == 0) return false;

          // 2. Search Query
          if (searchQuery.isEmpty) return true;
          return p.nameEn.toLowerCase().contains(searchQuery.toLowerCase()) ||
              p.nameAr.contains(searchQuery);
        }).toList();

        if (filteredProducts.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                category.nameEn == 'Sard Icons'
                    ? 'Popular Products'
                    : category.nameEn,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
            ),
            SizedBox(
              height: 280,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                scrollDirection: Axis.horizontal,
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: filteredProducts[index]);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}

class ProductCard extends ConsumerWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  void _handleAdd(BuildContext context, WidgetRef ref) {
    final variants = product.variants ?? [];
    if (variants.length > 1) {
      // Show variant picker
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Size',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.nameEn} added to cart'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.nameEn} added to cart')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final variants = product.variants ?? [];
    double displayPrice = 0.0;

    if (variants.isNotEmpty) {
      // Find the "starting" price or the price for the smallest size
      // 1. Try to find a variant labeled 'Small'
      // 2. Otherwise, find the lowest price that is greater than 0
      // 3. If all else fails, use the first variant's price
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
    }

    final gender = product.gender;

    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    image: DecorationImage(
                      image: AssetImage(product.imageUrl),
                      fit: BoxFit.cover,
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
                            ? Colors.blue.withOpacity(0.8)
                            : Colors.pink.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        gender == 'boy' ? Icons.male : Icons.female,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height:
                  105, // Fixed height for the text content area to ensure stability
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.nameEn,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.section,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${displayPrice.toStringAsFixed(0)} ₪',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      InkWell(
                        onTap: () => _handleAdd(context, ref),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
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
    ));
  }
}
