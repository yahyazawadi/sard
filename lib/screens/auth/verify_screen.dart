import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_routes.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/sard_background.dart';

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
        backgroundColor: Colors.transparent,
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
        child: SardBackground(
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
                      AppLocalizations.of(context)!.checkYourEmail,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.verificationLinkSent,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    CupertinoButton(
                      child: Text(
                        AppLocalizations.of(context)!.didntReceiveEmailTryAgain,
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
      ),
    );
  }
}
