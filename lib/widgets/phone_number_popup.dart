import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../custom/app_theme.dart';
import 'sard_primary_button.dart';

class PhoneNumberPopup extends StatefulWidget {
  final String? initialNumber;
  final Function(String) onConfirm;

  const PhoneNumberPopup({
    super.key,
    this.initialNumber,
    required this.onConfirm,
  });

  static void show(BuildContext context, {
    String? initialNumber,
    required Function(String) onConfirm,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return PhoneNumberPopup(
          initialNumber: initialNumber,
          onConfirm: onConfirm,
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

  @override
  State<PhoneNumberPopup> createState() => _PhoneNumberPopupState();
}

class _PhoneNumberPopupState extends State<PhoneNumberPopup> {
  late TextEditingController _phoneController;
  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '### ### ####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    String phone = widget.initialNumber ?? '';
    // Strip prefix
    phone = phone.replaceAll(RegExp(r'^\+97[02]?\s*'), '');
    
    _phoneController = TextEditingController(text: phone);
    
    // Apply formatting to initial text
    _phoneController.value = _phoneMaskFormatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: phone),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                      child: const Icon(
                        Icons.phone_android_outlined,
                        color: AppTheme.gradientStart,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Contact Number',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your phone number for delivery updates',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: const Text(
                              '+97',
                              style: TextStyle(
                                color: AppTheme.gradientStart,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                                height: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 1.5,
                            height: 24,
                            color: theme.colorScheme.outline.withValues(alpha: 0.2),
                          ),
                          const SizedBox(width: 12),
                          IntrinsicWidth(
                            child: TextField(
                              controller: _phoneController,
                              inputFormatters: [_phoneMaskFormatter],
                              keyboardType: TextInputType.phone,
                              autofocus: true,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.1,
                              ),
                              decoration: InputDecoration(
                                hintText: '---- --- ---',
                                hintStyle: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SardPrimaryButton(
                      label: 'CONFIRM NUMBER',
                      height: 56,
                      onTap: () {
                        widget.onConfirm(
                          '+97 ${_phoneMaskFormatter.getUnmaskedText()}',
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
