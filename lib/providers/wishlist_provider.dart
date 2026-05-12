import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'prefs_provider.dart';

final wishlistProvider = StateNotifierProvider<WishlistNotifier, Set<String>>((ref) {
  final prefs = ref.watch(prefsProvider);
  return WishlistNotifier(prefs);
});

class WishlistNotifier extends StateNotifier<Set<String>> {
  final SharedPreferences _prefs;
  static const _key = 'wishlist_ids';

  WishlistNotifier(this._prefs) : super({}) {
    _loadWishlist();
  }

  void _loadWishlist() {
    final ids = _prefs.getStringList(_key) ?? [];
    state = ids.toSet();
  }

  Future<void> toggleWishlist(String productId) async {
    final newState = Set<String>.from(state);
    if (newState.contains(productId)) {
      newState.remove(productId);
    } else {
      newState.add(productId);
    }
    state = newState;
    await _prefs.setStringList(_key, state.toList());
  }

  Future<void> addToWishlist(String productId) async {
    if (state.contains(productId)) return;
    final newState = Set<String>.from(state)..add(productId);
    state = newState;
    await _prefs.setStringList(_key, state.toList());
  }

  Future<void> removeFromWishlist(String productId) async {
    if (!state.contains(productId)) return;
    final newState = Set<String>.from(state)..remove(productId);
    state = newState;
    await _prefs.setStringList(_key, state.toList());
  }

  bool isWishlisted(String productId) {
    return state.contains(productId);
  }
}
