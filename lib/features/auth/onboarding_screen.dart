import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../shared/theme/theme_mode_notifier.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _items = [
    (
      image: 'assets/images/onboarding_1.png',
      titleKey: 'onboarding_title_1',
      bodyKey: 'onboarding_body_1',
      badgeKey: 'onboarding_badge_1',
    ),
    (
      image: 'assets/images/onboarding_2.png',
      titleKey: 'onboarding_title_2',
      bodyKey: 'onboarding_body_2',
      badgeKey: 'onboarding_badge_2',
    ),
    (
      image: 'assets/images/onboarding_3.png',
      titleKey: 'onboarding_title_3',
      bodyKey: 'onboarding_body_3',
      badgeKey: 'onboarding_badge_3',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = context.watch<ThemeModeNotifier>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF101A2E) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : AppTheme.outline.withValues(alpha: 0.9),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: isDark ? 0.96 : 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/images/educollab_lockup.png',
                        width: 132,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: themeMode.toggle,
                    icon: Icon(
                      themeMode.isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF111A2A)
                          : Colors.white,
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF23314A)
                            : AppTheme.outline.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => context.go('/signup'),
                    child: Text(context.tr('skip')),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final step = _items[i];
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final imageHeight = constraints.maxHeight * 0.42;
                        return SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF0F172A)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(32),
                                        border: Border.all(
                                          color: isDark
                                              ? const Color(0xFF23314A)
                                              : AppTheme.outline.withValues(
                                                  alpha: 0.9,
                                                ),
                                        ),
                                        boxShadow: AppElevations.lift,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: SizedBox(
                                          height: imageHeight,
                                          width: double.infinity,
                                          child: DecoratedBox(
                                          decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF0B1324)
                                                  : const Color(0xFFF7FAFF),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(
                                                8,
                                                8,
                                                8,
                                                2,
                                              ),
                                              child: ColorFiltered(
                                                colorFilter: ColorFilter.mode(
                                                  isDark
                                                      ? const Color(0x66000000)
                                                      : Colors.transparent,
                                                  BlendMode.darken,
                                                ),
                                                child: Image.asset(
                                                  step.image,
                                                  fit: BoxFit.contain,
                                                  filterQuality:
                                                      FilterQuality.high,
                                                  gaplessPlayback: true,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 8,
                                      top: -8,
                                      child: Transform.rotate(
                                        angle: 0.08,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF7A1A),
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.pill,
                                            ),
                                          ),
                                          child: Text(
                                            context.tr(step.badgeKey),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  context.tr(step.titleKey),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    height: 1.12,
                                    color: isDark
                                        ? const Color(0xFFF8FAFC)
                                        : const Color(0xFF081121),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF101A2E)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: isDark
                                            ? const Color(0xFF2A3B5B)
                                            : AppTheme.outline.withValues(
                                                alpha: 0.85,
                                              ),
                                      ),
                                      boxShadow: isDark
                                          ? null
                                          : AppElevations.soft,
                                    ),
                                    child: Text(
                                      context.tr(step.bodyKey),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.55,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? const Color(0xFFF8FAFC)
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _items.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 30 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? AppTheme.primary
                          : (isDark
                                ? const Color(0xFF334155)
                                : AppTheme.outline),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_index == _items.length - 1) {
                      context.go('/signup');
                      return;
                    }
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOut,
                    );
                  },
                  icon: Icon(
                    _index == _items.length - 1
                        ? Icons.arrow_forward_rounded
                        : Icons.navigate_next_rounded,
                  ),
                  label: Text(
                    _index == _items.length - 1
                        ? context.tr('get_started')
                        : context.tr('next'),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
