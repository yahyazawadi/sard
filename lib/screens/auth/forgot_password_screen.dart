import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_inputs.dart';

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
            title: const Text('Email Sent'),
            content: const Text('Check your inbox to reset your password.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
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
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
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
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: '',
        backgroundColor: Colors.transparent,
        border: null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Forgot Password?',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'select which contact details should we use to reset your password',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),
              
              _buildOptionCard(
                index: 0,
                icon: CupertinoIcons.mail,
                title: 'Email',
                subtitle: 'Send to your email',
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                index: 1,
                icon: CupertinoIcons.phone,
                title: 'Phone Number',
                subtitle: 'Send to your Phone number',
                theme: theme,
              ),
              
              if (_selectedOption == 0) ...[
                const SizedBox(height: 32),
                CustomTextField(
                  label: '',
                  placeholder: 'Enter your email',
                  controller: _emailCtrl,
                ),
              ],
              
              const SizedBox(height: 48),
              CustomButton(
                text: 'Continue',
                isLoading: auth.isLoading,
                onPressed: () {
                  if (_selectedOption == 0) {
                    _sendEmailReset();
                  } else {
                    showCupertinoDialog(
                      context: context,
                      builder: (ctx) => CupertinoAlertDialog(
                        title: const Text('Not Configured'),
                        content: const Text('SMS reset gateway not configured. Please use Email.'),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('OK'),
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
    // Primary is #26C6B8. We make a very faded version for the background.
    final bgColor = isSelected 
        ? theme.colorScheme.primary.withOpacity(0.15) 
        : theme.colorScheme.surfaceVariant.withOpacity(0.5);

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
