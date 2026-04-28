import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../routes/app_routes.dart';
import '../providers/user_profile_provider.dart';
import '../models/order_model.dart';
import '../custom/app_theme.dart';
import '../screens/main_wrapper_screen.dart';
import '../models/cart_item.dart';
import '../widgets/sard_info_card.dart';
import '../widgets/sard_primary_button.dart';
import '../widgets/phone_number_popup.dart';
import '../widgets/location_popup.dart';
import '../widgets/payment_method_selector.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPayment = 'cash';
  final PageController _cardPageController = PageController(
    viewportFraction: 0.85,
  );
  String _currentAddress = "Your home\nShuhada'a roundabout, Nablus city";
  final TextEditingController _phoneController = TextEditingController();

  // Controllers for credit card form
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  final List<Map<String, String>> _fakeCards = [
    {'number': '4242 4242 4242 4242', 'expiry': '12/26', 'cvv': '123'},
    {'number': '5555 5555 5555 5555', 'expiry': '10/25', 'cvv': '456'},
    {'number': '3782 8224 6310 005', 'expiry': '08/24', 'cvv': '789'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfile = ref.read(userProfileProvider);
      if (userProfile.phoneNumber != null &&
          userProfile.phoneNumber!.isNotEmpty) {
        _phoneController.text = userProfile.phoneNumber!;
      }
      if (userProfile.preferredPayment != null) {
        setState(() => _selectedPayment = userProfile.preferredPayment!);
      }
      if (userProfile.address != null) {
        setState(() => _currentAddress = userProfile.address!);
      }
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartItems = ref.watch(cartProvider);
    final subtotal = cartItems.fold(
      0.0,
      (sum, item) => sum + (item.variant.price * item.quantity),
    );
    final total = subtotal + 5.0;

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
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
          ),
          title: Text('Checkout', style: theme.textTheme.titleLarge),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: AppTheme.gradientStart,
                size: 24,
              ),
              onPressed: () {
                ref.read(mainWrapperPageProvider.notifier).state = 1;
                context.go(AppRoutes.home);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const SizedBox(height: 40),

              _buildSectionLabel('Shipping Address'),
              SardInfoCard(
                icon: Icons.location_on_outlined,
                title: 'Shipping Address',
                subtitle: _currentAddress.contains('\n')
                    ? _currentAddress.split('\n').last
                    : _currentAddress,
                onTap: () => LocationPopup.show(
                  context,
                  currentAddress: _currentAddress,
                  onAddressChanged: (newAddress) {
                    setState(() => _currentAddress = newAddress);
                    ref
                        .read(userProfileProvider.notifier)
                        .updateAddress(newAddress);
                  },
                ),
              ),

              const SizedBox(height: 20),
              _buildSectionLabel('Phone Number'),
              SardInfoCard(
                icon: Icons.phone_android_outlined,
                title: 'Phone Number',
                subtitle: _phoneController.text.isEmpty
                    ? 'Not set'
                    : _phoneController.text,
                onTap: () => PhoneNumberPopup.show(
                  context,
                  initialNumber: _phoneController.text,
                  onConfirm: (newNumber) {
                    setState(() => _phoneController.text = newNumber);
                    ref
                        .read(userProfileProvider.notifier)
                        .updatePhoneNumber(newNumber);
                  },
                ),
              ),

              const SizedBox(height: 32),
              PaymentMethodSelector(
                selectedMethod: _selectedPayment,
                onSelected: (method) {
                  setState(() => _selectedPayment = method);
                  ref
                      .read(userProfileProvider.notifier)
                      .updatePreferredPayment(method);
                  if (method == 'Credit') {
                    _showCreditCardSheet(context, total);
                  }
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomSummary(
          theme,
          cartItems,
          subtotal,
          total,
        ),
      ),
    );
  }

  Widget _buildBottomSummary(
    ThemeData theme,
    List<CartItem> cartItems,
    double subtotal,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow(
              theme,
              'Subtotal',
              '₪ ${subtotal.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(theme, 'Shipping', '₪ 5.00'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Divider(color: theme.colorScheme.outlineVariant, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "₪ ${total.toStringAsFixed(2)}",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SardPrimaryButton(
              label: 'PLACE ORDER',
              onTap: () => _handlePlaceOrder(total),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showCreditCardSheet(BuildContext context, double total) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cards ABOVE the sliding menu
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _cardPageController,
                  itemCount: _fakeCards.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      final card = _fakeCards[index];
                      _cardNumberController.text = card['number']!;
                      _expiryController.text = card['expiry']!;
                      _cvvController.text = card['cvv']!;
                    },
                    child: _buildCreditCardItem(theme, index),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // The Sliding Menu container
              Container(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Method',
                            style: theme.textTheme.titleLarge,
                          ),
                          Text(
                            'Enter your card details',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildFormTextField(
                            theme,
                            '0000 0000 0000 0000',
                            Icons.credit_card_outlined,
                            controller: _cardNumberController,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormTextField(
                                  theme,
                                  'MM/YY',
                                  null,
                                  controller: _expiryController,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildFormTextField(
                                  theme,
                                  '***',
                                  null,
                                  isObscure: true,
                                  controller: _cvvController,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SardPrimaryButton(
                            label: 'Pay Now  |  ₪ ${total.toStringAsFixed(2)}',
                            onTap: () {
                              TextInput.finishAutofillContext();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditCardItem(ThemeData theme, int index) {
    final colors = [
      theme.colorScheme.onSurface,
      theme.colorScheme.primary,
      theme.colorScheme.tertiary,
    ];
    final card = _fakeCards[index];

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
              Icon(
                Icons.wifi_rounded,
                color: Colors.white.withValues(alpha: 0.5),
                size: 20,
              ),
              const Text(
                'VISA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Text(
            card['number']!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'YOUR NAME',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                card['expiry']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormTextField(
    ThemeData theme,
    String hint,
    IconData? icon, {
    bool isObscure = false,
    TextEditingController? controller,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, size: 18) : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 32),
        ),
      ),
    );
  }

  void _handlePlaceOrder(double total) {
    final cartItems = ref.read(cartProvider);
    final profileNotifier = ref.read(userProfileProvider.notifier);
    profileNotifier.updatePreferredPayment(_selectedPayment);

    final order = OrderModel(
      id: 'SRD-${DateTime.now().millisecondsSinceEpoch % 10000}',
      date: DateTime.now(),
      items: List.from(cartItems),
      total: total,
    );
    profileNotifier.addOrder(order);
    ref.read(cartProvider.notifier).clearCart();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Order Placed!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
