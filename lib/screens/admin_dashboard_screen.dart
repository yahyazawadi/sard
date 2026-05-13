import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/admin_product_store.dart';
import '../models/admin_product_model.dart';
import '../widgets/admin_shared_widgets.dart';
import 'admin_product_creator_screen.dart';

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
      await context.read<AdminProductProvider>().addProduct(result);

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
      await context.read<AdminProductProvider>().updateProduct(
        oldProduct: oldProduct,
        newProduct: result,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product updated')));
    }
  }

  Future<void> purchaseVariant(
    AdminProductModel product,
    AdminProductVariant variant,
  ) async {
    final success = await context.read<AdminProductProvider>().purchaseVariant(
      product: product,
      variant: variant,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This variant is out of stock')),
      );
    }
  }

  Future<void> deleteProduct(AdminProductModel product) async {
    await context.read<AdminProductProvider>().deleteProduct(product);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Product deleted')));
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<AdminProductProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3EF),
      appBar: AppBar(
        title: const Text('Chocolate Command Center'),
        actions: [
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
                onPurchase: purchaseVariant,
                onDelete: () => deleteProduct(product),
                onEdit: () => editProduct(product),
              ),
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
