import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/admin_product_store.dart';
import '../models/admin_product_model.dart';

class AdminMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const AdminMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: Colors.brown.shade700),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title),
        ],
      ),
    );
  }
}

class AdminInfoBox extends StatelessWidget {
  final Widget child;

  const AdminInfoBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: child,
    );
  }
}

class AdminSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const AdminSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              trailing ?? const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class AdminJsonDialog extends StatelessWidget {
  final AdminProductModel product;

  const AdminJsonDialog({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final jsonText = encoder.convert(product.toJson());

    return AlertDialog(
      title: const Text('Product JSON'),
      content: SizedBox(
        width: 700,
        child: SingleChildScrollView(child: SelectableText(jsonText)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class AdminProductCard extends StatelessWidget {
  final AdminProductModel product;
  final void Function(AdminProductModel product, AdminProductVariant variant)
  onEditVariant;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AdminProductCard({
    super.key,
    required this.product,
    required this.onEditVariant,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF1DBBC),
            image: product.mainImage.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(product.mainImage),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: product.mainImage.isEmpty
              ? const Icon(Icons.image_not_supported_outlined, color: Color(0xFF5B301F))
              : null,
        ),
        title: Text(
          product.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${product.category} | ${product.variants.length} variants',
        ),
        children: [
          const SizedBox(height: 10),
          ...product.variants.map(
            (variant) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F3EF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      image: variant.image != null && variant.image!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(variant.image!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: variant.image == null || variant.image!.isEmpty
                        ? const Icon(Icons.image_outlined, size: 20, color: Color(0xFF5B301F))
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      '${variant.title}\nPrice: ${variant.price} | Weight: ${variant.weightG}g | Stock: ${variant.stockQuantity}',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => onEditVariant(product, variant),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5B301F),
                      side: const BorderSide(color: Color(0xFF5B301F)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AdminJsonDialog(product: product),
                  );
                },
                icon: const Icon(Icons.code),
                label: const Text('View JSON'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final provider = context.read<AdminProductProvider>();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Optimizing image to WebP...')),
                  );
                  try {
                    await provider.optimizeToWebP(product);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Successfully converted to WebP!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Optimization failed: $e'),
                          backgroundColor: Colors.redAccent,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.bolt_outlined, color: Colors.orange),
                label: const Text('Optimize WebP'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange.shade800,
                  side: BorderSide(color: Colors.orange.shade200),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
