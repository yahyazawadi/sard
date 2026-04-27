import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../custom/app_theme.dart';
import '../models/featured_template.dart';
import '../providers/catalog_provider.dart';
import 'home_screen.dart'; // To reuse _ProductCard if possible, or I'll copy the logic

class CollectionScreen extends ConsumerWidget {
  final FeaturedTemplate template;

  const CollectionScreen({super.key, required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = template.productIds ?? [];
    final productsAsync = ref.watch(productsByIdsProvider(ids));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Immersive Header Section
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppTheme.gradientStart,
              ),
              onPressed: () => context.pop(),
            ),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    template.bannerUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        stops: const [0.0, 0.4, 1.0],
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.title,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template.subtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Collection Grid
          productsAsync.when(
            data: (products) {
              if (products.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No products in this collection')),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return ProductCard(product: products[index]);
                    },
                    childCount: products.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, s) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// I need to export _ProductCard or make it public in HomeScreen.dart
// For now, I'll assume I've made ProductCard public in HomeScreen.dart
