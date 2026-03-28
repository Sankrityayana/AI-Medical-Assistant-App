import 'package:flutter/material.dart';

class BlueGradientBackground extends StatelessWidget {
  final Widget child;

  const BlueGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.45),
            scheme.tertiaryContainer.withValues(alpha: 0.4),
            scheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -30,
            child: _Bubble(color: scheme.primary.withValues(alpha: 0.12), size: 170),
          ),
          Positioned(
            bottom: -70,
            left: -35,
            child: _Bubble(color: scheme.secondary.withValues(alpha: 0.14), size: 210),
          ),
          child,
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Color color;
  final double size;

  const _Bubble({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
