import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_profile_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../routes/app_routes.dart';
import '../models/order_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as p;

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(userProfileProvider);
    final auth = p.Provider.of<AuthProvider>(context);

    // Limit to last 5 items as requested
    final orderHistory = profile.orderHistory.take(5).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'serif'),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // PERSONAL INFORMATION
            _buildSectionLabel('PERSONAL INFORMATION'),
            _buildProfileItem(
              icon: Icons.home_outlined,
              title: 'DEFAULT ADDRESS',
              subtitle: 'Shuhada` roundabout,\nNablus',
              theme: theme,
            ),
            _buildProfileItem(
              icon: Icons.phone_outlined,
              title: 'PHONE NUMBER',
              subtitle: profile.phoneNumber ?? 'Not set',
              theme: theme,
            ),

            const SizedBox(height: 24),
            // PAYMENT & SECURITY
            _buildSectionLabel('PAYMENT & SECURITY'),
            _buildProfileItem(
              icon: Icons.credit_card_outlined,
              title: 'PAYMENT METHOD',
              subtitle: profile.preferredPayment ?? 'Not set',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(4)),
                child: const Text('DEFAULT', style: TextStyle(color: Color(0xFF26A69A), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              theme: theme,
            ),

            const SizedBox(height: 24),
            // RECENT ACTIVITY
            _buildSectionLabel('RECENT ACTIVITY'),
            if (orderHistory.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No recent activity', style: TextStyle(color: Colors.grey)),
              )
            else
              ...orderHistory.map((order) => _buildOrderCard(order, theme, ref)),

            const SizedBox(height: 40),
            // Actions
            _buildActionButton(
              label: 'Switch Account',
              icon: Icons.switch_account_outlined,
              onPressed: () {},
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              label: 'Sign Out',
              icon: Icons.logout,
              onPressed: () => auth.logout(),
              theme: theme,
              isDestructive: true,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeData theme,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF8F9F9), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF1A8F85), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600, height: 1.2)),
              ],
            ),
          ),
          if (trailing != null) trailing,
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, ThemeData theme, WidgetRef ref) {
    return StatefulBuilder(
      builder: (context, setState) {
        // Local state for checkboxes
        final Set<int> selectedIndices = ref.read(orderSelectionProvider(order.id));

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
                      const SizedBox(height: 2),
                      Text(DateFormat('MMM dd, yyyy • hh:mm a').format(order.date), style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 12, color: Color(0xFF26A69A)),
                        const SizedBox(width: 4),
                        Text(order.status, style: const TextStyle(color: Color(0xFF26A69A), fontSize: 9, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, thickness: 0.5)),
              
              ...List.generate(order.items.length, (index) {
                final item = order.items[index];
                final isSelected = selectedIndices.contains(index);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                selectedIndices.add(index);
                              } else {
                                selectedIndices.remove(index);
                              }
                            });
                          },
                          activeColor: const Color(0xFF1A8F85),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('${item.quantity}x ', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 14)),
                                Text(item.product.nameEn, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getItemDetails(item),
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      Text('₪ ${(item.variant.price * item.quantity).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL AMOUNT', style: TextStyle(color: Colors.grey.shade400, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                      Text('₪ ${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: selectedIndices.isEmpty ? null : () {
                      for (var index in selectedIndices) {
                        final item = order.items[index];
                        ref.read(cartProvider.notifier).addToCart(
                          item.product,
                          variantIndex: item.selectedVariantIndex,
                          gender: item.selectedGender,
                          weight: item.selectedWeight,
                          fillings: item.selectedFillings,
                        );
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${selectedIndices.length} items re-added to cart!'), 
                          behavior: SnackBarBehavior.floating,
                          action: SnackBarAction(label: 'VIEW CART', onPressed: () => context.push(AppRoutes.cart)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart, size: 16),
                    label: const Text('RE-ORDER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A8F85),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  String _getItemDetails(dynamic item) {
    List<String> details = [];
    if (item.selectedGender != null) details.add(item.selectedGender!);
    if (item.selectedWeight != null) details.add('${item.selectedWeight}kg');
    if (item.selectedFillings != null && item.selectedFillings!.isNotEmpty) {
      details.add(item.selectedFillings!.keys.join(', '));
    }
    details.add(item.variant.size);
    return details.join(' • ');
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required ThemeData theme,
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isDestructive ? Colors.red.shade100 : Colors.grey.shade200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF1A8F85), size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: isDestructive ? Colors.red : Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// Simple provider to keep track of checkbox selections per order
final orderSelectionProvider = StateProvider.family<Set<int>, String>((ref, orderId) {
  return {};
});
