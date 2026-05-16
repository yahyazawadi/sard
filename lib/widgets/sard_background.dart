import 'dart:ui';
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
        // Standard blur mask for all screens
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.transparent),
          ),
        ),
        // Optional color overlay to make content more readable
        if (applyOpacity)
          Positioned.fill(
            child: Container(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.6),
            ),
          ),
        // The actual screen content
        child,
      ],
    );
  }
}
