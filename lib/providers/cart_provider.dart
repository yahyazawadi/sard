import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'prefs_provider.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    final prefs = ref.watch(prefsProvider);
    final cartString = prefs.getString('cart_items');
    if (cartString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cartString);
        return decoded.map((item) => CartItem.fromJson(item)).toList();
      } catch (e) {
        debugPrint('Error loading cart: $e');
      }
    }
    return [];
  }

  double get totalPrice {
    return state.fold(0, (total, item) => total + (item.variant.price * item.quantity));
  }

  int get totalItems {
    return state.fold(0, (total, item) => total + item.quantity);
  }

  void addToCart(Product product, {int variantIndex = 0}) {
    final existingIndex = state.indexWhere(
      (item) => item.product.remoteId == product.remoteId && item.selectedVariantIndex == variantIndex
    );
    
    if (existingIndex >= 0) {
      final newList = List<CartItem>.from(state);
      newList[existingIndex].quantity += 1;
      state = newList;
    } else {
      state = [...state, CartItem(product: product, selectedVariantIndex: variantIndex)];
    }
    _saveCart();
  }

  void removeFromCart(String remoteId, int variantIndex) {
    state = state.where((item) => !(item.product.remoteId == remoteId && item.selectedVariantIndex == variantIndex)).toList();
    _saveCart();
  }

  void updateQuantity(String remoteId, int variantIndex, int quantity) {
    final index = state.indexWhere(
      (item) => item.product.remoteId == remoteId && item.selectedVariantIndex == variantIndex
    );
    
    if (index >= 0) {
      if (quantity <= 0) {
        removeFromCart(remoteId, variantIndex);
      } else {
        final newList = List<CartItem>.from(state);
        newList[index].quantity = quantity;
        state = newList;
        _saveCart();
      }
    }
  }

  void clearCart() {
    state = [];
    _saveCart();
  }

  void _saveCart() {
    final prefs = ref.read(prefsProvider);
    final cartString = jsonEncode(state.map((item) => item.toJson()).toList());
    prefs.setString('cart_items', cartString);
  }
}
