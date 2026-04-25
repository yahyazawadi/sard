import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffix;
  
  const CustomTextField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          obscureText: obscureText,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          style: theme.textTheme.bodyLarge,
          placeholderStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            fontWeight: FontWeight.w300, // Very thin placeholder like wireframe
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3), // Very soft grey box
            borderRadius: BorderRadius.circular(4), // slightly squared
          ),
          suffix: suffix,
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final Color bgColor = isSecondary 
      ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
      : theme.colorScheme.primaryContainer; // Light Sard teal
      
    final Color textColor = theme.colorScheme.onSurface; // Black text for primary buttons per spec

    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        onPressed: isLoading ? null : onPressed,
        child: isLoading 
          ? CupertinoActivityIndicator(color: textColor) 
          : Text(
              text,
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
    );
  }
}
