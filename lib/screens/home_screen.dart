import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/catalog_provider.dart';
import '../providers/cart_provider.dart';
import '../screens/main_wrapper_screen.dart';
import '../models/product.dart';
import '../models/featured_template.dart';
import '../models/category.dart';
import '../providers/settings_provider.dart';
import '../providers/sync_provider.dart';
import 'collection_screen.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_routes.dart';
import 'notifications_screen.dart';
import '../providers/wishlist_provider.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/search_widgets.dart';
import '../custom/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../l10n/app_localizations.dart';
import '../providers/isar_provider.dart';

final homeResetProvider = StateProvider<int>((ref) => 0);
final isSearchModeProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // bool _isFeaturedExpanded = false;
  final ScrollController _scrollController = ScrollController();
  // final GlobalKey _featuredKey = GlobalKey();

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
    await prefs.setStringList(
      'last_search_categories',
      _selectedCategoryIds.toList(),
    );
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
      final lastCategories =
          prefs.getStringList('last_search_categories') ?? [];

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

    final l10n = AppLocalizations.of(context)!;
    final languageCode = l10n.localeName;
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final featuredAsync = ref.watch(featuredTemplatesProvider);

    return RefreshIndicator(
      color: AppTheme.highContrastGold,
      backgroundColor: AppTheme.bgDarkTeal,
      onRefresh: () async {
        await ref.read(syncProvider).performInitialSeed(forceRemote: true);
        // We might want to invalidate the providers to force a re-fetch from Isar
        ref.invalidate(categoriesProvider);
        ref.invalidate(featuredTemplatesProvider);
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 1, 2, 3. Combined Glassy Top Bar
          SliverAppBar(
            pinned: false,
            floating: true,
            snap: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            expandedHeight: _isSearchMode ? 160 : 200,
            collapsedHeight: _isSearchMode ? 130 : 160,
            toolbarHeight: 60,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.light
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: theme.brightness == Brightness.light
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.1),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: FlexibleSpaceBar(
                    background: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top,
                      ),
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            // Logo / Title Row
                            SizedBox(
                              height: 54,
                              child: Row(
                                children: [
                                  if (!_isSearchMode)
                                    IconButton(
                                      icon: Icon(
                                        Icons.settings_outlined,
                                        color: AppTheme.getIconColor(theme),
                                        size: 24,
                                      ),
                                      onPressed: () =>
                                          context.push(AppRoutes.settings),
                                    )
                                  else
                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 20,
                                        color: AppTheme.getIconColor(theme),
                                      ),
                                      onPressed: _exitSearchMode,
                                    ),
                                  Expanded(
                                    child: Center(
                                      child: _isSearchMode
                                          ? Text(
                                              l10n.search,
                                              style:
                                                  theme.textTheme.headlineSmall,
                                            )
                                          : const SizedBox(
                                              height: 40,
                                            ), // Logo placeholder
                                    ),
                                  ),
                                  if (!_isSearchMode)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.notifications_none_rounded,
                                              color: AppTheme.getIconColor(
                                                theme,
                                              ),
                                              size: 26,
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const NotificationsScreen(),
                                                  ),
                                                ),
                                          ),
                                          Positioned(
                                            right: 12,
                                            top: 12,
                                            child: Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    const SizedBox(width: 48),
                                ],
                              ),
                            ),
                            // Search Bar
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
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
                            // Categories
                            categoriesAsync.when(
                              data: (categories) => SizedBox(
                                height: 40,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const AlwaysScrollableScrollPhysics(
                                    parent: ClampingScrollPhysics(),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  itemCount: categories.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      final isAllSelected =
                                          _selectedCategoryIds.isEmpty;
                                      return SardCategoryChip(
                                        label: l10n.all,
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
                                    final isSelected = _selectedCategoryIds
                                        .contains(category.remoteId);
                                    return SardCategoryChip(
                                      label: languageCode == 'ar'
                                          ? category.nameAr
                                          : category.nameEn,
                                      isSelected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedCategoryIds.add(
                                              category.remoteId,
                                            );
                                            _isSearchMode = true;
                                          } else {
                                            _selectedCategoryIds.remove(
                                              category.remoteId,
                                            );
                                          }
                                        });
                                        _saveSearchHistory();
                                      },
                                    );
                                  },
                                ),
                              ),
                              loading: () => const SizedBox(height: 40),
                              error: (error, stackTrace) =>
                                  const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. Content (Featured & Catalog OR Search Results)
          if (!_isSearchMode) ...[
            // Default View: Featured Section
            featuredAsync.when(
              data: (templates) {
                debugPrint('!!! HomeScreen: templates.length = ${templates.length}');
                if (templates.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                
                const itemHeight = 220.0;
                return SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                        child: Text(AppLocalizations.of(context)!.featured, style: theme.textTheme.headlineSmall),
                      ),
                      SizedBox(
                        height: itemHeight,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          itemCount: templates.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 16),
                          itemBuilder: (context, index) => SizedBox(
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: _FeaturedCard(template: templates[index]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, s) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Featured Error: $e', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),

            // 5. Dynamic Categories & Products
            categoriesAsync.when(
              data: (categories) => SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = categories[index];
                  return _CategorySection(
                    category: category,
                    showDivider: index < categories.length - 1,
                  );
                }, childCount: categories.length),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, s) => SliverFillRemaining(
                child: Center(child: Text(l10n.errorLoading(e.toString()))),
              ),
            ),
          ] else ...[
            // Search Results Mode
            _SearchResultsGrid(
              query: _searchQuery,
              selectedCategoryIds: _selectedCategoryIds,
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final FeaturedTemplate template;
  const _FeaturedCard({required this.template});

  void _navigate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CollectionScreen(template: template),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _navigate(context),
      child: Container(
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius + 8),
          border: Border.all(
            color: AppTheme.getFeaturedBorderColor(theme),
            width: 2.0, // Increased width as requested
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius + 6.5),
          child: Stack(
            fit: StackFit.expand,
            children: [
              template.bannerUrl.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: template.bannerUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.black12,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/allchocolatetype3to2.jpg',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(template.bannerUrl, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.getTitle(
                        AppLocalizations.of(context)!.localeName,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: AppTheme.highContrastGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (template.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        template.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // "try now" chip
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 40,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: AppTheme.getCardColor(theme),
                            borderRadius: BorderRadius.circular(
                              AppTheme.buttonRadius,
                            ),
                            border: Border.all(
                              color: AppTheme.getOnCardColor(
                                theme,
                              ).withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.tryNow,
                            textAlign: TextAlign.center,
                            strutStyle: const StrutStyle(
                              fontSize: 14,
                              height: 1.0,
                              forceStrutHeight: true,
                              leading: 0,
                            ),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppTheme.getOnCardColor(theme),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              height: 1.0,
                              leadingDistribution: TextLeadingDistribution.even,
                            ),
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
      ),
    );
  }
}

class _CategorySection extends ConsumerWidget {
  final Category category;
  final bool showDivider;
  const _CategorySection({required this.category, this.showDivider = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(
      productsBySectionProvider(category.remoteId),
    );
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final branch = settings.selectedBranch;
    final l10n = AppLocalizations.of(context)!;

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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                l10n.localeName == 'ar' ? category.nameAr : category.nameEn,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            SizedBox(
              height: 275,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: filteredProducts[index]);
                },
              ),
            ),
            if (showDivider)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                child: Divider(
                  color: AppTheme.textPrimaryDark.withValues(alpha: 0.1),
                  thickness: 1,
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
    final theme = Theme.of(context);
    final variants = product.variants ?? [];
    if (variants.length > 1) {
      // Show variant picker
      showModalBottomSheet(
        context: context,
        backgroundColor: theme.scaffoldBackgroundColor,
        showDragHandle: false, // Using custom handle for color control
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
                  // Custom Handle
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
                          "${product.getName(AppLocalizations.of(context)!.localeName)} ${AppLocalizations.of(context)!.addedToCart}",
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
      SardSnackBar.show(
        context,
        "${product.getName(AppLocalizations.of(context)!.localeName)} ${AppLocalizations.of(context)!.addedToCart}",
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
    final l10n = AppLocalizations.of(context)!;
    final languageCode = l10n.localeName;
    final variants = product.variants ?? [];
    double displayPrice = 0.0;

    final cartItems = ref.watch(cartProvider);
    final productItems = cartItems
        .where((item) => item.product.remoteId == product.remoteId)
        .toList();
    final totalQty = productItems.fold(0, (sum, item) => sum + item.quantity);
    final isWishlisted = ref.watch(wishlistProvider).contains(product.remoteId);

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
    } else if (product.isBulkProduct && (product.bulkBoxes?.isNotEmpty ?? false)) {
      // For bulk products, show the cheapest box price
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
          width: 152,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(theme),
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            border: Border.all(
              color: AppTheme.getCardBorderColor(theme),
              width: 1.5,
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
                        color: Colors.transparent,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppTheme.cardRadius),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Hero(
                        tag: 'product_${product.remoteId}',
                        child: product.imageUrl.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: product.imageUrl,
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
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
                            : Image.asset(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
                                cacheWidth: 300,
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
                            child: Icon(
                              isWishlisted
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_outline_rounded,
                              color: isWishlisted
                                  ? Colors.red
                                  : AppTheme.highContrastGold,
                              size: 18,
                            ),
                          ),
                          // Larger invisible hitbox for the heart
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  final wasWishlisted = ref
                                      .read(wishlistProvider)
                                      .contains(product.remoteId);
                                  ref
                                      .read(wishlistProvider.notifier)
                                      .toggleWishlist(product.remoteId);

                                  if (wasWishlisted) {
                                    SardSnackBar.show(
                                      context,
                                      "${product.getName(languageCode)} ${l10n.removed}",
                                      action: SnackBarAction(
                                        label: l10n.undo,
                                        onPressed: () => ref
                                            .read(wishlistProvider.notifier)
                                            .toggleWishlist(product.remoteId),
                                      ),
                                    );
                                  } else {
                                    SardSnackBar.show(
                                      context,
                                      "${product.getName(languageCode)} ${l10n.addedToCart}",
                                      action: SnackBarAction(
                                        label: l10n.myWishlist,
                                        onPressed: () =>
                                            ref
                                                    .read(
                                                      mainWrapperPageProvider
                                                          .notifier,
                                                    )
                                                    .state =
                                                1,
                                      ),
                                    );
                                  }
                                },
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: SizedBox(
                  height: 80, // Further reduced to maximize image space
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                        ],
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
                          if (totalQty == 0)
                            Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getCardColor(theme),
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.buttonRadius / 2,
                                    ),
                                    border: Border.all(
                                      color: AppTheme.getButtonBorderColor(
                                        theme,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: onCardColor,
                                    size: 18,
                                  ),
                                ),
                                Positioned.fill(
                                  child: InkWell(
                                    onTap: () => _handleAdd(context, ref),
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.buttonRadius / 2,
                                    ),
                                  ),
                                ),
                                // Invisible large hitbox
                                Positioned(
                                  top: -10,
                                  bottom: -10,
                                  left: -10,
                                  right: -10,
                                  child: GestureDetector(
                                    onTap: () => _handleAdd(context, ref),
                                    behavior: HitTestBehavior.opaque,
                                  ),
                                ),
                              ],
                            )
                          else
                            Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                // 1. The Visual Pill
                                Container(
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppTheme.getCardColor(theme),
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.buttonRadius / 2,
                                    ),
                                    border: Border.all(
                                      color: AppTheme.getButtonBorderColor(
                                        theme,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Icon(
                                          Icons.remove_rounded,
                                          color: onCardColor,
                                          size: 16,
                                        ),
                                      ),
                                      // The number with a visual nudge UP
                                      Transform.translate(
                                        offset: const Offset(0, 1),
                                        child: Text(
                                          '$totalQty',
                                          style: TextStyle(
                                            color: onCardColor,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                            height: 1.0,
                                            leadingDistribution:
                                                TextLeadingDistribution.even,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Icon(
                                          Icons.add_rounded,
                                          color: onCardColor,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // 2. Large Invisible Hitboxes
                                // Minus Button (Left half)
                                Positioned(
                                  left: -10,
                                  top: -10,
                                  bottom: -10,
                                  width: 50,
                                  child: GestureDetector(
                                    onTap: () {
                                      final target = productItems.last;
                                      ref
                                          .read(cartProvider.notifier)
                                          .updateQuantity(
                                            target.id,
                                            target.quantity - 1,
                                          );
                                    },
                                    behavior: HitTestBehavior.opaque,
                                  ),
                                ),
                                // Plus Button (Right half) → navigate to detail
                                Positioned(
                                  right: -10,
                                  top: -10,
                                  bottom: -10,
                                  width: 50,
                                  child: GestureDetector(
                                    onTap: () => context.push(
                                      '${AppRoutes.productDetail}?id=${product.remoteId}',
                                      extra: product,
                                    ),
                                    behavior: HitTestBehavior.opaque,
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
          final matchesSearch =
              query.isEmpty ||
              p.nameEn.toLowerCase().contains(query.toLowerCase()) ||
              p.nameAr.contains(query);

          // c. Category Filter
          final matchesCategory =
              selectedCategoryIds.isEmpty ||
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
                  Icon(
                    Icons.search_off_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noProductsFound,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
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
              childAspectRatio: 0.62,
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
