import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../custom/app_theme.dart';

class SardBackground extends StatelessWidget {
  final Widget child;
  final bool applyOpacity;

  const SardBackground({
    super.key,
    required this.child,
    this.applyOpacity = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgPath = AppTheme.getBackgroundPath(theme);

    return Stack(
      children: [
        // The Background SVG
        Positioned.fill(
          child: RepaintBoundary(
            child: SvgPicture.asset(
              bgPath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Optional overlay to make content more readable if needed
        if (applyOpacity)
          Positioned.fill(
            child: Container(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
            ),
          ),
        // The actual screen content
        child,
      ],
    );
  }
}
