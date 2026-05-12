import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_inputs.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/sard_background.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _selectedOption = 0; // 0 for Email, 1 for Phone
  final _emailCtrl = TextEditingController();

  Future<void> _sendEmailReset() async {
    if (_emailCtrl.text.isEmpty) return;
    try {
      await context.read<AuthProvider>().sendPasswordReset(_emailCtrl.text.trim());
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text(AppLocalizations.of(context)!.emailSent),
            content: Text(AppLocalizations.of(context)!.checkInboxResetPassword),
            actions: [
              CupertinoDialogAction(
                child: Text(AppLocalizations.of(context)!.ok),
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pop(); // Go back to login
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text(AppLocalizations.of(context)!.errorText),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: Text(AppLocalizations.of(context)!.ok),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      navigationBar: CupertinoNavigationBar(
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        previousPageTitle: '',
        backgroundColor: Colors.transparent,
        border: null,
      ),
      child: SardBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.forgotPassword,
                  style: theme.textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.selectContactDetailsReset,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),
                
                _buildOptionCard(
                  index: 0,
                  icon: CupertinoIcons.mail,
                  title: AppLocalizations.of(context)!.email,
                  subtitle: AppLocalizations.of(context)!.sendToYourEmail,
                  theme: theme,
                ),
                const SizedBox(height: 16),
                _buildOptionCard(
                  index: 1,
                  icon: CupertinoIcons.phone,
                  title: AppLocalizations.of(context)!.phoneNumber,
                  subtitle: AppLocalizations.of(context)!.sendToYourPhone,
                  theme: theme,
                ),
                
                if (_selectedOption == 0) ...[
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: '',
                    placeholder: AppLocalizations.of(context)!.enterYourEmail,
                    controller: _emailCtrl,
                  ),
                ],
                
                const SizedBox(height: 48),
                CustomButton(
                  text: AppLocalizations.of(context)!.continueText,
                  isLoading: auth.isLoading,
                  onPressed: () {
                    if (_selectedOption == 0) {
                      _sendEmailReset();
                    } else {
                      showCupertinoDialog(
                        context: context,
                        builder: (ctx) => CupertinoAlertDialog(
                          title: Text(AppLocalizations.of(context)!.notConfigured),
                          content: Text(AppLocalizations.of(context)!.smsResetGatewayError),
                          actions: [
                            CupertinoDialogAction(
                              child: Text(AppLocalizations.of(context)!.ok),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeData theme,
  }) {
    final isSelected = _selectedOption == index;
    final bgColor = isSelected 
        ? theme.colorScheme.primary.withValues(alpha: 0.15) 
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedOption = index);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.onSurface, size: 28),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle, 
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
