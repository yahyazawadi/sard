import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class VerifyScreen extends StatefulWidget {
  final String? emailLink;

  const VerifyScreen({super.key, this.emailLink});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  bool _isProcessing = false;
  String? _error;
  bool _needsEmailEntry = false;
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('!!! VerifyScreen initState. emailLink: ${widget.emailLink}');
    if (widget.emailLink != null) {
      _processLink(widget.emailLink!);
    }
  }

  @override
  void didUpdateWidget(VerifyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('!!! VerifyScreen didUpdateWidget. emailLink: ${widget.emailLink}');
    if (widget.emailLink != null && widget.emailLink != oldWidget.emailLink) {
      _processLink(widget.emailLink!);
    }
  }

  Future<void> _processLink(String link) async {
    print('!!! VerifyScreen: _processLink started with link: $link');
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      
      // Basic check for link mode if possible, or just try to use it
      final uri = Uri.parse(link);
      final mode = uri.queryParameters['mode'];
      print('!!! VerifyScreen: Mode identified as: $mode');

      if (mode == 'resetPassword') {
        final oobCode = uri.queryParameters['oobCode'];
        if (oobCode != null) {
          try {
            print('!!! VerifyScreen: Verifying reset code...');
            final email = await FirebaseAuth.instance.verifyPasswordResetCode(oobCode);
            print('!!! VerifyScreen: Reset code verified. Email: $email');
            if (mounted) {
              final target = '${AppRoutes.signUp}?email=${Uri.encodeComponent(email)}&oobCode=$oobCode';
              print('!!! VerifyScreen: Redirecting to recovery: $target');
              context.go(target);
            }
          } catch (e) {
            setState(() {
              _isProcessing = false;
              _error = "Invalid or expired reset link. Error: $e";
            });
          }
        } else {
          setState(() {
            _isProcessing = false;
            _error = "Invalid reset link: missing code.";
          });
        }
        return;
      }

      String? email = auth.getEmailForSignIn();
      
      // If the user manually entered their email in the UI, use that instead
      if (_emailController.text.isNotEmpty) {
        email = _emailController.text.trim();
      }

      if (email == null) {
        // If it's a sign-in link but we don't have the email, we need to ask the user
        setState(() {
          _isProcessing = false;
          _needsEmailEntry = true;
        });
        return;
      }

      await auth.signInWithEmailLink(email, link);
      
      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => context.go(AppRoutes.onboarding),
        ),
        previousPageTitle: '',
        backgroundColor: Colors.transparent,
        border: null,
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_isProcessing) ...[
                  const CupertinoActivityIndicator(radius: 20),
                  const SizedBox(height: 24),
                  Text(
                    'Verifying your link...',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ] else if (_error != null) ...[
                  const Icon(CupertinoIcons.exclamationmark_circle, size: 64, color: Colors.red),
                  const SizedBox(height: 24),
                  Text(
                    'Verification Failed',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CupertinoButton.filled(
                    child: const Text('Back to Login'),
                    onPressed: () => context.go(AppRoutes.login),
                  ),
                ] else if (_needsEmailEntry) ...[
                  const Icon(CupertinoIcons.lock_shield, size: 80, color: Colors.orange),
                  const SizedBox(height: 32),
                  Text(
                    'Confirm Your Email',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'For security, please enter the email address where you received the link.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CupertinoTextField(
                    controller: _emailController,
                    placeholder: 'your@email.com',
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  CupertinoButton.filled(
                    child: const Text('Verify & Sign In'),
                    onPressed: () {
                      if (_emailController.text.isNotEmpty && widget.emailLink != null) {
                        _processLink(widget.emailLink!);
                      }
                    },
                  ),
                ] else ...[
                  const Icon(CupertinoIcons.mail_solid, size: 80, color: Colors.blue),
                  const SizedBox(height: 32),
                  Text(
                    'Check Your Email',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We sent a sign-in link to your email. Click it to complete the login.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  CupertinoButton(
                    child: const Text('Didn\'t receive the email? Try again'),
                    onPressed: () => context.go(AppRoutes.login),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
