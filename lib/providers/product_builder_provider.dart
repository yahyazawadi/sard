import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import 'cart_provider.dart';

class ProductBuilderState {
  final Product? product;
  final ProductVariant? selectedVariant;
  final BulkBox? selectedBulkBox;
  final PreMadeTemplate? selectedTemplate;
  final String? selectedGender;
  final double? selectedWeight;
  final Map<String, int> selectedFillings;
  final String? selectedType;
  final String? selectedSize;
  final bool isLoading;
  final bool isEdited;
  final int quantity;

  ProductBuilderState({
    this.product,
    this.selectedVariant,
    this.selectedBulkBox,
    this.selectedTemplate,
    this.selectedGender,
    this.selectedWeight,
    this.selectedType,
    this.selectedSize,
    this.selectedFillings = const {},
    this.isLoading = false,
    this.isEdited = false,
    this.quantity = 1,
  });

  ProductBuilderState copyWith({
    Product? product,
    ProductVariant? selectedVariant,
    BulkBox? selectedBulkBox,
    PreMadeTemplate? selectedTemplate,
    bool clearTemplate = false,
    bool clearBulkBox = false,
    String? selectedGender,
    double? selectedWeight,
    Map<String, int>? selectedFillings,
    String? selectedType,
    String? selectedSize,
    bool clearType = false,
    bool clearSize = false,
    bool? isLoading,
    bool? isEdited,
    int? quantity,
  }) {
    return ProductBuilderState(
      product: product ?? this.product,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      selectedBulkBox: clearBulkBox ? null : (selectedBulkBox ?? this.selectedBulkBox),
      selectedTemplate: clearTemplate ? null : (selectedTemplate ?? this.selectedTemplate),
      selectedGender: selectedGender ?? this.selectedGender,
      selectedWeight: selectedWeight ?? this.selectedWeight,
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      selectedSize: clearSize ? null : (selectedSize ?? this.selectedSize),
      selectedFillings: selectedFillings ?? this.selectedFillings,
      isLoading: isLoading ?? this.isLoading,
      isEdited: isEdited ?? this.isEdited,
      quantity: quantity ?? this.quantity,
    );
  }

  // --- Computed props ---

  int get currentPieces => selectedFillings.values.fold(0, (sum, count) => sum + count);

  int get maxPieces => selectedVariant?.pieces ?? 0;

  bool get isBoxFull {
    if (product == null || !product!.isCustomizable) return false;
    return currentPieces >= maxPieces && maxPieces > 0;
  }

  bool get isSelectionValid {
    if (product == null) return false;

    if (product!.isBulkProduct) {
      // For bulk products: must have a box size selected; template is optional
      return selectedBulkBox != null;
    }

    if (product!.isCustomizable) {
      return isBoxFull;
    }

    if (product!.isGendered) {
      return selectedGender != null;
    }

    if (product!.isSoldByWeight) {
      return selectedWeight != null;
    }

    if (product!.section == 'bars') {
      return selectedType != null && selectedSize != null;
    }

    if (product!.hasVariants) {
      return selectedVariant != null;
    }

    return true;
  }

  double get totalPrice {
    if (product == null) return 0.0;

    if (product!.isBulkProduct) {
      return (selectedBulkBox?.price ?? 0.0) * quantity;
    }

    if (product!.isSoldByWeight) {
      final basePrice = product!.variants?.isNotEmpty == true
          ? product!.variants!.first.price
          : 0.0;
      return basePrice * (selectedWeight ?? 1.0);
    }

    if (product!.isFixedPrice) {
      return product!.variants?.isNotEmpty == true
          ? product!.variants!.first.price
          : 0.0;
    }

    return (selectedVariant?.price ?? 0.0) * quantity;
  }
}

class ProductBuilderNotifier extends StateNotifier<ProductBuilderState> {
  final Ref _ref;
  ProductBuilderNotifier(this._ref) : super(ProductBuilderState());

