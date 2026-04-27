import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../core/models/submission_item.dart';
import 'lecturer_submissions_notifier.dart';
import '../../core/localization/app_strings.dart';

class LecturerSubmissionsScreen extends StatefulWidget {
  final String assignmentId;
  const LecturerSubmissionsScreen({super.key, required this.assignmentId});

  @override
  State<LecturerSubmissionsScreen> createState() => _LecturerSubmissionsScreenState();
}

class _LecturerSubmissionsScreenState extends State<LecturerSubmissionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LecturerSubmissionsNotifier>().load(widget.assignmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _SubmissionsContent(assignmentId: widget.assignmentId),
        ],
      ),
    );
  }
}

class _SubmissionsContent extends StatelessWidget {
  final String assignmentId;
  const _SubmissionsContent({required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<LecturerSubmissionsNotifier>();
    final items = notifier.items;
    return Column(
      children: [
        AppTopBar(title: context.tr('academic_atelier')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.tr('submissions'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              ElevatedButton.icon(
                onPressed: () => context.push('/lecturer/assignments/$assignmentId/grade'),
                icon: const Icon(Icons.check),
                label: Text(context.tr('grade_all')),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              if (notifier.loading)
                const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()),
              if (notifier.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _infoBanner(
                    icon: Icons.error,
                    color: AppTheme.danger,
                    background: AppTheme.errorContainer,
                    title: context.tr('submissions_unavailable'),
                    body: notifier.error!,
                  ),
                ),
              for (final item in items) _submissionRow(context, item),
              if (items.isEmpty && !notifier.loading)
                _emptyState(
                  title: context.tr('no_submissions_yet'),
                  subtitle: context.tr('no_submissions_subtitle'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _submissionRow(BuildContext context, SubmissionItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.2)),
        boxShadow: AppElevations.soft,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: item.submitted ? AppTheme.primary.withValues(alpha: 0.1) : AppTheme.errorContainer,
            child: Icon(item.submitted ? Icons.check_circle : Icons.warning, color: item.submitted ? AppTheme.primary : AppTheme.danger),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.studentName, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(item.status, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          if (item.submitted)
            TextButton(
              onPressed: () => context.push('/lecturer/assignments/${item.assignmentId}/grade'),
              child: Text(context.tr('grade')),
            )
          else
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _emptyState({required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _infoBanner({
    required IconData icon,
    required Color color,
    required Color background,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: background.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(body, style: const TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
