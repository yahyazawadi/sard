import 'package:flutter/material.dart';
import '../custom/app_theme.dart';
import 'package:sard/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.paymentMethod),
        const SizedBox(height: 12),
        _buildPaymentOption(theme, 'Apple Pay', l10n.applePay, Icons.apple),
        _buildPaymentOption(theme, 'Credit', l10n.creditCard, Icons.credit_card_outlined),
        _buildPaymentOption(theme, 'cash', l10n.cash, Icons.payments_outlined),
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

  Widget _buildPaymentOption(ThemeData theme, String value, String title, IconData icon) {
    final isSelected = selectedMethod == value;
    final onCardColor = AppTheme.getOnCardColor(theme);

    return GestureDetector(
      onTap: () => onSelected(title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(theme),
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
              color: isSelected
                  ? Colors.white
                  : onCardColor.withValues(alpha: 0.3),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
