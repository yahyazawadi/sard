import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});


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
                  context.go(AppRoutes.login);
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
