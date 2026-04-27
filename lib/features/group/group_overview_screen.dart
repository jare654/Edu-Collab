import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../core/models/group.dart';
import 'group_notifier.dart';
import '../../core/localization/app_strings.dart';

class GroupOverviewScreen extends StatelessWidget {
  const GroupOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<GroupNotifier>();
    final groups = notifier.items;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AppTopBar(title: context.tr('groups')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('academic_collaboration'),
                  style: const TextStyle(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('group_work_overview'),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _infoBanner(
              icon: Icons.lock_outline,
              color: AppTheme.primary,
              background: AppTheme.primaryContainer,
              title: context.tr('groups_created_by_lecturer'),
              body: context.tr('groups_created_by_lecturer_subtitle'),
            ),
          ),
          const SizedBox(height: 8),
          if (notifier.loading)
            const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
          if (notifier.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: _infoBanner(
                icon: Icons.error,
                color: AppTheme.danger,
                background: AppTheme.errorContainer,
                title: context.tr('groups_unavailable'),
                body: notifier.error!,
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                for (final g in groups) _groupCard(context, g),
                if (groups.isEmpty && !notifier.loading)
                  _emptyState(
                    title: context.tr('no_groups_yet'),
                    subtitle: context.tr('no_groups_subtitle'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupCard(BuildContext context, Group g) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            children: [
              const Icon(Icons.school, color: AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  g.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceHigh,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(context.tr('members_count', params: {'count': g.members.toString()}),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            context.tr('group_course_subtitle', params: {'course': g.courseCode}),
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _avatar('A'),
              _avatar('M'),
              _avatar('L'),
              _avatar('+${g.members - 3}'),
              const SizedBox(width: 8),
              Text(context.tr('active_members'), style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.tr('current_progress'), style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              const Text('74%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: 0.74,
              backgroundColor: AppTheme.surfaceLow,
              valueColor: AlwaysStoppedAnimation(AppTheme.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: () => context.push('/student/groups/${g.id}'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                side: BorderSide(color: AppTheme.outline.withValues(alpha: 0.6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              child: Text(context.tr('open_group')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      height: 28,
      width: 28,
      decoration: BoxDecoration(
        color: AppTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
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
