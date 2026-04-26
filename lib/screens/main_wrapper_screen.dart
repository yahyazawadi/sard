import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import '../custom/app_theme.dart';

final mainWrapperPageProvider = StateProvider<int>((ref) => 0);

class SardPageScrollPhysics extends PageScrollPhysics {
  const SardPageScrollPhysics({super.parent});

  @override
  SardPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SardPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get minFlingVelocity => 40.0; // Lower velocity required to trigger fling

  @override
  double get minFlingDistance => 8.0; // Shorter distance required for fling

  @override
  Tolerance get tolerance => const Tolerance(
        velocity: 1.0 / 0.001, // Default is 1.0 / 0.001
        distance: 0.01, // Default is 0.01
      );
}

class MainWrapperScreen extends ConsumerStatefulWidget {
  const MainWrapperScreen({super.key});

  @override
  ConsumerState<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends ConsumerState<MainWrapperScreen> {
  late final PageController _pageController;
  int _navSelectedIndex = 0; // Drives the navbar - only set on tap or final settle

  @override
  void initState() {
    super.initState();
    final initialPage = ref.read(mainWrapperPageProvider);
    _navSelectedIndex = initialPage;
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(mainWrapperPageProvider);
    final isSearchMode = ref.watch(isSearchModeProvider);

    // Sync PageController if state changed externally (e.g. from checkout screen)
    ref.listen<int>(mainWrapperPageProvider, (previous, next) {
      if (next != _navSelectedIndex) {
        setState(() => _navSelectedIndex = next);
      }
      if (_pageController.hasClients && _pageController.page?.round() != next) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });

    return PopScope(
      canPop: !isSearchMode && currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (isSearchMode && currentPage == 0) {
          ref.read(homeResetProvider.notifier).state++;
        } else if (currentPage != 0) {
          ref.read(mainWrapperPageProvider.notifier).state = 0;
        }
      },
      child: Scaffold(
        body: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: PageView(
            controller: _pageController,
            physics: isSearchMode
                ? const NeverScrollableScrollPhysics()
                : const SardPageScrollPhysics(parent: BouncingScrollPhysics()),
            onPageChanged: (index) {
              // Only update the provider when the page fully settles.
              // Do NOT update _navSelectedIndex here to avoid intermediate flicker.
              ref.read(mainWrapperPageProvider.notifier).state = index;
              // If user physically swiped (not a tap), sync the navbar at the end.
              if (index != _navSelectedIndex) {
                setState(() => _navSelectedIndex = index);
              }
            },
            children: const [
              KeepAlivePage(child: HomeScreen()),
              KeepAlivePage(child: CartScreen()),
              KeepAlivePage(child: ProfileScreen()),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _navSelectedIndex,
          onDestinationSelected: (index) {
            if (index == 0 && currentPage == 0) {
              ref.read(homeResetProvider.notifier).state++;
            }
            // Update navbar immediately on tap — no flicker from animation
            setState(() => _navSelectedIndex = index);
            ref.read(mainWrapperPageProvider.notifier).state = index;
          },
          destinations: [
            NavigationDestination(
              icon: const SizedBox(
                width: 52,
                height: 52,
                child: Center(child: Icon(Icons.home_outlined)),
              ),
              selectedIcon: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Icon(Icons.home_rounded)),
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const SizedBox(
                width: 52,
                height: 52,
                child: Center(child: Icon(Icons.shopping_cart_outlined)),
              ),
              selectedIcon: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Icon(Icons.shopping_cart_rounded)),
              ),
              label: 'Cart',
            ),
            NavigationDestination(
              icon: const SizedBox(
                width: 52,
                height: 52,
                child: Center(child: Icon(Icons.person_outline_rounded)),
              ),
              selectedIcon: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Icon(Icons.person_rounded)),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class KeepAlivePage extends StatefulWidget {
  final Widget child;
  const KeepAlivePage({super.key, required this.child});

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(child: widget.child);
  }
}
