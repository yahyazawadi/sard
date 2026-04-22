import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_inputs.dart';

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
  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp || widget.oobCode != null;
    if (widget.initialEmail != null) {
      _emailCtrl.text = widget.initialEmail!;
    }
  }

  Future<void> _handleSubmit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password.');
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
          _showError('Please enter your name.');
          return;
        }
        await auth.registerWithEmailLink(name, email, password);
        if (mounted) context.push(AppRoutes.verify);
      } else {
        // Login flow
        await auth.loginWithEmail(email, password);
        if (mounted) context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(_isSignUp ? 'Registration Failed' : 'Login Failed'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.oobCode != null ? 'Complete Recovery' : (_isSignUp ? 'Create Account' : 'Welcome Sard'),
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _isSignUp ? 'Choose your favorite menu and join us' : 'Sign in to your account',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),
              
              if (_isSignUp && widget.oobCode == null) ...[
                CustomTextField(
                  label: 'Name',
                  placeholder: 'your name',
                  controller: _nameCtrl,
                ),
                const SizedBox(height: 24),
              ],

              CustomTextField(
                label: 'Email',
                placeholder: 'your email',
                controller: _emailCtrl,
              ),
              const SizedBox(height: 24),
              
              CustomTextField(
                label: 'Password',
                placeholder: 'your password',
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
                      'Forgot Password?',
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
                text: widget.oobCode != null ? 'Complete Recovery' : (_isSignUp ? 'Register' : 'Login'),
                onPressed: _handleSubmit,
                isLoading: auth.isLoading,
              ),
              
              const SizedBox(height: 48),
              Center(
                child: CupertinoButton(
                  child: Text(
                    _isSignUp ? 'Have an account? Sign In' : 'New here? Create Account',
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
              // Subtle Google Login
              Center(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    try {
                      await auth.signInWithGoogle();
                      if (context.mounted) context.go(AppRoutes.home);
                    } catch (e) {
                      _showError(e.toString());
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Continue with ', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      Text('Google', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
}
