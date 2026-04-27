import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class ProductBuilderState {
  final Product? product;
  final ProductVariant? selectedVariant;
  final String? selectedGender;
  final double? selectedWeight;
  final Map<String, int> selectedFillings;
  final bool isLoading;
  final bool isEdited;
  final int quantity;

  ProductBuilderState({
    this.product,
    this.selectedVariant,
    this.selectedGender,
    this.selectedWeight,
    this.selectedFillings = const {},
    this.isLoading = false,
    this.isEdited = false,
    this.quantity = 1,
  });

  ProductBuilderState copyWith({
    Product? product,
    ProductVariant? selectedVariant,
    String? selectedGender,
    double? selectedWeight,
    Map<String, int>? selectedFillings,
    bool? isLoading,
    bool? isEdited,
    int? quantity,
  }) {
    return ProductBuilderState(
      product: product ?? this.product,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      selectedGender: selectedGender ?? this.selectedGender,
      selectedWeight: selectedWeight ?? this.selectedWeight,
      selectedFillings: selectedFillings ?? this.selectedFillings,
      isLoading: isLoading ?? this.isLoading,
      isEdited: isEdited ?? this.isEdited,
      quantity: quantity ?? this.quantity,
    );
  }

  // --- Interface State Bools ---

  int get currentPieces => selectedFillings.values.fold(0, (sum, count) => sum + count);
  
  int get maxPieces => selectedVariant?.pieces ?? 0;

  bool get isBoxFull {
    if (product == null || !product!.isCustomizable) return false;
    return currentPieces >= maxPieces && maxPieces > 0;
  }

  bool get isSelectionValid {
    if (product == null) return false;
    
    if (product!.isCustomizable) {
      return isBoxFull;
    }
    
    if (product!.isGendered) {
      return selectedGender != null;
    }
    
    if (product!.isSoldByWeight) {
      return selectedWeight != null;
    }

    // Default valid if no special requirements
    return true; 
  }
  
  double get totalPrice {
    if (product == null) return 0.0;
    
    if (product!.isSoldByWeight) {
       final basePrice = product!.variants?.isNotEmpty == true ? product!.variants!.first.price : 0.0;
       return basePrice * (selectedWeight ?? 1.0);
    }
    
    if (product!.isFixedPrice) {
       return product!.variants?.isNotEmpty == true ? product!.variants!.first.price : 0.0;
    }
    
    return (selectedVariant?.price ?? 0.0) * quantity;
  }
}

class ProductBuilderNotifier extends StateNotifier<ProductBuilderState> {
  ProductBuilderNotifier() : super(ProductBuilderState());

  void initFromCartItem(CartItem item) {
    state = ProductBuilderState(
      product: item.product,
      selectedVariant: item.product.variants?[item.selectedVariantIndex],
      selectedGender: item.selectedGender,
      selectedWeight: item.selectedWeight,
      selectedFillings: item.selectedFillings != null ? Map<String, int>.from(item.selectedFillings!) : {},
      isLoading: false,
      isEdited: true, 
      quantity: item.quantity,
    );
  }

  void initProduct(Product product) {
    ProductVariant? initialVariant;
    if (product.hasVariants && product.variants != null && product.variants!.isNotEmpty) {
      // Default to Medium if available, else first
      initialVariant = product.variants!.firstWhere(
        (v) => v.size.toLowerCase().contains('medium') || v.size.toLowerCase().contains('m'),
        orElse: () => product.variants!.first,
      );
    }

    String? initialGender;
    if (product.isGendered && product.genderOptions != null && product.genderOptions!.isNotEmpty) {
        initialGender = product.genderOptions!.first;
    }

    double? initialWeight;
    if (product.isSoldByWeight) {
        initialWeight = 1.0; // Default 1kg
    }

    Map<String, int> initialFillings = {};
    if (product.isCustomizable) {
      if (initialVariant?.prefilledMixJson != null) {
        try {
          final decoded = json.decode(initialVariant!.prefilledMixJson!);
          if (decoded is Map) {
            decoded.forEach((k, v) {
              initialFillings[k.toString()] = v as int;
            });
          }
        } catch (e) {
          debugPrint('Error parsing prefilledMixJson: $e');
        }
      }

      if (initialFillings.isEmpty) {
        final maxPieces = initialVariant?.pieces ?? 24;
        if (maxPieces > 0) {
           initialFillings['fill_0'] = (maxPieces / 2).floor();
           initialFillings['fill_1'] = maxPieces - (maxPieces / 2).floor();
        }
      }
    }

    state = ProductBuilderState(
      product: product,
      selectedVariant: initialVariant,
      selectedGender: initialGender,
      selectedWeight: initialWeight,
      selectedFillings: initialFillings,
      isLoading: false,
      quantity: 1,
    );
  }

  void selectVariant(ProductVariant variant, {bool forceReset = false}) {
    Map<String, int> newFillings = {};
    if (state.product?.isCustomizable == true && variant.prefilledMixJson != null) {
      try {
        final decoded = json.decode(variant.prefilledMixJson!);
        if (decoded is Map) {
          decoded.forEach((k, v) {
            newFillings[k.toString()] = v as int;
          });
        }
      } catch (e) {
        debugPrint('Error parsing prefilledMixJson on selectVariant: $e');
      }
    }

    if (newFillings.isEmpty) {
      if (!state.isEdited || forceReset) {
        // If they haven't edited or we force reset, auto-fill the new size perfectly!
        final maxPieces = variant.pieces ?? 24;
        if (maxPieces > 0) {
           newFillings['fill_0'] = (maxPieces / 2).floor();
           newFillings['fill_1'] = maxPieces - (maxPieces / 2).floor();
        }
      } else {
        // Fallback to their current selections
        newFillings = Map.from(state.selectedFillings);
        if (variant.pieces != null && variant.pieces! < state.currentPieces) {
          newFillings.clear(); // Reset if the box shrinks and no prefill provided
        }
      }
    }
    
    state = state.copyWith(
      selectedVariant: variant,
      selectedFillings: newFillings,
      isEdited: false, // Reset editing state on size change
    );
  }

  void selectGender(String gender) {
    state = state.copyWith(selectedGender: gender);
  }

  void selectWeight(double weight) {
    state = state.copyWith(selectedWeight: weight);
  }

  void addFilling(String fillingId) {
    // Removed isBoxFull check to allow users to go over the limit intentionally
    final currentFillings = Map<String, int>.from(state.selectedFillings);
    currentFillings[fillingId] = (currentFillings[fillingId] ?? 0) + 1;
    
    state = state.copyWith(selectedFillings: currentFillings, isEdited: true);
  }

  void removeFilling(String fillingId) {
    final currentFillings = Map<String, int>.from(state.selectedFillings);
    if (currentFillings.containsKey(fillingId) && currentFillings[fillingId]! > 0) {
      currentFillings[fillingId] = currentFillings[fillingId]! - 1;
      if (currentFillings[fillingId] == 0) {
        currentFillings.remove(fillingId);
      }
      state = state.copyWith(selectedFillings: currentFillings, isEdited: true);
    }
  }

  void clearFillings() {
    state = state.copyWith(selectedFillings: {}, isEdited: true);
  }

  void setQuantity(int q) {
    if (q >= 1) {
      state = state.copyWith(quantity: q);
    }
  }
}

final productBuilderProvider = StateNotifierProvider.autoDispose<ProductBuilderNotifier, ProductBuilderState>((ref) {
  return ProductBuilderNotifier();
});
