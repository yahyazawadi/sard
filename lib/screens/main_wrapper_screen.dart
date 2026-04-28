import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';


final mainWrapperPageProvider = StateProvider<int>((ref) => 0);
final tabHistoryProvider = StateProvider<List<int>>((ref) => [0]);

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
  // Tracks the navbar highlight — set immediately on tap to avoid flicker
  // through intermediate pages during animation.
  int _navIndex = 0;
  bool _isProgrammaticScroll = false;

  @override
  void initState() {
    super.initState();
    final initialPage = ref.read(mainWrapperPageProvider);
    _navIndex = initialPage;
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (index == _navIndex) return;

    // Immediately highlight the destination in the navbar
    setState(() => _navIndex = index);

    // Update history
    final history = ref.read(tabHistoryProvider);
    if (history.isEmpty || history.last != index) {
      ref.read(tabHistoryProvider.notifier).state = [...history, index];
    }

    // Animate the PageView through intermediate pages (visual flow)
    if (_pageController.hasClients && _pageController.page?.round() != index) {
      _isProgrammaticScroll = true;
      _pageController
          .animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          )
          .then((_) => _isProgrammaticScroll = false);
    }
    ref.read(mainWrapperPageProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(mainWrapperPageProvider);
    final isSearchMode = ref.watch(isSearchModeProvider);

    // Sync when state changed externally (e.g. from checkout screen)
    ref.listen<int>(mainWrapperPageProvider, (previous, next) {
      if (next != _navIndex) {
        _goToPage(next);
      }
    });

    return PopScope(
      canPop: !isSearchMode && currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (isSearchMode && currentPage == 0) {
          ref.read(homeResetProvider.notifier).state++;
        } else if (currentPage != 0) {
          final history = ref.read(tabHistoryProvider);
          if (history.length > 1) {
            final newHistory = List<int>.from(history)..removeLast();
            ref.read(tabHistoryProvider.notifier).state = newHistory;
            _goToPage(newHistory.last);
          } else {
            _goToPage(0);
          }
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
              // During programmatic animation, don't update navbar (already set)
              // Only update for manual finger swipes
              if (!_isProgrammaticScroll) {
                setState(() => _navIndex = index);
                ref.read(mainWrapperPageProvider.notifier).state = index;

                // Update history
                final history = ref.read(tabHistoryProvider);
                if (history.isEmpty || history.last != index) {
                  ref.read(tabHistoryProvider.notifier).state = [
                    ...history,
                    index,
                  ];
                }
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
          selectedIndex: _navIndex,
          onDestinationSelected: (index) {
            if (index == 0 && _navIndex == 0) {
              ref.read(homeResetProvider.notifier).state++;
            }
            _goToPage(index);
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
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
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
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
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
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
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
