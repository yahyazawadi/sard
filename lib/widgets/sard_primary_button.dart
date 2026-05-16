import 'package:flutter/material.dart';
import '../custom/app_theme.dart';

class SardPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double? width;
  final double height;
  final IconData? icon;

  const SardPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width,
    this.height = 58,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(Theme.of(context)),
          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
          border: Border.all(
            color: AppTheme.getButtonBorderColor(Theme.of(context)),
            width: 1.5,
          ),
          boxShadow: AppTheme.goldShadow,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppTheme.darkCocoa, size: 20),
              const SizedBox(width: 12),
            ],
            Text(
              label,
              strutStyle: const StrutStyle(
                fontSize: 16,
                height: 1.0,
                forceStrutHeight: true,
              ),
              style: const TextStyle(
                color: AppTheme.darkCocoa,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Tajawal',
                height: 1.0,
                leadingDistribution: TextLeadingDistribution.even,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
