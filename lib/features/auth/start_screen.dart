import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/localization/locale_notifier.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../shared/theme/theme_mode_notifier.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeNotifier = context.watch<LocaleNotifier>();
    final themeMode = context.watch<ThemeModeNotifier>();
    final languageCode = localeNotifier.locale?.languageCode ?? 'en';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            Row(
              children: [
                _BrandWordmark(languageCode: languageCode),
                const Spacer(),
                _HeaderAction(
                  icon: Icons.language_rounded,
                  label: languageCode == 'am' ? 'AM' : 'EN',
                  onTap: () => _showLanguagePicker(context, localeNotifier),
                ),
                const SizedBox(width: 10),
                _HeaderAction(
                  icon: Icons.help_outline_rounded,
                  label: context.tr('support'),
                  onTap: () => _showSupportSheet(context),
                ),
                const SizedBox(width: 10),
                _HeaderAction(
                  icon: themeMode.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  label: '',
                  onTap: themeMode.toggle,
                ),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF101A2E) : Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2A3B5B)
                      : AppTheme.outline.withValues(alpha: 0.9),
                ),
                boxShadow: AppElevations.lift,
              ),
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 0.95,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0B1324)
                          : const Color(0xFFF7FAFF),
                    ),
                    child: Image.asset(
                      'assets/images/welcome_students.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A1A),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26FF7A1A),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Text(
                    context.tr('start_tagline'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              context.tr('welcome_to'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(0xFFF8FAFC) : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'EduCollab',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 42,
                height: 1.05,
                fontWeight: FontWeight.w900,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                context.tr('start_description'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF334155),
                  fontSize: 17,
                  height: 1.65,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/onboarding'),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(context.tr('get_started')),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/login'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(context.tr('login')),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _MetaPill(
                    icon: Icons.verified_rounded,
                    label: context.tr('secure_workspace'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetaPill(
                    icon: Icons.groups_rounded,
                    label: context.tr('live_collaboration'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                context.tr('agree_terms'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF334155),
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('footer_credit'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : AppTheme.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('support'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.tr('support_message'),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
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
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('language'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
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
      ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      tileColor: selected ? AppTheme.secondaryContainer : AppTheme.surfaceLow,
      title: Text(label),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary)
          : null,
    );
  }
}

class _BrandWordmark extends StatelessWidget {
  const _BrandWordmark({required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF101A2E) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2A3B5B)
                  : AppTheme.outline.withValues(alpha: 0.9),
            ),
            boxShadow: AppElevations.soft,
          ),
          padding: const EdgeInsets.all(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isDark ? 0.96 : 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset('assets/images/academic_collab_mark.png'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/educollab_lockup.png',
              height: 26,
              fit: BoxFit.contain,
            ),
            Text(
              languageCode == 'am' ? 'አካዳሚክ ትብብር' : 'Academic workspace',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? const Color(0xFF23314A)
                : AppTheme.outline.withValues(alpha: 0.9),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primary),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.primaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF23314A)
              : AppTheme.outline.withValues(alpha: 0.9),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.primary, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
