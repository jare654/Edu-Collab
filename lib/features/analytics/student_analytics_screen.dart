import 'package:flutter/material.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../core/localization/app_strings.dart';

class StudentAnalyticsScreen extends StatelessWidget {
  const StudentAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AppTopBar(title: context.tr('analytics')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('performance_review'),
                  style: const TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('academic_growth'),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('analytics_subtitle'),
                  style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _FuturisticHero(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _metricCard(context, context.tr('focus_hours'), '124.5', Icons.auto_stories, AppTheme.secondaryContainer, AppTheme.primary),
                _metricCard(context, context.tr('current_streak'), '14 ${context.tr('days')}',
                    Icons.local_fire_department, AppTheme.tertiary.withValues(alpha: 0.2), AppTheme.tertiary),
                _accentMetric(context.tr('gpa_equivalent'), '3.92'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLow,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppTheme.outline.withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.tr('weekly_progression'), style: const TextStyle(fontWeight: FontWeight.w700)),
                      const _Legend(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        _BarColumn(label: 'Mon', completed: 0.8, pending: 0.2),
                        _BarColumn(label: 'Tue', completed: 0.85, pending: 0.15),
                        _BarColumn(label: 'Wed', completed: 0.4, pending: 0.6),
                        _BarColumn(label: 'Thu', completed: 0.9, pending: 0.1),
                        _BarColumn(label: 'Fri', completed: 0.7, pending: 0.3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _metricCard(
      BuildContext context, String label, String value, IconData icon, Color bg, Color accent) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.2)),
        boxShadow: AppElevations.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.sm)),
                child: Icon(icon, color: accent),
              ),
              Text(context.tr('vs_last_month', params: {'value': '+12%'}),
                  style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  static Widget _accentMetric(String label, String value) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: AppTheme.primary,
        boxShadow: AppElevations.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.star, color: AppTheme.onPrimary),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 12, color: AppTheme.onPrimary.withValues(alpha: 0.8))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.onPrimary)),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(AppTheme.primary),
        const SizedBox(width: 4),
        Text(context.tr('completed'), style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        const SizedBox(width: 10),
        _dot(AppTheme.outline),
        const SizedBox(width: 4),
        Text(context.tr('pending'), style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _dot(Color color) {
    return Container(height: 8, width: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

class _BarColumn extends StatelessWidget {
  final String label;
  final double completed;
  final double pending;

  const _BarColumn({required this.label, required this.completed, required this.pending});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Container(
              height: 110,
              width: 24,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppTheme.outline.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(height: 110 * pending * value, color: AppTheme.outline.withValues(alpha: 0.4)),
                  Container(height: 110 * completed * value, color: AppTheme.primary),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _FuturisticHero extends StatefulWidget {
  const _FuturisticHero();

  @override
  State<_FuturisticHero> createState() => _FuturisticHeroState();
}

class _FuturisticHeroState extends State<_FuturisticHero> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
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
        final shift = (_controller.value * 2) - 1;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            gradient: LinearGradient(
              begin: Alignment(-1 + shift, -1),
              end: Alignment(1 - shift, 1),
              colors: [
                AppTheme.primary.withValues(alpha: 0.25),
                AppTheme.surfaceHigh,
                AppTheme.secondary.withValues(alpha: 0.2),
              ],
            ),
            border: Border.all(color: AppTheme.outline.withValues(alpha: 0.35)),
            boxShadow: AppElevations.soft,
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 30 + (shift * 12),
                child: Container(
                  height: 1,
                  color: AppTheme.primary.withValues(alpha: 0.4),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('learning_signal'),
                    style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.tr('focus_sessions'),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('analytics_signal_subtitle'),
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _NeoStat(label: context.tr('today'), value: '3.5h'),
                      const SizedBox(width: 12),
                      _NeoStat(label: context.tr('this_week'), value: '18.2h'),
                      const SizedBox(width: 12),
                      _NeoStat(label: context.tr('flow_score'), value: '92'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NeoStat extends StatelessWidget {
  final String label;
  final String value;

  const _NeoStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppTheme.outline.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
