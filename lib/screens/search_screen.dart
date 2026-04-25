import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalog_provider.dart';
import '../providers/isar_provider.dart';
import '../providers/settings_provider.dart';
import '../models/product.dart';
import 'home_screen.dart'; // To reuse ProductCard
import 'package:isar/isar.dart';
import '../widgets/search_widgets.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialCategoryId;
  const SearchScreen({super.key, this.initialCategoryId});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _searchQuery = '';
  final Set<String> _selectedCategoryIds = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCategoryId != null) {
      _selectedCategoryIds.add(widget.initialCategoryId!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final isar = ref.watch(isarProvider);
    final settings = ref.watch(settingsProvider);
    final branch = settings.selectedBranch;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. Premium Search Bar Area
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (Navigator.of(context).canPop())
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      const Text(
                        'Search Catalog',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'serif',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SardSearchBar(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    onClear: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  ),
                ],
              ),
            ),

            // 2. Dynamic Categories (OR Filter)
            categoriesAsync.when(
              data: (categories) {
                return Container(
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = _selectedCategoryIds.contains(category.remoteId);
                      return SardCategoryChip(
                        label: category.nameEn,
                        isSelected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategoryIds.add(category.remoteId);
                            } else {
                              _selectedCategoryIds.remove(category.remoteId);
                            }
                          });
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox(height: 60),
              error: (e, s) => const SizedBox.shrink(),
            ),

            // 3. Results Grid (AND filter logic)
            Expanded(
              child: StreamBuilder<List<Product>>(
                stream: isar.products.where().watch(fireImmediately: true),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allProducts = snapshot.data!;
                  final filteredProducts = allProducts.where((p) {
                    // a. Stock Filtering (Global logic)
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

                    // b. Search Text Filter (AND)
                    final matchesSearch = _searchQuery.isEmpty ||
                        p.nameEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        p.nameAr.contains(_searchQuery);

                    // c. Category Filter (OR between categories, AND with search)
                    final matchesCategory = _selectedCategoryIds.isEmpty ||
                        _selectedCategoryIds.contains(p.section);

                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 18),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: filteredProducts[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
