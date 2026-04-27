import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../custom/app_theme.dart';
import '../models/order_model.dart';
import 'main_wrapper_screen.dart';
import '../widgets/sard_info_card.dart';
import '../widgets/phone_number_popup.dart';
import '../widgets/location_popup.dart';
import '../widgets/payment_method_popup.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProfile = ref.watch(userProfileProvider);
    final settings = ref.watch(settingsProvider);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isDarkMode = settings.themeMode == ThemeMode.dark;
    final orderHistory = userProfile.orderHistory;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          final history = ref.read(tabHistoryProvider);
          if (history.length > 1) {
            final newHistory = List<int>.from(history)..removeLast();
            ref.read(tabHistoryProvider.notifier).state = newHistory;
            ref.read(mainWrapperPageProvider.notifier).state = newHistory.last;
          } else {
            context.go(AppRoutes.home);
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: AppTheme.gradientStart,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                final history = ref.read(tabHistoryProvider);
                if (history.length > 1) {
                  final newHistory = List<int>.from(history)..removeLast();
                  ref.read(tabHistoryProvider.notifier).state = newHistory;
                  ref.read(mainWrapperPageProvider.notifier).state =
                      newHistory.last;
                } else {
                  context.go(AppRoutes.home);
                }
              }
            },
          ),
          title: Text('My Profile', style: theme.textTheme.titleLarge),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // PERSONAL INFORMATION
              _buildSectionLabel('PERSONAL INFORMATION', theme),
              SardInfoCard(
                icon: Icons.location_on_outlined,
                title: 'Default Address',
                subtitle: userProfile.address ?? 'Not set',
                onTap: () => LocationPopup.show(
                  context,
                  currentAddress: userProfile.address,
                  onAddressChanged: (newAddress) {
                    ref.read(userProfileProvider.notifier).updateAddress(newAddress);
                  },
                ),
              ),
              SardInfoCard(
                icon: Icons.phone_android_outlined,
                title: 'Phone Number',
                subtitle: userProfile.phoneNumber ?? 'Not set',
                onTap: () => PhoneNumberPopup.show(
                  context,
                  initialNumber: userProfile.phoneNumber,
                  onConfirm: (newNumber) {
                    ref.read(userProfileProvider.notifier).updatePhoneNumber(newNumber);
                  },
                ),
              ),
              SardInfoCard(
                icon: Icons.credit_card_outlined,
                title: 'Payment Method',
                subtitle: userProfile.preferredPayment ?? 'cash',
                onTap: () => PaymentMethodPopup.show(
                  context,
                  initialMethod: userProfile.preferredPayment,
                  onSelected: (newMethod) {
                    ref.read(userProfileProvider.notifier).updatePreferredPayment(newMethod);
                  },
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionLabel('APP', theme),
              SardInfoCard(
                icon: isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                title: 'Appearance',
                subtitle: isDarkMode ? 'Dark Mode' : 'Light Mode',
                trailing: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: isDarkMode,
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).setThemeMode(
                        val ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                    thumbColor:
                        WidgetStateProperty.all(AppTheme.gradientStart),
                    trackColor:
                        WidgetStateProperty.all(AppTheme.bgWhite),
                    trackOutlineColor:
                        WidgetStateProperty.all(Colors.transparent),
                  ),
                ),
              ),

              if (orderHistory.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildSectionLabel('ORDER HISTORY', theme),
                ...orderHistory.map((order) => _buildOrderCard(order, theme, ref)),
              ],

              const SizedBox(height: 100),
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
                icon: Icons.logout_outlined,
                onPressed: () async {
                  await auth.fullReset();
                  ref.invalidate(cartProvider);
                  ref.invalidate(userProfileProvider);
                  ref.invalidate(syncProvider);
                },
                theme: theme,
                isDestructive: true,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }



  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required ThemeData theme,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.2)
                : theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : AppTheme.gradientStart,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isDestructive ? Colors.red : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, ThemeData theme, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(order.date),
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text('${item.quantity}x ', style: const TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(item.product.nameEn)),
                Text('₪${(item.variant.price * item.quantity).toStringAsFixed(2)}'),
              ],
            ),
          )),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '₪${order.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }



}
