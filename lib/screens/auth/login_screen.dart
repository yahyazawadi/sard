// =============================================================================
// LOGIN SCREEN — ⚠️  DO NOT TOUCH THE AUTH LOGIC IN THIS FILE  ⚠️
// =============================================================================
// This screen handles three flows:
//   • SIGN IN   → loginWithEmail() → router redirect takes user to /home
//   • SIGN UP   → registerWithEmailLink() → navigates to /verify screen
//   • RECOVERY  → confirmResetAndLogin() → router redirect takes user to /home
//
// Navigation after auth is handled by GoRouter redirect in routes.dart.
// ⚠️  Do NOT add context.go(AppRoutes.home) after sign-in calls.
//     The auth stream fires → router redirects automatically. Adding manual
//     navigation creates double-navigation and routing bugs.
//
// Back button uses context.go(AppRoutes.onboarding) NOT context.pop().
//     Login is opened via context.go() (not push), so there is nothing
//     on the stack to pop. Popping causes a GoError crash.
// =============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_inputs.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/sard_background.dart';

class LoginScreen extends StatefulWidget {
  final String? initialEmail;
  final bool initialIsSignUp;
  final String? oobCode;

  const LoginScreen({
    super.key,
    this.initialEmail,
    this.initialIsSignUp = false,
    this.oobCode,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscureText = true;
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp || widget.oobCode != null;
    if (widget.initialEmail != null) {
      _emailCtrl.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError(context.read<AppLocalizations>().enterEmailPasswordError);
      return;
    }

    try {
      final auth = context.read<AuthProvider>();

      if (widget.oobCode != null) {
        // Recovery flow
        await auth.confirmResetAndLogin(widget.oobCode!, email, password);
        if (mounted) context.go(AppRoutes.home);
      } else if (_isSignUp) {
        // Sign up flow
        if (name.isEmpty) {
          _showError(context.read<AppLocalizations>().enterNameError);
          return;
        }
        await auth.registerWithEmailLink(name, email, password);
        if (mounted) context.go(AppRoutes.verify);
      } else {
        // Login flow — router redirect handles navigation after auth state changes
        await auth.loginWithEmail(email, password);
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    final l10n = AppLocalizations.of(context)!;
    String displayMessage = message;
    if (message.contains('invalid-credential') || message.contains('INVALID_LOGIN_CREDENTIALS')) {
      displayMessage = l10n.incorrectEmailPassword;
    } else if (message.contains('too-many-requests')) {
      displayMessage = l10n.tooManyAttempts;
    } else if (message.contains('user-not-found')) {
      displayMessage = l10n.noAccountFound;
    } else if (message.contains('wrong-password')) {
      displayMessage = l10n.incorrectPassword;
    } else if (message.contains('user-disabled')) {
      displayMessage = l10n.accountDisabled;
    } else if (message.contains('email-not-verified')) {
      displayMessage = l10n.verifyEmailCheckInbox;
    } else if (message.contains('network-request-failed')) {
      displayMessage = l10n.networkError;
    } else if (message.contains('email-already-in-use')) {
      displayMessage = l10n.accountAlreadyExists;
    }
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(_isSignUp ? l10n.registrationFailed : l10n.loginFailed),
        content: Text(displayMessage),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.ok),
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.onboarding);
      },
      child: CupertinoPageScaffold(
        backgroundColor: Colors.transparent,
        navigationBar: CupertinoNavigationBar(
          leading: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
            ),
            onPressed: () => context.go(AppRoutes.onboarding),
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
                  widget.oobCode != null
                      ? AppLocalizations.of(context)!.completeRecovery
                      : (_isSignUp ? AppLocalizations.of(context)!.createAccount : AppLocalizations.of(context)!.welcomeSard),
                  style: theme.textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _isSignUp
                      ? AppLocalizations.of(context)!.chooseFavoriteMenu
                      : AppLocalizations.of(context)!.signInToAccount,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),

                if (_isSignUp && widget.oobCode == null) ...[
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
                const SizedBox(height: 16),

                if (!_isSignUp)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        AppLocalizations.of(context)!.forgotPassword,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onPressed: () {
                        context.push(AppRoutes.forgotPassword);
                      },
                    ),
                  ),

                const SizedBox(height: 32),
                CustomButton(
                  text: widget.oobCode != null
                      ? AppLocalizations.of(context)!.completeRecovery
                      : (_isSignUp ? AppLocalizations.of(context)!.register : AppLocalizations.of(context)!.login),
                  onPressed: _handleSubmit,
                  isLoading: auth.isLoading,
                ),

                const SizedBox(height: 48),
                Center(
                  child: CupertinoButton(
                    child: Text(
                      _isSignUp ? AppLocalizations.of(context)!.haveAccountSignIn : AppLocalizations.of(context)!.newHereCreateAccount,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      setState(() => _isSignUp = !_isSignUp);
                    },
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      try {
                        await auth.signInWithGoogle();
                        // Router redirect handles navigation
                      } catch (e) {
                        _showError(e.toString());
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.continueWith,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.google,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
