import 'package:flutter/material.dart';
import '../custom/app_theme.dart';

class PaymentMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onSelected;
  final double? total;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onSelected,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Payment Method'),
        const SizedBox(height: 12),
        _buildPaymentOption(theme, 'Apple Pay', Icons.apple),
        _buildPaymentOption(theme, 'Credit', Icons.credit_card_outlined),
        _buildPaymentOption(theme, 'cash', Icons.payments_outlined),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildPaymentOption(ThemeData theme, String title, IconData icon) {
    final isSelected = selectedMethod == title;
    final onCardColor = AppTheme.getOnCardColor(theme);
    
    return GestureDetector(
      onTap: () => onSelected(title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: AppTheme.getCardGradient(theme),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(
            color: isSelected ? AppTheme.accentGold : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected ? AppTheme.cardShadow : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: AppTheme.gradientStart),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: onCardColor,
              ),
            ),
            const Spacer(),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? Colors.white : onCardColor.withValues(alpha: 0.3),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
