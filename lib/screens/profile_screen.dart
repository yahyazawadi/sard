import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../providers/user_profile_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/sync_provider.dart';
import '../routes/app_routes.dart';
import '../models/order_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as p;
import '../providers/settings_provider.dart';
import '../custom/app_theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '### ### ####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final TextEditingController _phoneController = TextEditingController();
  final PageController _cardPageController = PageController(
    viewportFraction: 0.85,
  );
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfile = ref.read(userProfileProvider);
      if (userProfile.phoneNumber != null &&
          userProfile.phoneNumber!.isNotEmpty) {
        String phone = userProfile.phoneNumber!;
        // Strip any existing Palestinian/Regional prefixes to avoid duplicates
        phone = phone.replaceAll(RegExp(r'^\+97[02]?\s*'), '');
        
        _phoneController.value = _phoneMaskFormatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(text: phone),
        );
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _cardPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(userProfileProvider);
    final auth = p.Provider.of<AuthProvider>(context);
    final settings = ref.watch(settingsProvider);

    // Limit to last 5 items as requested
    final orderHistory = profile.orderHistory.take(5).toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
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
              _buildProfileItem(
                icon: Icons.home_outlined,
                title: 'DEFAULT ADDRESS',
                subtitle: profile.address ?? 'Not set',
                onTap: () => _showLocationPopup(context),
                theme: theme,
              ),
              _buildProfileItem(
                icon: Icons.phone_outlined,
                title: 'PHONE NUMBER',
                subtitle: profile.phoneNumber ?? 'Not set',
                onTap: () => _showPhonePopup(context),
                theme: theme,
              ),

              const SizedBox(height: 24),
              // PAYMENT & SECURITY
              _buildSectionLabel('PAYMENT & SECURITY', theme),
              _buildProfileItem(
                icon: Icons.credit_card_outlined,
                title: 'PAYMENT METHOD',
                subtitle: profile.preferredPayment ?? 'Not set',
                onTap: () => _showCreditCardSheet(context),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'DEFAULT',
                    style: TextStyle(
                      color: Color(0xFF26A69A),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                theme: theme,
              ),

              const SizedBox(height: 24),
              // RECENT ACTIVITY
              _buildSectionLabel('RECENT ACTIVITY', theme),
              if (orderHistory.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No recent activity',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...orderHistory.map(
                  (order) => _buildOrderCard(order, theme, ref),
                ),

              const SizedBox(height: 24),
              // APP SETTINGS
              _buildSectionLabel('APP SETTINGS', theme),
              _buildProfileItem(
                icon:
                    settings.themeMode == ThemeMode.dark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                title: 'THEME MODE',
                subtitle:
                    settings.themeMode == ThemeMode.dark
                        ? 'Dark Mode'
                        : 'Light Mode',
                theme: theme,
                trailing: Switch.adaptive(
                  value: settings.themeMode == ThemeMode.dark,
                  onChanged: (isDark) {
                    ref
                        .read(settingsProvider.notifier)
                        .setThemeMode(
                          isDark ? ThemeMode.dark : ThemeMode.light,
                        );
                  },
                  activeTrackColor: const Color(0xFF1A8F85),
                ),
              ),

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

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeData theme,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.secondary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  // Reuse logic from CheckoutScreen
  Future<void> _fetchAndSetLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location services are disabled.")),
          );
        }
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = "${place.street}, ${place.locality}, ${place.country}";
        ref.read(userProfileProvider.notifier).updateAddress(address);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      setState(() => _isLocating = false);
    }
  }

  void _showLocationPopup(BuildContext context) {
    final theme = Theme.of(context);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius + 16),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Update Address', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 32),
                  _buildSheetButton(
                    theme,
                    'Use Current Location',
                    theme.colorScheme.primary,
                    Colors.white,
                    Icons.my_location_rounded,
                    onTap: () {
                      Navigator.pop(context);
                      _fetchAndSetLocation();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSheetButton(
                    theme,
                    'Type Address Manually',
                    theme.colorScheme.surfaceContainerHighest,
                    theme.colorScheme.onSurface,
                    Icons.edit_location_outlined,
                    onTap: () {
                      Navigator.pop(context);
                      _showManualAddressSheet(context);
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_isLocating)
                    const CircularProgressIndicator()
                  else
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showManualAddressSheet(BuildContext context) {
    final theme = Theme.of(context);
    final controller = TextEditingController(
      text: ref.read(userProfileProvider).address,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Enter Address', style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter your full address...",
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(userProfileProvider.notifier)
                          .updateAddress(controller.text);
                      Navigator.pop(context);
                    },
                    child: const Text('SAVE ADDRESS'),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
              ],
            ),
          ),
    );
  }

  void _showPhonePopup(BuildContext context) {
    final theme = Theme.of(context);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.phone_android_outlined,
                            color: theme.colorScheme.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Update Phone',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your phone number for contact',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _phoneController,
                          inputFormatters: [_phoneMaskFormatter],
                          keyboardType: TextInputType.phone,
                          autofocus: true,
                          autofillHints: null,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                            hintText: '---- --- ---',
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 16, right: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '+97 ',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.cardRadius,
                              ),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              ref
                                  .read(userProfileProvider.notifier)
                                  .updatePhoneNumber(
                                    '+97 ${_phoneMaskFormatter.getUnmaskedText()}',
                                  );
                              Navigator.pop(context);
                            },
                            child: const Text('SAVE NUMBER'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: child,
        );
      },
    );
  }

  void _showCreditCardSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Payment Method', style: theme.textTheme.titleLarge),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    controller: _cardPageController,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return _buildCreditCardItem(theme, index);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildLabel(theme, 'CARD NUMBER'),
                      _buildFormTextField(theme, '0000 0000 0000 0000', Icons.credit_card_outlined),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(userProfileProvider.notifier).updatePreferredPayment('Credit');
                            Navigator.pop(context);
                          },
                          child: const Text('SAVE CARD'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ref.read(userProfileProvider.notifier).updatePreferredPayment('cash');
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.payments_outlined, size: 20),
                          label: const Text('SWITCH TO CASH'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
    );
  }

  Widget _buildCreditCardItem(ThemeData theme, int index) {
    final colors = [theme.colorScheme.onSurface, theme.colorScheme.primary, theme.colorScheme.tertiary];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colors[index % 3],
        borderRadius: BorderRadius.circular(AppTheme.cardRadius + 4),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.wifi_rounded, color: Colors.white.withValues(alpha: 0.5), size: 20),
              const Text('VISA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          const Text('**** **** **** 4242', style: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('YOUR NAME', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              const Text('12/26', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(ThemeData theme, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _buildFormTextField(ThemeData theme, String hint, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, size: 18) : null,
        ),
      ),
    );
  }

  Widget _buildSheetButton(ThemeData theme, String label, Color color, Color textColor, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppTheme.buttonRadius)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14))),
              Icon(Icons.arrow_forward_ios_rounded, size: 10, color: textColor.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, ThemeData theme, WidgetRef ref) {
    return StatefulBuilder(
      builder: (context, setState) {
        final Set<int> selectedIndices = ref.read(orderSelectionProvider(order.id));
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
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
                      Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(DateFormat('MMM dd, yyyy • hh:mm a').format(order.date), style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(8)),
                    child: Text(order.status, style: const TextStyle(color: Color(0xFF26A69A), fontSize: 9, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, thickness: 0.2)),
              ...List.generate(order.items.length, (index) {
                final item = order.items[index];
                final isSelected = selectedIndices.contains(index);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (val) => setState(() => val == true ? selectedIndices.add(index) : selectedIndices.remove(index)),
                        activeColor: const Color(0xFF1A8F85),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${item.quantity}x ${item.product.nameEn}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(_getItemDetails(item), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
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
                  Text('₪ ${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                  ElevatedButton(
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
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A8F85), foregroundColor: Colors.white),
                    child: const Text('RE-ORDER'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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

  Widget _buildActionButton({required String label, required IconData icon, required VoidCallback onPressed, required ThemeData theme, bool isDestructive = false}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isDestructive ? Colors.red.shade100 : theme.colorScheme.outline.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF1A8F85), size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: isDestructive ? Colors.red : theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

final orderSelectionProvider = StateProvider.family<Set<int>, String>((ref, id) => {});