  void _syncWithCart() {
    if (state.product == null) return;
    final cart = _ref.read(cartProvider);
    final variantIndex = state.product?.variants?.indexWhere(
          (v) => v.size == state.selectedVariant?.size,
        ) ??
        -1;
    if (variantIndex < 0) return;

    final existing = cart.where((item) {
      bool productMatch = item.product.remoteId == state.product!.remoteId &&
          item.selectedVariantIndex == variantIndex;
      if (!productMatch) return false;
      bool genderMatch = item.selectedGender == state.selectedGender;
      bool weightMatch = item.selectedWeight == state.selectedWeight;
      bool fillingsMatch = true;
      if (item.selectedFillings == null && state.selectedFillings.isEmpty) {
        fillingsMatch = true;
      } else if (item.selectedFillings != null &&
          state.selectedFillings.isNotEmpty) {
        if (item.selectedFillings!.length != state.selectedFillings.length) {
          fillingsMatch = false;
        } else {
          for (var key in item.selectedFillings!.keys) {
            if (item.selectedFillings![key] != state.selectedFillings[key]) {
              fillingsMatch = false;
              break;
            }
          }
        }
      } else {
        fillingsMatch = false;
      }
      return genderMatch && weightMatch && fillingsMatch;
    }).toList();

    if (existing.isNotEmpty && state.quantity != existing.first.quantity) {
      state = state.copyWith(quantity: existing.first.quantity);
    }
  }

  void initFromCartItem(CartItem item) {
    final variant = item.product.variants != null && item.product.variants!.length > item.selectedVariantIndex
        ? item.product.variants![item.selectedVariantIndex]
        : null;

    state = ProductBuilderState(
      product: item.product,
      selectedVariant: variant,
      selectedGender: item.selectedGender,
      selectedWeight: item.selectedWeight,
      selectedFillings: item.selectedFillings != null
          ? Map<String, int>.from(item.selectedFillings!)
          : {},
      selectedType: variant?.type,
      selectedSize: variant?.size,
      isLoading: false,
      isEdited: true,
      quantity: item.quantity,
    );
  }

  void initProduct(Product product) {
    // --- Bulk product default ---
    BulkBox? initialBulkBox;
    if (product.isBulkProduct && product.bulkBoxes!.isNotEmpty) {
      // Default to first box (smallest)
      initialBulkBox = product.bulkBoxes!.first;
    }

    // --- Classic variant default ---
    ProductVariant? initialVariant;
    if (!product.isBulkProduct &&
        product.hasVariants &&
        product.variants != null &&
        product.variants!.isNotEmpty) {
      if (product.section.toLowerCase() == 'bars') {
        initialVariant = null; // Do not pre-select for bars, show all combinations initially
      } else {
        initialVariant = product.variants!.firstWhere(
          (v) =>
              v.size.toLowerCase().contains('medium') ||
              v.size.toLowerCase().contains('m'),
          orElse: () => product.variants!.first,
        );
      }
    }

    String? initialGender;
    if (product.isGendered &&
        product.genderOptions != null &&
        product.genderOptions!.isNotEmpty) {
      initialGender = product.genderOptions!.first;
    }

    double? initialWeight;
    if (product.isSoldByWeight) {
      initialWeight = 1.0;
    }

    Map<String, int> initialFillings = {};
    if (product.isCustomizable && !product.isBulkProduct) {
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
      selectedBulkBox: initialBulkBox,
      selectedGender: initialGender,
      selectedWeight: initialWeight,
      selectedFillings: initialFillings,
      selectedType: initialVariant?.type,
      selectedSize: initialVariant?.size,
      isLoading: false,
      quantity: 1,
    );
    _syncWithCart();
  }

  // ── Selection actions ──────────────────────────────

  void selectVariant(ProductVariant variant, {bool forceReset = false}) {
    Map<String, int> newFillings = {};
    if (state.product?.isCustomizable == true &&
        variant.prefilledMixJson != null) {
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
        final maxPieces = variant.pieces ?? 24;
        if (maxPieces > 0) {
          newFillings['fill_0'] = (maxPieces / 2).floor();
          newFillings['fill_1'] = maxPieces - (maxPieces / 2).floor();
        }
      } else {
        newFillings = Map.from(state.selectedFillings);
        if (variant.pieces != null && variant.pieces! < state.currentPieces) {
          newFillings.clear();
        }
      }
    }

