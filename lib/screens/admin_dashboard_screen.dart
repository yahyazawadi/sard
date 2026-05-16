import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/cloudflare_product_api.dart';

import '../data/admin_product_store.dart';
import '../models/admin_product_model.dart';
import '../widgets/admin_shared_widgets.dart';
import 'admin_product_creator_screen.dart';
import 'admin_image_upload_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Future<void> openCreator() async {
    final result = await Navigator.push<AdminProductModel>(
      context,
      MaterialPageRoute(builder: (_) => const AdminProductCreatorScreen()),
    );

    if (result != null) {
      if (!mounted) return;
      await context.read<AdminProductProvider>().addProduct(result);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product added')));
    }
  }

  Future<void> editProduct(AdminProductModel oldProduct) async {
    final result = await Navigator.push<AdminProductModel>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminProductCreatorScreen(existingProduct: oldProduct),
      ),
    );

    if (result != null) {
      if (!mounted) return;
      await context.read<AdminProductProvider>().updateProduct(
        oldProduct: oldProduct,
        newProduct: result,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product updated')));
    }
  }



  Future<void> deleteProduct(AdminProductModel product) async {
    await context.read<AdminProductProvider>().deleteProduct(product);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Product deleted')));
  }

  void _showFeaturedSectionEditor(BuildContext context, {AdminFeaturedSection? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FeaturedSectionEditor(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<AdminProductProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3EF),
      appBar: AppBar(
        title: const Text('Chocolate Command Center'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminImageUploadScreen()),
            ),
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: 'Upload Image',
          ),
          IconButton(
            onPressed: () async {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fetching data from database...')),
                );
                final api = CloudflareProductApi();
                final dbProducts = await api.getProducts();

                final allData = {
                  'products': dbProducts.map((p) => p.toJson()).toList(),
                  'featured_sections': productProvider.featuredSections.map((s) => s.toJson()).toList(),
                };
                final jsonString = const JsonEncoder.withIndent('  ').convert(allData);
                await Clipboard.setData(ClipboardData(text: jsonString));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data JSON copied to clipboard!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to fetch from DB: $e'), backgroundColor: Colors.redAccent),
                  );
                }
              }
            },
            icon: const Icon(Icons.code_rounded),
            tooltip: 'Copy All Data JSON',
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: FilledButton.icon(
              onPressed: openCreator,
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              return GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                childAspectRatio: isWide ? 1.7 : 1.25,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  AdminMetricCard(
                    title: 'Daily Revenue',
                    value:
                        '${productProvider.dailyRevenue.toStringAsFixed(2)} NIS',
                    icon: Icons.today_outlined,
                  ),
                  AdminMetricCard(
                    title: 'Weekly Revenue',
                    value:
                        '${productProvider.weeklyRevenue.toStringAsFixed(2)} NIS',
                    icon: Icons.date_range_outlined,
                  ),
                  AdminMetricCard(
                    title: 'Monthly Revenue',
                    value:
                        '${productProvider.monthlyRevenue.toStringAsFixed(2)} NIS',
                    icon: Icons.calendar_month_outlined,
                  ),
                  AdminMetricCard(
                    title: 'Total Revenue',
                    value:
                        '${productProvider.totalRevenue.toStringAsFixed(2)} NIS',
                    icon: Icons.payments_outlined,
                  ),
                  AdminMetricCard(
                    title: 'Inventory Weight',
                    value:
                        '${productProvider.totalInventoryKg.toStringAsFixed(2)} KG',
                    icon: Icons.scale_outlined,
                  ),
                  AdminMetricCard(
                    title: 'Products',
                    value: productProvider.products.length.toString(),
                    icon: Icons.inventory_2_outlined,
                  ),
                  AdminMetricCard(
                    title: 'Active Variants',
                    value: productProvider.activeVariants.toString(),
                    icon: Icons.widgets_outlined,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminImageUploadScreen()),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.brown.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.brown.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, color: Colors.brown.shade700, size: 28),
                          const SizedBox(height: 4),
                          Text(
                            'Upload Image',
                            style: TextStyle(
                              color: Colors.brown.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Products',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (productProvider.products.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Text(
                  'No products yet. Click Add Product to create your first item.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          else
            ...productProvider.products.map(
              (product) => AdminProductCard(
                product: product,
                onEditVariant: (p, v) => editProduct(p),
                onDelete: () => deleteProduct(product),
                onEdit: () => editProduct(product),
              ),
            ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Collections',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              FilledButton.icon(
                onPressed: () => _showFeaturedSectionEditor(context),
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Add Section'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (productProvider.featuredSections.isEmpty)
            AdminInfoBox(
              child: const Text('No featured collections yet. These appear on the home page app banners.'),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: productProvider.featuredSections.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final section = productProvider.featuredSections[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (section.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            section.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.image_outlined),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.titleAr,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              section.titleEn,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${section.productIds.length} Products',
                              style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.w500, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showFeaturedSectionEditor(context, existing: section),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => productProvider.deleteFeaturedSection(section.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          const Text(
            'Category Distribution',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          AdminInfoBox(
            child: productProvider.revenueByCategory.isEmpty
                ? const Text('No sales yet.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: productProvider.revenueByCategory.entries.map((
                      entry,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          '${entry.key}: ${entry.value.toStringAsFixed(2)} NIS',
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Customization Trends',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          AdminInfoBox(
            child: productProvider.customizationTrends.isEmpty
                ? const Text('No customization sales yet.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: productProvider.customizationTrends.entries.map((
                      entry,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text('${entry.key}: ${entry.value} orders'),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedSectionEditor extends StatefulWidget {
  final AdminFeaturedSection? existing;

  const _FeaturedSectionEditor({this.existing});

  @override
  State<_FeaturedSectionEditor> createState() => _FeaturedSectionEditorState();
}

class _FeaturedSectionEditorState extends State<_FeaturedSectionEditor> {
  late TextEditingController titleAr;
  late TextEditingController titleEn;
  late TextEditingController imageUrl;
  List<String> selectedProductIds = [];

  @override
  void initState() {
    super.initState();
    titleAr = TextEditingController(text: widget.existing?.titleAr ?? '');
    titleEn = TextEditingController(text: widget.existing?.titleEn ?? '');
    imageUrl = TextEditingController(text: widget.existing?.imageUrl ?? '');
    selectedProductIds = List<String>.from(widget.existing?.productIds ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<AdminProductProvider>().products;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existing == null ? 'New Featured Section' : 'Edit Section',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: titleAr,
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                labelText: 'العنوان (عربي)',
                hintText: 'التشكيلة المختارة',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: titleEn,
              decoration: const InputDecoration(
                labelText: 'Title (English)',
                hintText: 'Featured Collection',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: imageUrl,
              decoration: const InputDecoration(
                labelText: 'Header Image URL',
                hintText: 'https://...',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Products',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final p = products[index];
                  final isSelected = selectedProductIds.contains(p.id);
                  return CheckboxListTile(
                    title: Text(p.titleEn),
                    subtitle: Text(p.category, style: const TextStyle(fontSize: 12)),
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selectedProductIds.add(p.id);
                        } else {
                          selectedProductIds.remove(p.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final section = AdminFeaturedSection(
                    id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    titleAr: titleAr.text,
                    titleEn: titleEn.text,
                    imageUrl: imageUrl.text,
                    productIds: selectedProductIds,
                  );

                  if (widget.existing == null) {
                    context.read<AdminProductProvider>().addFeaturedSection(section);
                  } else {
                    context.read<AdminProductProvider>().updateFeaturedSection(section);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Save Section'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
