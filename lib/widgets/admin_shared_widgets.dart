import 'dart:convert';

import 'package:flutter/material.dart';

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
            color: Colors.brown.withOpacity(0.08),
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
            color: Colors.brown.withOpacity(0.06),
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
              if (trailing != null) trailing!,
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
  onPurchase;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AdminProductCard({
    super.key,
    required this.product,
    required this.onPurchase,
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
        tilePadding: EdgeInsets.zero,
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
                  Expanded(
                    child: Text(
                      '${variant.title}\nPrice: ${variant.price} | Weight: ${variant.weightG}g | Stock: ${variant.stockQuantity}',
                    ),
                  ),
                  FilledButton(
                    onPressed: () => onPurchase(product, variant),
                    child: const Text('Purchase'),
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
