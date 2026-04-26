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
        color: theme.brightness == Brightness.light
            ? Colors.grey.shade200
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        autofocus: autofocus,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          suffixIcon: (!readOnly && (controller?.text.isNotEmpty ?? false))
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.primary,
        checkmarkColor: Colors.white,
        showCheckmark: false, // Cleaner look for this premium design
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          color: isSelected ? Colors.white : theme.colorScheme.primary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          height: 1.0,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.buttonRadius), // More rounded for premium feel
          side: BorderSide(
            color: theme.colorScheme.tertiary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
