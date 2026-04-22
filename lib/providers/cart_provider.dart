import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chocolate.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  List<CartItem> _items = [];

  CartProvider(this._prefs) {
    _loadCart();
  }

  List<CartItem> get items => _items;

  double get totalPrice {
    return _items.fold(0, (total, item) => total + (item.chocolate.price * item.quantity));
  }

  int get totalItems {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  void addToCart(Chocolate chocolate) {
    final existingIndex = _items.indexWhere((item) => item.chocolate.id == chocolate.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(CartItem(chocolate: chocolate));
    }
    _saveCart();
    notifyListeners();
  }

  void removeFromCart(String chocolateId) {
    _items.removeWhere((item) => item.chocolate.id == chocolateId);
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(String chocolateId, int quantity) {
    final index = _items.indexWhere((item) => item.chocolate.id == chocolateId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  void _loadCart() {
    final cartString = _prefs.getString('cart_items');
    if (cartString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cartString);
        _items = decoded.map((item) => CartItem.fromJson(item)).toList();
      } catch (e) {
        debugPrint('Error loading cart: $e');
        _items = [];
      }
    }
    notifyListeners();
  }

  void _saveCart() {
    final cartString = jsonEncode(_items.map((item) => item.toJson()).toList());
    _prefs.setString('cart_items', cartString);
  }
}
