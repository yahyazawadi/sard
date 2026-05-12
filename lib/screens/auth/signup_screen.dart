import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_inputs.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/sard_background.dart';

class SignUpScreen extends StatefulWidget {
  final String? prefilledEmail;
  final String? oobCode;
  const SignUpScreen({super.key, this.prefilledEmail, this.oobCode});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    debugPrint('SignUpScreen initState. prefilledEmail: ${widget.prefilledEmail}');
    if (widget.prefilledEmail != null) {
      _emailCtrl.text = widget.prefilledEmail!;
    }
  }

  Future<void> _register() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError(AppLocalizations.of(context)!.enterEmailPasswordError);
      return;
    }

    try {
      final auth = context.read<AuthProvider>();
      
      if (widget.oobCode != null) {
        // This is a password reset flow - confirm reset and login immediately
        await auth.confirmResetAndLogin(widget.oobCode!, email, password);
        if (mounted) {
          context.go(AppRoutes.home);
        }
      } else {
        // This is a standard registration or hybrid flow
        await auth.registerWithEmailLink(name.isEmpty ? 'User' : name, email, password);
        if (mounted) {
          context.push(AppRoutes.verify);
        }
      }
    } catch (e) {
      if (mounted) {
        _showError(AppLocalizations.of(context)!.registrationFailedDetail(e.toString()));
      }
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.registrationFailed),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.ok),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      navigationBar: const CupertinoNavigationBar(
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
                  widget.prefilledEmail != null
                      ? AppLocalizations.of(context)!.completeRecovery
                      : AppLocalizations.of(context)!.signUp,
                  style: theme.textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.createAccountChooseMenu,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),
                
                if (widget.prefilledEmail == null) ...[
                  CustomTextField(
                    label: AppLocalizations.of(context)!.name,
                    placeholder: AppLocalizations.of(context)!.name.toLowerCase(),
                    controller: _nameCtrl,
                  ),
                  const SizedBox(height: 24),
                ],

                CustomTextField(
                  label: AppLocalizations.of(context)!.email,
                  placeholder: AppLocalizations.of(context)!.email.toLowerCase(),
                  controller: _emailCtrl,
                ),
                const SizedBox(height: 24),

                CustomTextField(
                  label: AppLocalizations.of(context)!.password,
                  placeholder: AppLocalizations.of(context)!.password.toLowerCase(),
                  controller: _passwordCtrl,
                  obscureText: _obscureText,
                  suffix: CupertinoButton(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      _obscureText ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() => _obscureText = !_obscureText);
                    },
                  ),
                ),
                const SizedBox(height: 48),
                
                CustomButton(
                  text: widget.prefilledEmail != null
                      ? AppLocalizations.of(context)!.completeRecovery
                      : AppLocalizations.of(context)!.register,
                  onPressed: _register,
                  isLoading: auth.isLoading,
                ),
                
                const SizedBox(height: 24),
                Center(
                  child: CupertinoButton(
                    child: Text(
                      AppLocalizations.of(context)!.haveAccountSignIn,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onPressed: () {
                      context.pop(); // Go back to login or welcome
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
