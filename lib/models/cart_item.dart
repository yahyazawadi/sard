import 'chocolate.dart';

class CartItem {
  final Chocolate chocolate;
  int quantity;

  CartItem({
    required this.chocolate,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'chocolate': chocolate.toJson(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      chocolate: Chocolate.fromJson(json['chocolate']),
      quantity: json['quantity'],
    );
  }
}
