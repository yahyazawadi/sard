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

  void addToCart(
    Product product, {
    int variantIndex = 0,
    String? gender,
    double? weight,
    Map<String, int>? fillings,
    int quantity = 1,
  }) {
    final existingIndex = state.indexWhere((item) {
      bool basicMatch = item.product.remoteId == product.remoteId && item.selectedVariantIndex == variantIndex;
      if (!basicMatch) return false;

      // Check customizations
      bool genderMatch = item.selectedGender == gender;
      bool weightMatch = item.selectedWeight == weight;
      
      // Check fillings (deep equality)
      bool fillingsMatch = true;
      if (item.selectedFillings == null && fillings == null) {
        fillingsMatch = true;
      } else if (item.selectedFillings != null && fillings != null) {
        if (item.selectedFillings!.length != fillings.length) {
          fillingsMatch = false;
        } else {
          for (var key in item.selectedFillings!.keys) {
            if (item.selectedFillings![key] != fillings[key]) {
              fillingsMatch = false;
              break;
            }
          }
        }
      } else {
        fillingsMatch = false;
      }

      return genderMatch && weightMatch && fillingsMatch;
    });

    if (existingIndex >= 0) {
      final newList = List<CartItem>.from(state);
      newList[existingIndex].quantity += quantity;
      state = newList;
    } else {
      state = [
        ...state,
        CartItem(
          product: product,
          selectedVariantIndex: variantIndex,
          selectedGender: gender,
          selectedWeight: weight,
          selectedFillings: fillings != null ? Map<String, int>.from(fillings) : null,
          quantity: quantity,
        )
      ];
    }
    _saveCart();
  }

  void removeFromCart(String remoteId, int variantIndex) {
    state = state.where((item) => !(item.product.remoteId == remoteId && item.selectedVariantIndex == variantIndex)).toList();
    _saveCart();
  }

  void updateQuantity(String id, int quantity) {
    final index = state.indexWhere((item) => item.id == id);
    
    if (index >= 0) {
      if (quantity <= 0) {
        removeItemById(id);
      } else {
        final newList = List<CartItem>.from(state);
        newList[index] = newList[index].copyWith(quantity: quantity);
        state = newList;
        _saveCart();
      }
    }
  }

  void removeItemById(String id) {
    final currentState = state;
    final newState = currentState.where((item) => item.id != id).toList();
    
    // Explicitly check if something changed to avoid redundant updates, 
    // but ALWAYS replace the state with a new list if it did.
    if (newState.length != currentState.length) {
      state = newState;
      _saveCart();
    }
  }

  void updateCartItem(CartItem newItem) {
    final index = state.indexWhere((item) => item.id == newItem.id);
    if (index >= 0) {
      final newList = List<CartItem>.from(state);
      newList[index] = newItem;
      state = newList;
      _saveCart();
    }
  }

  void clearCart() {
    state = [];
    _saveCart();
  }

  void restoreItem(CartItem item) {
    state = [...state, item];
    _saveCart();
  }

  void _saveCart() {
    final prefs = ref.read(prefsProvider);
    final cartString = jsonEncode(state.map((item) => item.toJson()).toList());
    prefs.setString('cart_items', cartString);
  }
}
