import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalog_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import '../models/featured_template.dart';
import '../models/category.dart';
import '../providers/settings_provider.dart';
import '../providers/sync_provider.dart';
import 'collection_screen.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_routes.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/search_widgets.dart';
import '../custom/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/isar_provider.dart';
import 'package:isar/isar.dart';

final homeResetProvider = StateProvider<int>((ref) => 0);
final isSearchModeProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isFeaturedExpanded = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuredKey = GlobalKey();

  // Search Integration
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _selectedCategoryIds = {};
  bool _isSearchMode = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    // Auto-sync products on first load (e.g. after login)
    Future.microtask(() => ref.read(syncProvider).performInitialSeed());
  }



  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final query = prefs.getString('last_search_query') ?? '';
    final categories = prefs.getStringList('last_search_categories') ?? [];
    
    if (mounted) {
      setState(() {
        _searchQuery = query;
        _searchController.text = query;
        _selectedCategoryIds.addAll(categories);
      });
    }
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_search_query', _searchQuery);
    await prefs.setStringList('last_search_categories', _selectedCategoryIds.toList());
  }

  void _exitSearchMode() {
    setState(() {
      _isSearchMode = false;
      _searchQuery = '';
      _searchController.clear();
      _selectedCategoryIds.clear();
    });
    ref.read(isSearchModeProvider.notifier).state = false;
    FocusScope.of(context).unfocus();
  }

  void _enterSearchMode() async {
    if (!_isSearchMode) {
      // If entering fresh, restore the last saved search as "autofill"
      final prefs = await SharedPreferences.getInstance();
      final lastQuery = prefs.getString('last_search_query') ?? '';
      final lastCategories = prefs.getStringList('last_search_categories') ?? [];

      setState(() {
        _isSearchMode = true;
        if (_searchQuery.isEmpty && _selectedCategoryIds.isEmpty) {
          _searchQuery = lastQuery;
          _searchController.text = lastQuery;
          _selectedCategoryIds.addAll(lastCategories);
        }
      });
      ref.read(isSearchModeProvider.notifier).state = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to reset signal
    ref.listen(homeResetProvider, (prev, next) {
      if (next > 0) {
        _exitSearchMode();
      }
    });

    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final featuredAsync = ref.watch(featuredTemplatesProvider);

    return SafeArea(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 1. Logo App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: theme.appBarTheme.backgroundColor,
            elevation: 0,
            title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isSearchMode
                  ? Row(
                      key: const ValueKey('search_title'),
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                          onPressed: _exitSearchMode,
                        ),
                        Text(
                          'Search',
                          style: theme.textTheme.headlineSmall,
                        ),
                      ],
                    )
                  : TweenAnimationBuilder<double>(
                      key: const ValueKey('logo_title'),
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.fastOutSlowIn,
                            );
                          }
                        },
                        child: Image.asset(
                          'assets/images/TealLogo.png',
                          height: 45,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
            ),
          ),

          // 2. Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SardSearchBar(
                controller: _searchController,
                onTap: _enterSearchMode,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                    if (val.isNotEmpty) _isSearchMode = true;
                  });
                  _saveSearchHistory();
                },
                onClear: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                  _saveSearchHistory();
                },
              ),
            ),
          ),

          // 3. Dynamic Category Filter Pills
          SliverToBoxAdapter(
            child: categoriesAsync.when(
              data: (categories) => SizedBox(
                height: 56,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isAllSelected = _selectedCategoryIds.isEmpty;
                      return SardCategoryChip(
                        label: 'ALL',
                        isSelected: isAllSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategoryIds.clear();
                            _isSearchMode = true;
                          });
                          _saveSearchHistory();
                        },
                      );
                    }
                    final category = categories[index - 1];
                    final isSelected = _selectedCategoryIds.contains(category.remoteId);
                    return SardCategoryChip(
                      label: category.nameEn,
                      isSelected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategoryIds.add(category.remoteId);
                            _isSearchMode = true;
                          } else {
                            _selectedCategoryIds.remove(category.remoteId);
                          }
                        });
                        _saveSearchHistory();
                      },
                    );
                  },
                ),
              ),
              loading: () => const SizedBox(height: 56),
              error: (error, stackTrace) => const SizedBox.shrink(),
            ),
          ),

          // 4. Content (Featured & Catalog OR Search Results)
          if (!_isSearchMode) ...[
            // Default View: Featured Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text('Featured', style: theme.textTheme.headlineSmall),
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
                final currentHeight = _isFeaturedExpanded ? expandedHeight : collapsedHeight;
                const buttonHeight = 64.0;

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      key: _featuredKey,
                      height: (templates.length <= 2 ? (totalItemBlock * templates.length) : currentHeight) + 8.0,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.fastLinearToSlowEaseIn,
                            height: templates.length <= 2 ? (totalItemBlock * templates.length) : currentHeight,
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(),
                            child: OverflowBox(
                              alignment: Alignment.topCenter,
                              minHeight: 0,
                              maxHeight: double.infinity,
                              child: Column(
                                children: [
                                  ...templates.map((t) => Container(
                                        height: itemHeight,
                                        width: double.infinity,
                                        margin: EdgeInsets.only(bottom: itemMargin),
                                        child: _FeaturedCard(template: t),
                                      )),
                                ],
                              ),
                            ),
                          ),
                          if (showAll)
                            Positioned(
                              top: (templates.length <= 2 ? (totalItemBlock * templates.length) : currentHeight) - (buttonHeight / 2),
                              left: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  if (!_scrollController.hasClients) return;
                                  final wasExpanded = _isFeaturedExpanded;
                                  double? targetOffset;
                                  if (wasExpanded) {
                                    final RenderBox? renderBox = _featuredKey.currentContext?.findRenderObject() as RenderBox?;
                                    if (renderBox != null) {
                                      final position = renderBox.localToGlobal(Offset.zero);
                                      targetOffset = _scrollController.offset + position.dy - 20;
                                    }
                                  }
                                  setState(() => _isFeaturedExpanded = !_isFeaturedExpanded);
                                  if (wasExpanded && targetOffset != null) {
                                    _scrollController.animateTo(
                                      targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
                                      duration: const Duration(milliseconds: 600),
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
                                      Divider(color: Colors.grey.shade300, thickness: 1),
                                      AnimatedRotation(
                                        turns: _isFeaturedExpanded ? 0.5 : 0,
                                        duration: const Duration(milliseconds: 600),
                                        curve: Curves.easeOutBack,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.grey.shade300),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.08),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary, size: 24),
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
              loading: () => const SliverToBoxAdapter(child: SizedBox(height: 240, child: Center(child: CircularProgressIndicator()))),
              error: (e, s) => const SliverToBoxAdapter(child: SizedBox()),
            ),

            // 5. Dynamic Categories & Products
            categoriesAsync.when(
              data: (categories) => SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = categories[index];
                  return _CategorySection(category: category);
                }, childCount: categories.length),
              ),
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, s) => SliverFillRemaining(child: Center(child: Text('Error loading catalog: $e'))),
            ),
          ] else ...[
            // Search Results Mode
            _SearchResultsGrid(
              query: _searchQuery,
              selectedCategoryIds: _selectedCategoryIds,
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
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
        borderRadius: BorderRadius.circular(AppTheme.cardRadius + 8),
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: AppTheme.cardShadow,
        image: DecorationImage(
          image: AssetImage(template.bannerUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius + 6), // Slightly smaller to fit inside border
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.center,
            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
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
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
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
                  borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
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
  const _CategorySection({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(
      productsBySectionProvider(category.remoteId),
    );
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
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
          return true;
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
                style: theme.textTheme.headlineSmall,
              ),
            ),
            SizedBox(
              height: 300,
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
                        SardSnackBar.show(
                          context,
                          "${product.nameEn} added to cart",
                          action: SnackBarAction(
                            label: "VIEW CART",
                            onPressed: () => context.push(AppRoutes.cart),
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
      SardSnackBar.show(
        context,
        "${product.nameEn} added to cart",
        action: SnackBarAction(
          label: "VIEW CART",
          onPressed: () => context.push(AppRoutes.cart),
        ),
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
        context.push(AppRoutes.productDetail, extra: product);
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(
            color: AppTheme.accentGold.withValues(alpha: 0.4),
            width: 1,
          ),
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
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppTheme.cardRadius),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Hero(
                      tag: 'product_${product.remoteId}',
                      child: Image.asset(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
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
                          gender == 'boy' ? Icons.male_rounded : Icons.female_rounded,
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
                    120, // Increased from 105 to absorb text size with new premium fonts
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
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 200),
                            tween: Tween(begin: 1.0, end: 1.0), // No auto animation, just structure
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              );
                            },
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
    );
  }
}

class _SearchResultsGrid extends ConsumerWidget {
  final String query;
  final Set<String> selectedCategoryIds;

  const _SearchResultsGrid({
    required this.query,
    required this.selectedCategoryIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isar = ref.watch(isarProvider);
    final settings = ref.watch(settingsProvider);
    final branch = settings.selectedBranch;

    return StreamBuilder<List<Product>>(
      stream: isar.products.where().watch(fireImmediately: true),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final allProducts = snapshot.data!;
        final filteredProducts = allProducts.where((p) {
          // a. Stock Filtering
          final stock = p.branchStock;
          int branchStockCount = 0;
          if (stock != null) {
            if (branch == 'nablus') branchStockCount = stock.nablus ?? 0;
            if (branch == 'bethlehem') branchStockCount = stock.bethlehem ?? 0;
            if (branch == 'ramallah') branchStockCount = stock.ramallah ?? 0;
          } else {
            branchStockCount = 99;
          }
          if (branchStockCount == 0) return false;

          // b. Search Text Filter
          final matchesSearch = query.isEmpty ||
              p.nameEn.toLowerCase().contains(query.toLowerCase()) ||
              p.nameAr.contains(query);

          // c. Category Filter
          final matchesCategory = selectedCategoryIds.isEmpty ||
              selectedCategoryIds.contains(p.section);

          return matchesSearch && matchesCategory;
        }).toList();

        if (filteredProducts.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => ProductCard(product: filteredProducts[index]),
              childCount: filteredProducts.length,
            ),
          ),
        );
      },
    );
  }
}
