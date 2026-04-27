import 'package:flutter/material.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_strings.dart';
import 'package:provider/provider.dart';
import '../group/group_notifier.dart';
import '../../core/models/group.dart';

class LecturerGroupsScreen extends StatelessWidget {
  const LecturerGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<GroupNotifier>().items;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AppTopBar(title: context.tr('groups')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('groups_overview'),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(context.tr('groups_overview_subtitle'),
                    style: const TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/lecturer/groups/create'),
                icon: const Icon(Icons.group_add),
                label: Text(context.tr('create_group')),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/lecturer/groups/manage'),
                icon: const Icon(Icons.manage_accounts),
                label: Text(context.tr('manage_groups')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: AppTheme.outline.withValues(alpha: 0.6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                for (final g in groups) _groupCard(context, g),
                if (groups.isEmpty)
                  _emptyState(
                    context.tr('no_groups_yet'),
                    context.tr('no_groups_subtitle'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupCard(BuildContext context, Group group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Text(group.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(group.courseCode,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: 0.6,
              minHeight: 8,
              backgroundColor: AppTheme.surfaceLow,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => context.push('/lecturer/groups/${group.id}'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              side: BorderSide(color: AppTheme.outline.withValues(alpha: 0.6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            child: Text(context.tr('open_group')),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String title, String subtitle) {
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
}
