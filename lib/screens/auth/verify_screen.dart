import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_routes.dart';

class VerifyScreen extends StatelessWidget {
  const VerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.login);
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
            ),
            onPressed: () => context.go(AppRoutes.login),
          ),
          previousPageTitle: '',
          backgroundColor: Colors.transparent,
          border: null,
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.mail_solid,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Check Your Email',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We sent a verification link to your email.\nClick the link to activate your account.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  CupertinoButton(
                    child: const Text(
                      'Didn\'t receive the email?\nTry again',
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () => context.go(AppRoutes.login),
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
