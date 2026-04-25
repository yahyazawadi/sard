import 'product.dart';

class CartItem {
  final String id; // Unique ID for this specific cart entry
  final Product product;
  final int selectedVariantIndex;
  final String? selectedGender;
  final double? selectedWeight;
  final Map<String, int>? selectedFillings;
  int quantity;

  CartItem({
    String? id,
    required this.product,
    required this.selectedVariantIndex,
    this.selectedGender,
    this.selectedWeight,
    this.selectedFillings,
    this.quantity = 1,
  }) : id = id ?? (DateTime.now().microsecondsSinceEpoch.toString() + (product.remoteId.isNotEmpty ? product.remoteId : "item"));

  ProductVariant get variant {
    if (product.variants != null && product.variants!.isNotEmpty) {
      if (selectedVariantIndex >= 0 && selectedVariantIndex < product.variants!.length) {
        return product.variants![selectedVariantIndex];
      }
    }
    return ProductVariant()..size = 'Default'..price = 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'selectedVariantIndex': selectedVariantIndex,
      'selectedGender': selectedGender,
      'selectedWeight': selectedWeight,
      'selectedFillings': selectedFillings,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString(),
      product: json['product'] != null ? Product.fromJson(json['product']) : Product(),
      selectedVariantIndex: json['selectedVariantIndex'] ?? 0,
      selectedGender: json['selectedGender'],
      selectedWeight: (json['selectedWeight'] as num?)?.toDouble(),
      selectedFillings: json['selectedFillings'] != null ? Map<String, int>.from(json['selectedFillings']) : null,
      quantity: json['quantity'] ?? 1,
    );
  }

  CartItem copyWith({
    int? quantity,
    Map<String, int>? selectedFillings,
    String? selectedGender,
    double? selectedWeight,
  }) {
    return CartItem(
      id: id,
      product: product,
      selectedVariantIndex: selectedVariantIndex,
      selectedGender: selectedGender ?? this.selectedGender,
      selectedWeight: selectedWeight ?? this.selectedWeight,
      selectedFillings: selectedFillings ?? this.selectedFillings,
      quantity: quantity ?? this.quantity,
    );
  }
}
