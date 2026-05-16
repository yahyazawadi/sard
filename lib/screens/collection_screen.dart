import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../widgets/sard_background.dart';

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
      backgroundColor: Colors.transparent,
      body: SardBackground(
        child: CustomScrollView(
          slivers: [
            // 1. Immersive Header Section
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => context.pop(),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    template.bannerUrl.startsWith('http')
                        ? Image.network(
                            template.bannerUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset('assets/images/allchocolatetype3to2.jpg', fit: BoxFit.cover),
                          )
                        : Image.asset(
                            template.bannerUrl,
                            fit: BoxFit.cover,
                          ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
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
                            template.getTitle(AppLocalizations.of(context)!.localeName),
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
                  return SliverFillRemaining(
                    child: Center(child: Text(AppLocalizations.of(context)!.noProductsInCollection)),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.68,
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
                child: Center(child: Text(AppLocalizations.of(context)!.errorLoading(e.toString()))),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// I need to export _ProductCard or make it public in HomeScreen.dart
// For now, I'll assume I've made ProductCard public in HomeScreen.dart
