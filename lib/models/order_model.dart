import 'cart_item.dart';

class OrderModel {
  final String id;
  final DateTime date;
  final List<CartItem> items;
  final double total;
  final String status; // e.g., 'DELIVERED', 'PENDING'

  OrderModel({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    this.status = 'DELIVERED',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'total': total,
      'status': status,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      items: (json['items'] as List).map((e) => CartItem.fromJson(e)).toList(),
      total: (json['total'] as num).toDouble(),
      status: json['status'] ?? 'DELIVERED',
    );
  }
}
