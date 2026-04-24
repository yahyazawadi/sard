import 'product.dart';

class CartItem {
  final Product product;
  final int selectedVariantIndex;
  int quantity;

  CartItem({
    required this.product,
    this.selectedVariantIndex = 0,
    this.quantity = 1,
  });

  ProductVariant get variant {
    if (product.variants != null && product.variants!.isNotEmpty) {
      if (selectedVariantIndex < product.variants!.length) {
        return product.variants![selectedVariantIndex];
      }
    }
    // Return a dummy variant if none exists to avoid crashes in calculations
    return ProductVariant()..size = 'Default'..price = 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'selectedVariantIndex': selectedVariantIndex,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      selectedVariantIndex: json['selectedVariantIndex'] ?? 0,
      quantity: json['quantity'],
    );
  }
}
