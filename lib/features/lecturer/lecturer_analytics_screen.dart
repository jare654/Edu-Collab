import 'package:flutter/material.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../core/localization/app_strings.dart';

class LecturerAnalyticsScreen extends StatelessWidget {
  const LecturerAnalyticsScreen({super.key});

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
                Text(context.tr('lecturer_analytics'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(context.tr('lecturer_analytics_subtitle'),
                    style: const TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const _LecturerSignalCard(),
                const SizedBox(height: 12),
                _MetricRow(title: context.tr('submission_trends'), value: context.tr('on_time_rate', params: {'value': '92%'})),
                const SizedBox(height: 10),
                _MetricRow(title: context.tr('average_grade'), value: '84%'),
                const SizedBox(height: 10),
                _MetricRow(title: context.tr('feedback_turnaround'), value: context.tr('days_value', params: {'value': '2.4'})),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String title;
  final String value;

  const _MetricRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.2)),
        boxShadow: AppElevations.soft,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary)),
        ],
      ),
    );
  }
}

class _LecturerSignalCard extends StatefulWidget {
  const _LecturerSignalCard();

  @override
  State<_LecturerSignalCard> createState() => _LecturerSignalCardState();
}

class _LecturerSignalCardState extends State<_LecturerSignalCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
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
                AppTheme.secondary.withValues(alpha: 0.18),
                AppTheme.surfaceHigh,
                AppTheme.primary.withValues(alpha: 0.18),
              ],
            ),
            border: Border.all(color: AppTheme.outline.withValues(alpha: 0.35)),
            boxShadow: AppElevations.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('teaching_signal'),
                  style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 11)),
              const SizedBox(height: 10),
              Text(context.tr('class_pulse'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(context.tr('analytics_signal_lecturer_subtitle'),
                  style: const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 14),
              Row(
                children: [
                  _SignalStat(label: context.tr('on_time'), value: '92%'),
                  const SizedBox(width: 10),
                  _SignalStat(label: context.tr('avg_grade'), value: '84'),
                  const SizedBox(width: 10),
                  _SignalStat(label: context.tr('feedback_speed'), value: '2.4d'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SignalStat extends StatelessWidget {
  final String label;
  final String value;

  const _SignalStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppTheme.outline.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
