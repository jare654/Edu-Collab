import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AppBackgroundLayer(),
        Positioned.fill(child: child),
      ],
    );
  }
}

class AppBackgroundLayer extends StatelessWidget {
  const AppBackgroundLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppTheme.background),
        Positioned(
          top: -140,
          right: -100,
          child: _GlowBlob(color: AppTheme.primary.withValues(alpha: 0.10), size: 360),
        ),
        Positioned(
          bottom: -100,
          left: -60,
          child: _GlowBlob(color: AppTheme.secondary.withValues(alpha: 0.18), size: 320),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.16,
          right: 24,
          child: _RingHalo(
            color: AppTheme.primary.withValues(alpha: 0.08),
            size: 180,
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.34,
          left: -40,
          child: Container(
            width: MediaQuery.of(context).size.width * 1.3,
            height: 1,
            color: AppTheme.primary.withValues(alpha: 0.05),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.18),
                    Colors.transparent,
                    AppTheme.secondary.withValues(alpha: 0.07),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 140,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}

class _RingHalo extends StatelessWidget {
  final Color color;
  final double size;

  const _RingHalo({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color),
      ),
    );
  }
}