    state = state.copyWith(
      selectedVariant: variant,
      selectedFillings: newFillings,
      selectedType: variant.type,
      selectedSize: variant.size,
      isEdited: false,
    );
    _syncWithCart();
  }

  void selectType(String? type) {
    if (state.selectedType == type) {
      state = state.copyWith(clearType: true);
    } else {
      state = state.copyWith(selectedType: type);
    }
    _updateVariantFromFilters();
  }

  void selectSize(String? size) {
    if (state.selectedSize == size) {
      state = state.copyWith(clearSize: true);
    } else {
      state = state.copyWith(selectedSize: size);
    }
    _updateVariantFromFilters();
  }

  void _updateVariantFromFilters() {
    if (state.product == null || state.product!.variants == null) return;
    
    // Find variant matching both
    final match = state.product!.variants!.firstWhere(
      (v) => (v.type == state.selectedType || state.selectedType == null) && 
             (v.size == state.selectedSize || state.selectedSize == null),
      orElse: () => state.product!.variants!.first,
    );
    
    // Only update the actual selectedVariant if BOTH are picked or if it's a 1-dimensional variant list
    // Actually, let's always update it to the "best" match
    state = state.copyWith(selectedVariant: match);
    _syncWithCart();
  }

  void selectBulkBox(BulkBox box) {
    if (state.selectedBulkBox?.name == box.name) {
      state = state.copyWith(clearBulkBox: true);
    } else {
      state = state.copyWith(selectedBulkBox: box);
    }
  }

  /// Select a pre-made template. This is just a label selection —
  /// it does NOT auto-fill piece counts (this product is weight-based).
  void selectTemplate(PreMadeTemplate template) {
    // Toggle off if already selected
    if (state.selectedTemplate?.nameEn == template.nameEn) {
      state = state.copyWith(clearTemplate: true);
    } else {
      state = state.copyWith(selectedTemplate: template);
    }
  }

  void selectGender(String gender) {
    state = state.copyWith(selectedGender: gender);
    _syncWithCart();
  }

  void selectWeight(double weight) {
    state = state.copyWith(selectedWeight: weight);
    _syncWithCart();
  }

  void addFilling(String fillingId) {
    final currentFillings = Map<String, int>.from(state.selectedFillings);
    currentFillings[fillingId] = (currentFillings[fillingId] ?? 0) + 1;
    state = state.copyWith(selectedFillings: currentFillings, isEdited: true);
    _syncWithCart();
  }

  void removeFilling(String fillingId) {
    final currentFillings = Map<String, int>.from(state.selectedFillings);
    if (currentFillings.containsKey(fillingId) &&
        currentFillings[fillingId]! > 0) {
      currentFillings[fillingId] = currentFillings[fillingId]! - 1;
      if (currentFillings[fillingId] == 0) {
        currentFillings.remove(fillingId);
      }
      state = state.copyWith(selectedFillings: currentFillings, isEdited: true);
      _syncWithCart();
    }
  }

  void clearFillings() {
    state = state.copyWith(selectedFillings: {}, isEdited: true);
    _syncWithCart();
  }

  void setQuantity(int q) {
    if (q >= 1) {
      state = state.copyWith(quantity: q);

      final cart = _ref.read(cartProvider);
      final variantIndex = state.product?.variants
              ?.indexWhere((v) => v.size == state.selectedVariant?.size && v.type == state.selectedVariant?.type) ??
          -1;
      if (variantIndex >= 0) {
        final existing = cart.where((item) {
          bool productMatch =
              item.product.remoteId == state.product!.remoteId &&
                  item.selectedVariantIndex == variantIndex;
          if (!productMatch) return false;
          bool genderMatch = item.selectedGender == state.selectedGender;
          bool weightMatch = item.selectedWeight == state.selectedWeight;
          bool fillingsMatch = true;
          if (item.selectedFillings == null &&
              state.selectedFillings.isEmpty) {
            fillingsMatch = true;
          } else if (item.selectedFillings != null &&
              state.selectedFillings.isNotEmpty) {
            if (item.selectedFillings!.length != state.selectedFillings.length) {
              fillingsMatch = false;
            } else {
              for (var key in item.selectedFillings!.keys) {
                if (item.selectedFillings![key] != state.selectedFillings[key]) {
                  fillingsMatch = false;
                  break;
                }
              }
            }
          } else {
            fillingsMatch = false;
          }
          return genderMatch && weightMatch && fillingsMatch;
        }).toList();

        if (existing.isNotEmpty) {
          _ref.read(cartProvider.notifier).updateQuantity(existing.first.id, q);
        }
      }
    }
  }
}

final productBuilderProvider =
    StateNotifierProvider<ProductBuilderNotifier, ProductBuilderState>((ref) {
  final notifier = ProductBuilderNotifier(ref);
  ref.listen(cartProvider, (prev, next) {
    notifier._syncWithCart();
  });
  return notifier;
});
