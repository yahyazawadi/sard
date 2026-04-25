import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../providers/cart_provider.dart';
import '../routes/app_routes.dart';
import '../providers/user_profile_provider.dart'; // Added import
import '../models/order_model.dart'; // Added import

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPayment = 'cash';
  final PageController _cardPageController = PageController(viewportFraction: 0.85);
  String _currentAddress = "Yahya's home\nShuhada'a roundabout, Nablus city";
  bool _isLocating = false;
  
  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '+970 ### ### ###',
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy,
  );
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load cached preferences
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfile = ref.read(userProfileProvider);
      if (userProfile.phoneNumber != null && userProfile.phoneNumber!.isNotEmpty) {
        _phoneController.value = _phoneMaskFormatter.formatEditUpdate(
          TextEditingValue.empty, 
          TextEditingValue(text: userProfile.phoneNumber!)
        );
      }
      if (userProfile.preferredPayment != null) {
        setState(() {
          _selectedPayment = userProfile.preferredPayment!;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartItems = ref.watch(cartProvider);
    final subtotal = cartItems.fold(0.0, (sum, item) => sum + (item.variant.price * item.quantity));
    final total = subtotal + 5.0;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface, size: 24),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(
            color: theme.colorScheme.onSurface, 
            fontWeight: FontWeight.w800, 
            fontSize: 22, 
            fontFamily: 'serif'
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: theme.colorScheme.onSurface, size: 24),
            onPressed: () => context.go(AppRoutes.cart),
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

            _buildSectionHeader('Shipping Address', onAction: () => _showLocationPopup(context)),
            _buildInfoCard(
              theme,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1), 
                      shape: BoxShape.circle
                    ),
                    child: Icon(Icons.location_on, color: theme.colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentAddress.contains('\n') ? _currentAddress.split('\n').last : _currentAddress, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentAddress.split('\n').first, 
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)
                        ),
                      ],
                    ),
                  ),
                  if (_isLocating)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('Phone Number'),
            _buildInfoCard(
              theme,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _phoneController,
                  inputFormatters: [_phoneMaskFormatter],
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: '+970 --- --- ---',
                    hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                    prefixIcon: Icon(Icons.phone_android, color: theme.colorScheme.primary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('Payment Method'),
            _buildPaymentOption(theme, 'Apple Pay', Icons.apple),
            _buildPaymentOption(theme, 'Credit', Icons.credit_card_outlined),
            _buildPaymentOption(theme, 'cash', Icons.money),

            const SizedBox(height: 32),
            _buildSectionHeader('Order Summary'),
            _buildInfoCard(
              theme,
              child: Column(
                children: [
                  _buildSummaryRow(theme, 'Subtotal (${cartItems.length} items)', '₪ ${subtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  _buildSummaryRow(theme, 'Shipping', '₪ 5.00'),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '₪ ${total.toStringAsFixed(2)}', 
                        style: TextStyle(
                          fontWeight: FontWeight.w900, 
                          fontSize: 22, 
                          color: theme.colorScheme.primary
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () => _handlePlaceOrder(total),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Place Order', 
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold, 
                    fontFamily: 'DG Sahabah'
                  )
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchAndSetLocation() async {
    setState(() => _isLocating = true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location services are disabled. Please enable GPS."))
          );
        }
        setState(() => _isLocating = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Location permissions are denied"))
            );
          }
          setState(() => _isLocating = false);
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permissions are permanently denied. Please enable them in settings."))
          );
        }
        setState(() => _isLocating = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        String? street = place.street;
        if (street != null && street.contains('+') && !street.contains(' ')) {
          street = (place.thoroughfare?.isNotEmpty ?? false) ? place.thoroughfare : place.name;
          if (street != null && street.contains('+') && !street.contains(' ')) {
            street = null;
          }
        }

        String line1 = street ?? place.name ?? "Current Location";
        String city = place.locality ?? place.subAdministrativeArea ?? "";
        String area = place.subLocality ?? "";
        
        String line2 = [area, city].where((s) => s.isNotEmpty).join(", ");
        if (line2.isEmpty) line2 = place.administrativeArea ?? "";
        
        String country = place.country ?? "";
        
        setState(() {
          _currentAddress = "$line1\n$line2, $country";
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching location: $e"))
        );
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
              borderRadius: BorderRadius.circular(32)
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
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2), 
                      borderRadius: BorderRadius.circular(2)
                    )
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Delivery Location', 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'serif')
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select how you\'d like to set your address', 
                    textAlign: TextAlign.center, 
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)
                  ),
                  const SizedBox(height: 32),
                  _buildSheetButton(
                    theme,
                    'Use Current Location', 
                    theme.colorScheme.primary, 
                    Colors.white, 
                    Icons.my_location,
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
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'NOT NOW', 
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5), 
                        fontWeight: FontWeight.w900, 
                        letterSpacing: 1.2, 
                        fontSize: 12
                      )
                    ),
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
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2), 
                  borderRadius: BorderRadius.circular(2)
                )
              )
            ),
            const SizedBox(height: 24),
            const Text(
              'Enter Address', 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'serif')
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter your full delivery address...",
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
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
                  if (controller.text.isNotEmpty) {
                    setState(() {
                      _currentAddress = controller.text;
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('SAVE ADDRESS', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
          ],
        ),
      ),
    );
  }

  void _showCreditCardSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AutofillGroup(
        child: Container(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface, 
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32))
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
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2), 
                    borderRadius: BorderRadius.circular(2)
                  )
                )
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment Method', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                        Text('Enter your card details', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
                      ],
                    ),
                    Row(
                      children: [
                        _buildSmallIconBox(theme, Icons.remove, theme.colorScheme.surfaceContainerHighest),
                        const SizedBox(width: 8),
                        _buildSmallIconBox(theme, Icons.credit_card, theme.colorScheme.onSurface, iconColor: theme.colorScheme.surface),
                      ],
                    ),
                  ],
                ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(theme, 'CARD NUMBER'),
                    _buildFormTextField(theme, '0000 0000 0000 0000', Icons.credit_card, hints: [AutofillHints.creditCardNumber]),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(theme, 'EXPIRY DATE'), _buildFormTextField(theme, 'MM/YY', null, hints: [AutofillHints.creditCardExpirationDate])])),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(theme, 'CCV'), _buildFormTextField(theme, '***', null, isObscure: true, hints: [AutofillHints.creditCardSecurityCode])])),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLabel(theme, 'CARDHOLDER NAME'),
                    _buildFormTextField(theme, 'me me', null, hints: [AutofillHints.creditCardName]),
                    const SizedBox(height: 24),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_user, size: 14, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('ENCRYPTED & SECURE PAYMENT', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          TextInput.finishAutofillContext();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                        ),
                        child: const Text('Pay Now  |  ₪ 48.00', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              Icon(Icons.wifi, color: Colors.white.withValues(alpha: 0.5), size: 20), 
              const Text('VISA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))
            ]
          ),
          const Text('**** **** **** 4242', style: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2, fontWeight: FontWeight.w500)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('CARD HOLDER', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)), 
                const Text('YAHYA ZAWADI', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('EXPIRES', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)), 
                const Text('12/26', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallIconBox(ThemeData theme, IconData icon, Color bg, {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.all(6), 
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)), 
      child: Icon(icon, size: 16, color: iconColor ?? theme.colorScheme.onSurfaceVariant)
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          if (onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                'Change', 
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 13
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, {required Widget child}) {
    return Container(
      width: double.infinity, 
      padding: const EdgeInsets.all(20), 
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3), 
        borderRadius: BorderRadius.circular(20)
      ), 
      child: child
    );
  }

  Widget _buildPaymentOption(ThemeData theme, String title, IconData icon) {
    bool isSelected = _selectedPayment == title;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPayment = title);
        if (title == 'Credit') _showCreditCardSheet(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3), 
          borderRadius: BorderRadius.circular(16)
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8), 
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05), 
                borderRadius: BorderRadius.circular(8)
              ), 
              child: Icon(icon, size: 20, color: theme.colorScheme.onSurface)
            ),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const Spacer(),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined, 
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3), 
              size: 22
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
        Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)), 
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))
      ]
    );
  }

  Widget _buildLabel(ThemeData theme, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8), 
    child: Text(
      text, 
      style: TextStyle(
        fontSize: 10, 
        color: theme.colorScheme.onSurfaceVariant, 
        fontWeight: FontWeight.bold
      )
    )
  );

  Widget _buildFormTextField(ThemeData theme, String hint, IconData? icon, {bool isObscure = false, Iterable<String>? hints}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5), 
        borderRadius: BorderRadius.circular(12)
      ),
      child: TextField(
        autofillHints: hints,
        obscureText: isObscure,
        style: TextStyle(color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 14),
          prefixIcon: icon != null ? Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 18) : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 32),
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
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14))),
              Icon(Icons.arrow_forward_ios, size: 10, color: textColor.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePlaceOrder(double total) {
    final cartItems = ref.read(cartProvider);
    final profileNotifier = ref.read(userProfileProvider.notifier);
    
    // 1. Save phone and payment to cache
    profileNotifier.updatePhoneNumber(_phoneMaskFormatter.getMaskedText());
    profileNotifier.updatePreferredPayment(_selectedPayment);
    
    // 2. Add to order history
    final order = OrderModel(
      id: 'SRD-${DateTime.now().millisecondsSinceEpoch % 10000}',
      date: DateTime.now(),
      items: List.from(cartItems),
      total: total,
    );
    profileNotifier.addOrder(order);
    
    // 3. Clear cart
    ref.read(cartProvider.notifier).clearCart();

    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), 
        content: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            Icon(Icons.check_circle, size: 80, color: Theme.of(context).colorScheme.primary), 
            const SizedBox(height: 24), 
            const Text('Order Placed!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'serif')), 
            const SizedBox(height: 32)
          ]
        )
      )
    );
  }
}
