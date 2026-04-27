import 'package:flutter/material.dart';
import '../custom/app_theme.dart';
import 'payment_method_selector.dart';

class PaymentMethodPopup extends StatefulWidget {
  final String? initialMethod;
  final Function(String) onSelected;
  final double? total;

  const PaymentMethodPopup({
    super.key,
    this.initialMethod,
    required this.onSelected,
    this.total,
  });

  static void show(
    BuildContext context, {
    String? initialMethod,
    required Function(String) onSelected,
    double? total,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentMethodPopup(
        initialMethod: initialMethod,
        onSelected: onSelected,
        total: total,
      ),
    );
  }

  @override
  State<PaymentMethodPopup> createState() => _PaymentMethodPopupState();
}

class _PaymentMethodPopupState extends State<PaymentMethodPopup> {
  late String _selectedMethod;
  final PageController _cardPageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.initialMethod ?? 'cash';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The sliding cards ABOVE the menu
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _cardPageController,
            itemCount: 3,
            itemBuilder: (context, index) => _buildCreditCardItem(theme, index),
          ),
        ),
        const SizedBox(height: 16),
        
        // The "Sliding Menu" (bottom container)
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              PaymentMethodSelector(
                selectedMethod: _selectedMethod,
                onSelected: (method) {
                  setState(() => _selectedMethod = method);
                  widget.onSelected(method);
                },
              ),
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreditCardItem(ThemeData theme, int index) {
    final colors = [theme.colorScheme.onSurface, theme.colorScheme.primary, theme.colorScheme.tertiary];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: colors[index % 3], borderRadius: BorderRadius.circular(AppTheme.cardRadius + 4)),
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
          const Text('**** **** **** 4242', style: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2, fontWeight: FontWeight.w500)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('YOUR NAME', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('12/26', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
