import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import 'prefs_provider.dart';

class UserProfile {
  final String? phoneNumber;
  final String? preferredPayment;
  final String? address;
  final List<OrderModel> orderHistory;

  UserProfile({
    this.phoneNumber,
    this.preferredPayment,
    this.address,
    this.orderHistory = const [],
  });

  UserProfile copyWith({
    String? phoneNumber,
    String? preferredPayment,
    String? address,
    List<OrderModel>? orderHistory,
  }) {
    return UserProfile(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      preferredPayment: preferredPayment ?? this.preferredPayment,
      address: address ?? this.address,
      orderHistory: orderHistory ?? this.orderHistory,
    );
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(() {
  return UserProfileNotifier();
});

class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    final prefs = ref.watch(prefsProvider);
    
    final phone = prefs.getString('user_phone');
    final payment = prefs.getString('user_payment');
    final address = prefs.getString('user_address');
    final historyJson = prefs.getStringList('order_history') ?? [];
    
    final history = historyJson.map((e) {
      return OrderModel.fromJson(jsonDecode(e));
    }).toList();

    return UserProfile(
      phoneNumber: phone,
      preferredPayment: payment,
      address: address,
      orderHistory: history,
    );
  }

  void updatePhoneNumber(String phone) {
    state = state.copyWith(phoneNumber: phone);
    ref.read(prefsProvider).setString('user_phone', phone);
  }

  void updatePreferredPayment(String payment) {
    state = state.copyWith(preferredPayment: payment);
    ref.read(prefsProvider).setString('user_payment', payment);
  }

  void updateAddress(String address) {
    state = state.copyWith(address: address);
    ref.read(prefsProvider).setString('user_address', address);
  }

  void addOrder(OrderModel order) {
    final newHistory = [order, ...state.orderHistory];
    state = state.copyWith(orderHistory: newHistory);
    
    final historyJson = newHistory.map((e) => jsonEncode(e.toJson())).toList();
    ref.read(prefsProvider).setStringList('order_history', historyJson);
  }

  void clearHistory() {
    state = state.copyWith(orderHistory: []);
    ref.read(prefsProvider).remove('order_history');
  }
}
