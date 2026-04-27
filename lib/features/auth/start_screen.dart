import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/localization/locale_notifier.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});
  static const _primary = Color(0xFF5EEDF9);
  static const _primaryContainer = Color(0xFF36D1DC);
  static const _surface = Color(0xFF0B1420);
  static const _surfaceLow = Color(0xFF131C29);
  static const _surfaceHigh = Color(0xFF222A38);
  static const _surfaceHighest = Color(0xFF2C3543);
  static const _onSurface = Color(0xFFDAE3F5);
  static const _onSurfaceVariant = Color(0xFFBBC9CA);

  @override
  Widget build(BuildContext context) {
    final localeNotifier = context.watch<LocaleNotifier>();
    final languageCode = localeNotifier.locale?.languageCode ?? 'en';
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 18),
                      const _LogoBlock(),
                      const SizedBox(height: 28),
                      Column(
                        children: [
                          const Text(
                            'EduCollab',
                            style: TextStyle(
                              color: _primary,
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.tr('start_subtitle'),
                            style: const TextStyle(
                              color: Color(0xCCB2C5FF),
                              fontSize: 14,
                              letterSpacing: 2.4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Column(
                        children: [
                          _PrimaryAction(
                            label: context.tr('login'),
                            icon: Icons.login,
                            onTap: () => context.go('/login'),
                          ),
                          const SizedBox(height: 14),
                          _SecondaryAction(
                            label: context.tr('create_account'),
                            icon: Icons.person_add_alt_1,
                            onTap: () => context.go('/signup'),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: _surfaceLow,
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                                    builder: (context) => SafeArea(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Support', style: TextStyle(color: _onSurface, fontSize: 20, fontWeight: FontWeight.w700)),
                                            const SizedBox(height: 16),
                                            const Text('Need help? Contact our support team directly at:', style: TextStyle(color: _onSurfaceVariant, fontSize: 14)),
                                            const SizedBox(height: 12),
                                            const Text('support@educollab.com', style: TextStyle(color: _primary, fontSize: 18, fontWeight: FontWeight.w600)),
                                            const SizedBox(height: 24),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () => Navigator.pop(context),
                                                style: ElevatedButton.styleFrom(backgroundColor: _surfaceHigh, foregroundColor: _onSurface),
                                                child: const Text('Close'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.help_outline,
                                  size: 16,
                                  color: _onSurfaceVariant,
                                ),
                                label: Text(
                                  context.tr('support'),
                                  style: const TextStyle(
                                    color: _onSurfaceVariant,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.6,
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 14,
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                color: _onSurfaceVariant.withValues(alpha: 0.3),
                              ),
                              TextButton.icon(
                                onPressed: () =>
                                    _showLanguagePicker(context, localeNotifier),
                                icon: const Icon(
                                  Icons.language,
                                  size: 16,
                                  color: _onSurfaceVariant,
                                ),
                                label: Text(
                                  languageCode == 'am' ? 'AM' : 'EN',
                                  style: const TextStyle(
                                    color: _onSurfaceVariant,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          const SizedBox(
                            width: 48,
                            height: 4,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: _surfaceHigh,
                                borderRadius: BorderRadius.all(Radius.circular(999)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.tr('footer_credit'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0x66B2C5FF),
                              fontSize: 12,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    LocaleNotifier localeNotifier,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surfaceLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('language'),
                  style: const TextStyle(
                    color: _onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _languageTile(
                  context,
                  localeNotifier,
                  'en',
                  context.tr('english'),
                ),
                _languageTile(
                  context,
                  localeNotifier,
                  'am',
                  context.tr('amharic'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _languageTile(
    BuildContext context,
    LocaleNotifier localeNotifier,
    String code,
    String label,
  ) {
    final selected = (localeNotifier.locale?.languageCode ?? 'en') == code;
    return ListTile(
      onTap: () {
        localeNotifier.setLocale(Locale(code));
        Navigator.pop(context);
      },
      title: Text(label, style: const TextStyle(color: _onSurface)),
      trailing: selected ? const Icon(Icons.check, color: _primary) : null,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _LogoBlock extends StatefulWidget {
  const _LogoBlock();

  @override
  State<_LogoBlock> createState() => _LogoBlockState();
}

class _LogoBlockState extends State<_LogoBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scan;
  late final Animation<double> _lockClick;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
    _scan = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _lockClick = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.12), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1), weight: 15),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scanY = lerpDouble(-0.2, 1.05, _scan.value) ?? 0;
        final orbit = _controller.value * math.pi * 2;
        final shimmer = 0.55 + (math.sin(orbit) * 0.2);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: StartScreen._surfaceLow.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: StartScreen._primary.withValues(alpha: 0.24),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: StartScreen._primary.withValues(alpha: 0.14),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 166,
                height: 166,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.07),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Transform.rotate(
                angle: orbit * 0.07,
                child: Container(
                  width: 126,
                  height: 126,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: StartScreen._primary.withValues(alpha: 0.28),
                    ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.16),
                          StartScreen._surfaceHighest.withValues(alpha: 0.64),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.28),
                        width: 1.1,
                      ),
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: shimmer,
                        child: Text(
                          'EC',
                          style: TextStyle(
                            color: StartScreen._primary.withValues(alpha: 0.96),
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: StartScreen._primary.withValues(alpha: 0.34),
                    width: 1.2,
                  ),
                ),
              ),
              Positioned(
                top: 140 * scanY,
                child: Container(
                  width: 146,
                  height: 2,
                  decoration: BoxDecoration(
                    color: StartScreen._primary.withValues(alpha: 0.62),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: StartScreen._primary.withValues(alpha: 0.34),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                child: Transform.scale(
                  scale: _lockClick.value,
                  child: Text(
                    'SYNC',
                    style: TextStyle(
                      color: StartScreen._primary.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        elevation: 8,
        shadowColor: StartScreen._primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [StartScreen._primary, StartScreen._primaryContainer],
            ),
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: StartScreen._surface),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: StartScreen._surface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: StartScreen._surfaceHigh,
          foregroundColor: StartScreen._onSurface,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
