import 'package:flutter/material.dart';
import '../custom/app_theme.dart';

class SardSearchBar extends StatelessWidget {
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool autofocus;
  final VoidCallback? onClear;
  final String hintText;

  const SardSearchBar({
    super.key,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.controller,
    this.autofocus = false,
    this.onClear,
    this.hintText = 'search for chocolate, truffle...',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        autofocus: autofocus,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            fontSize: 13,
          ),
          contentPadding: const EdgeInsets.fromLTRB(0, 11, 0, 5),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.gradientStart,
          ),
          suffixIcon: (!readOnly && (controller?.text.isNotEmpty ?? false))
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppTheme.gradientStart,
                  ),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class SardCategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;

  const SardCategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: GestureDetector(
        onTap: () => onSelected?.call(!isSelected),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.getCardGradient(theme) : null,
            color: isSelected ? null : theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
            border: Border.all(
              color: isSelected
                  ? AppTheme.accentGold
                  : AppTheme.gradientStart.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: isSelected ? AppTheme.cardShadow : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isSelected ? Icons.check_rounded : Icons.close_rounded,
                size: 13,
                color: isSelected ? Colors.white : AppTheme.gradientStart,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                strutStyle: const StrutStyle(
                  fontSize: 12,
                  height: 1.2,
                  forceStrutHeight: true,
                ),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected ? Colors.white : AppTheme.gradientStart,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                  fontSize: 12,
                  height: 1.2,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
