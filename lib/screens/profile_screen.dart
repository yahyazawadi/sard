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
import '../l10n/app_localizations.dart';
import '../widgets/sard_background.dart';

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
    final isArabic = settings.locale.languageCode == 'ar';
    final l10n = AppLocalizations.of(context)!;
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
      child: SardBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: false,
                floating: true,
                snap: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: AppTheme.getIconColor(theme),
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
                title: Text(
                  l10n.settings,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getIconColor(theme),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),
                    // PERSONAL INFORMATION
                    _buildSectionLabel(l10n.personalInformation, theme),
              SardInfoCard(
                icon: Icons.location_on_outlined,
                title: l10n.defaultAddress,
                subtitle: userProfile.address ?? l10n.notSet,
                onTap: () => LocationPopup.show(
                  context,
                  currentAddress: userProfile.address,
                  onAddressChanged: (newAddress) {
                    ref
                        .read(userProfileProvider.notifier)
                        .updateAddress(newAddress);
                  },
                ),
              ),
              SardInfoCard(
                icon: Icons.phone_android_outlined,
                title: l10n.phoneNumber,
                subtitle: userProfile.phoneNumber ?? l10n.notSet,
                onTap: () => PhoneNumberPopup.show(
                  context,
                  initialNumber: userProfile.phoneNumber,
                  onConfirm: (newNumber) {
                    ref
                        .read(userProfileProvider.notifier)
                        .updatePhoneNumber(newNumber);
                  },
                ),
              ),
              SardInfoCard(
                icon: Icons.credit_card_outlined,
                title: l10n.paymentMethod,
                subtitle: userProfile.preferredPayment ?? 'cash',
                onTap: () => PaymentMethodPopup.show(
                  context,
                  initialMethod: userProfile.preferredPayment,
                  onSelected: (newMethod) {
                    ref
                        .read(userProfileProvider.notifier)
                        .updatePreferredPayment(newMethod);
                  },
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionLabel(l10n.app, theme),
              SardInfoCard(
                icon: isDarkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                title: l10n.appearance,
                subtitle: isDarkMode ? l10n.dark : l10n.light,
                trailing: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: isDarkMode,
                    onChanged: (val) {
                      ref
                          .read(settingsProvider.notifier)
                          .setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                    },
                    thumbColor: WidgetStateProperty.all(AppTheme.gradientStart),
                    trackColor: WidgetStateProperty.all(
                      theme.colorScheme.surface,
                    ),
                    trackOutlineColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ),
                  ),
                ),
              ),
              SardInfoCard(
                icon: Icons.language_outlined,
                title: l10n.language,
                subtitle: isArabic ? l10n.arabic : l10n.english,
                trailing: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: isArabic,
                    onChanged: (val) {
                      ref
                          .read(settingsProvider.notifier)
                          .setLocale(Locale(val ? 'ar' : 'en'));
                    },
                    thumbColor: WidgetStateProperty.all(AppTheme.gradientStart),
                    trackColor: WidgetStateProperty.all(
                      theme.colorScheme.surface,
                    ),
                    trackOutlineColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ),
                  ),
                ),
              ),

              if (orderHistory.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildSectionLabel(l10n.orderHistory, theme),
                ...orderHistory.map(
                  (order) => _buildOrderCard(order, theme, ref, context),
                ),
              ],

              const SizedBox(height: 100),
              // Actions
              _buildActionButton(
                label: l10n.switchAccount,
                icon: Icons.switch_account_outlined,
                onPressed: () {},
                theme: theme,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: l10n.signOut,
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
              const SizedBox(height: 120),
                  ]),
                ),
              ),
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
            color: AppTheme.getIconColor(theme).withValues(alpha: 0.6),
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
              : AppTheme.getCardColor(theme).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.2)
                : AppTheme.getCardBorderColor(theme),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : AppTheme.getIconColor(theme),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isDestructive ? Colors.red : AppTheme.getIconColor(theme),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, ThemeData theme, WidgetRef ref, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onCardColor = AppTheme.getOnCardColor(theme);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(theme),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: AppTheme.getCardBorderColor(theme),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.orderId(order.id),
                style: TextStyle(fontWeight: FontWeight.bold, color: onCardColor),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(order.date),
                style: TextStyle(
                  color: onCardColor.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(
                    '${item.quantity}x ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: onCardColor),
                  ),
                  Expanded(child: Text(
                    item.product.getName(Localizations.localeOf(context).languageCode),
                    style: TextStyle(color: onCardColor),
                  )),
                  Text(
                    '₪${(item.variant.price * item.quantity).toStringAsFixed(2)}',
                    style: TextStyle(color: onCardColor),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.total,
                style: TextStyle(fontWeight: FontWeight.bold, color: onCardColor),
              ),
              Text(
                '₪${order.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: onCardColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
