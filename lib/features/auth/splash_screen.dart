import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/theme_mode_notifier.dart';
import 'auth_notifier.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3900),
    )..forward();
    _timer = Timer(const Duration(milliseconds: 4100), _goNext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _goNext() {
    if (!mounted) return;
    final auth = context.read<AuthNotifier>();
    if (auth.isAuthenticated && auth.role != null) {
      context.go(
        auth.role!.name == 'student' ? '/student/home' : '/lecturer/dashboard',
      );
      return;
    }
    context.go('/start');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = context.watch<ThemeModeNotifier>();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF081121), Color(0xFF101A2E)]
                : const [Color(0xFFF8FBFF), Color(0xFFEAF2FF)],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              final dotProgress = Curves.easeOutCubic.transform(
                _interval(t, 0.0, 0.28),
              );
              final orbitProgress = Curves.easeInOut.transform(
                _interval(t, 0.25, 0.56),
              );
              final markOpacity = Curves.easeOut.transform(
                _interval(t, 0.52, 0.76),
              );
              final lockupOpacity = Curves.easeOut.transform(
                _interval(t, 0.72, 1.0),
              );

              return Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: IconButton(
                        onPressed: themeMode.toggle,
                        icon: Icon(
                          themeMode.isDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: orbitProgress * 0.5,
                          child: Container(
                            width: 132,
                            height: 132,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primary.withValues(alpha: 0.18),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        for (final dot in _dots(dotProgress, orbitProgress))
                          Transform.translate(
                            offset: dot.offset,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: dot.color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: dot.color.withValues(alpha: 0.24),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Transform.scale(
                          scale: 0.9 + (0.1 * markOpacity),
                          child: Opacity(
                            opacity: markOpacity,
                            child: Container(
                              width: 126,
                              height: 126,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(
                                  alpha: isDark ? 0.04 : 0.8,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Image.asset(
                                  'assets/images/academic_collab_mark.png',
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Opacity(
                    opacity: 1 - markOpacity.clamp(0, 1),
                    child: Text(
                      t < 0.28
                          ? context.tr('splash_copy_1')
                          : t < 0.56
                          ? context.tr('splash_copy_2')
                          : context.tr('splash_copy_3'),
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : AppTheme.textSecondary,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, 12 * (1 - lockupOpacity)),
                    child: Opacity(
                      opacity: lockupOpacity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF101A2E)
                              : Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF2A3B5B)
                                : AppTheme.outline.withValues(alpha: 0.8),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: isDark ? 0.95 : 0.82,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Image.asset(
                            'assets/images/educollab_lockup.png',
                            width: 280,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Opacity(
                    opacity: lockupOpacity,
                    child: Text(
                      context.tr('splash_tagline'),
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : AppTheme.textSecondary,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  double _interval(double t, double begin, double end) {
    if (t <= begin) return 0;
    if (t >= end) return 1;
    return (t - begin) / (end - begin);
  }

  List<_AnimatedDot> _dots(double spread, double orbit) {
    const colors = [
      Color(0xFFA855F7),
      Color(0xFFFBBF24),
      Color(0xFF60D5B2),
      Color(0xFF3B82F6),
    ];
    const baseAngles = [-math.pi / 2, 0.0, math.pi, math.pi / 2];
    final rotation = orbit * math.pi * 1.35;
    return List.generate(colors.length, (i) {
      final angle = baseAngles[i] + rotation;
      final radius = 62 * spread;
      return _AnimatedDot(
        color: colors[i],
        offset: Offset(math.cos(angle) * radius, math.sin(angle) * radius),
      );
    });
  }
}

class _AnimatedDot {
  const _AnimatedDot({required this.color, required this.offset});

  final Color color;
  final Offset offset;
}
