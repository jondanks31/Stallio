import 'package:flutter/material.dart';

/// Reusable gradient background widget used across all pages.
/// Provides the warm yellow gradient theme consistent with the app design.
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base background color
        Container(
          color: isDark ? const Color(0xFF020617) : const Color(0xFFEDEDED),
        ),
        // Gradient 1: Bottom Left warm yellow glow
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: isDark
                  ? [const Color(0xFF0F172A), Colors.transparent]
                  : [
                      const Color(0xFFFEF08A),
                      const Color(0xFFFEFBEB),
                      const Color(0xFFEDEDED).withValues(alpha: 0.0),
                    ],
              stops: const [0.0, 0.4, 1.0],
              center: Alignment.bottomLeft,
              radius: 1.8,
            ),
          ),
        ),
        // Gradient 2: Right Side Lower-Middle warm yellow glow
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: isDark
                  ? [const Color(0xFF0F172A), Colors.transparent]
                  : [
                      const Color(0xFFFEF08A).withValues(alpha: 0.8),
                      const Color(0xFFFEFBEB).withValues(alpha: 0.8),
                      const Color(0xFFEDEDED).withValues(alpha: 0.0),
                    ],
              stops: const [0.0, 0.4, 1.0],
              center: const Alignment(1.2, 0.4),
              radius: 1.5,
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}
