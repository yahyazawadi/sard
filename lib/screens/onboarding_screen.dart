import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    // If they've already tapped "Get Started" once, they're coming back from
    // the login/signup screen — auto-reopen the auth sheet so it feels seamless.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.hasSeenOnboarding && mounted) {
        _showAuthBottomSheet(context);
      }
    });
  }

  void _showAuthBottomSheet(BuildContext context) {
    // Create a controller for the sheet itself
    final sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      transitionAnimationController: sheetController,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 0.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(50 * value, 0),
              child: Opacity(
                opacity: 1.0 - value,
                child: child,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(32, 12, 32, 40),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'All your\nBest Chocolates',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(30),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('${AppRoutes.login}?signup=true');
                      },
                      child: Text(
                        'Sign Up',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(30),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      onPressed: () {
                        Navigator.pop(context);
                        context.go(AppRoutes.login);
                      },
                      child: Text(
                        'Log In',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      Navigator.pop(context);
                      await context.read<AuthProvider>().signInAsGuest();
                      if (context.mounted) {
                        context.go(AppRoutes.home);
                      }
                    },
                    child: Text(
                      'Continue as Guest',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/onboarding_bg.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text('Please add onboarding_bg.png to assets/images/'),
              );
            },
          ),
          
          // Get Started Button
          Positioned(
            left: 24,
            right: 24,
            bottom: 96,
            child: CupertinoButton(
              color: Theme.of(context).colorScheme.primary, // dynamic color
              borderRadius: BorderRadius.circular(24),
              onPressed: () async {
                // Mark onboarding as complete when they start
                await context.read<AuthProvider>().completeOnboarding();
                if (context.mounted) {
                  _showAuthBottomSheet(context);
                }
              },
              child: Text(
                'Get Started',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
