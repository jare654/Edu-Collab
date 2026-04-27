import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_notifier.dart';
import '../../features/assignments/student_assignments_notifier.dart';
import '../../features/resources/resources_notifier.dart';
import '../../features/notifications/notifications_notifier.dart';
import '../../core/models/assignment.dart';
import '../chat/meet_notifier.dart';
import '../../core/localization/app_strings.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/app_top_bar.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assignments = context.watch<StudentAssignmentsNotifier>().items;
    final resources = context.watch<ResourcesNotifier>().items;
    final notifications = context.watch<NotificationsNotifier?>();
    final meet = context.watch<MeetNotifier>();
    final dueCount = assignments.where((a) => a.status == AssignmentStatus.upcoming).length;
    final newAssignmentCount = notifications?.assignmentCount ?? 0;
    final user = context.watch<AuthNotifier?>()?.user;
    final displayName = user?.name ?? 'Student';
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final featuredAssignments = assignments.take(3).toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AppTopBar(title: context.tr('home'), showMenu: !isWide),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heroCard(
                  context,
                  name: displayName,
                  dueCount: dueCount,
                  newAssignmentCount: newAssignmentCount,
                ),
                const SizedBox(height: 16),
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Column(
                              children: [
                                _statsGrid(
                                  context,
                                  dueCount: dueCount,
                                  newAssignmentCount: newAssignmentCount,
                                  width: 220,
                                ),
                                const SizedBox(height: 16),
                                _focusPanel(
                                  context,
                                  assignments: featuredAssignments,
                                  notifications: notifications,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                if (meet.nextMeeting != null)
                                  _meetingPanel(context, meet),
                                if (meet.nextMeeting != null)
                                  const SizedBox(height: 16),
                                _quickActionsPanel(context),
                                const SizedBox(height: 16),
                                _resourcesPanel(context, resources),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _statsGrid(
                            context,
                            dueCount: dueCount,
                            newAssignmentCount: newAssignmentCount,
                            width: double.infinity,
                          ),
                          const SizedBox(height: 16),
                          if (meet.nextMeeting != null) _meetingPanel(context, meet),
                          if (meet.nextMeeting != null) const SizedBox(height: 16),
                          _quickActionsPanel(context),
                          const SizedBox(height: 16),
                          _focusPanel(
                            context,
                            assignments: featuredAssignments,
                            notifications: notifications,
                          ),
                          const SizedBox(height: 16),
                          _resourcesPanel(context, resources),
                        ],
                      ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _heroCard(
    BuildContext context, {
    required String name,
    required int dueCount,
    required int newAssignmentCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryContainer,
            AppTheme.surface,
            Colors.white,
          ],
          stops: const [0.0, 0.42, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.10),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              context.tr('good_morning', params: {'name': name}),
              style: const TextStyle(
                color: AppTheme.primaryContainer,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            context.tr('home'),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryContainer,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr(
              'assignments_due_this_week',
              params: {'count': dueCount.toString()},
            ),
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _heroMetric(
                label: context.tr('assignments_due'),
                value: '$dueCount',
              ),
              const SizedBox(width: 12),
              _heroMetric(
                label: context.tr('new_label'),
                value: '$newAssignmentCount',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroMetric({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.outline.withValues(alpha: 0.9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryContainer,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsGrid(
    BuildContext context, {
    required int dueCount,
    required int newAssignmentCount,
    required double width,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _dashboardStatCard(
          icon: Icons.assignment_rounded,
          badge: newAssignmentCount > 0
              ? context.tr(
                  'new_items',
                  params: {'count': newAssignmentCount.toString()},
                )
              : context.tr('due_soon'),
          value: dueCount.toString().padLeft(2, '0'),
          label: context.tr('assignments_due'),
          accent: AppTheme.primary,
          width: width,
        ),
        _dashboardStatCard(
          icon: Icons.pending_actions_rounded,
          badge: context.tr('awaiting_review'),
          value: '05',
          label: context.tr('pending_submissions'),
          accent: AppTheme.tertiary,
          width: width,
        ),
        _accentStatCard(
          icon: Icons.auto_awesome_rounded,
          value: '92%',
          label: context.tr('average_grade'),
          width: width,
        ),
      ],
    );
  }

  Widget _meetingPanel(BuildContext context, MeetNotifier meet) {
    return _panel(
      context,
      title: meet.title.isEmpty ? 'In-group Meet' : meet.title,
      subtitle: meet.location,
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.schedule, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('starts_in'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meet.countdown,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => context.push('/student/schedule_session'),
            child: Text(context.tr('schedule')),
          ),
        ],
      ),
    );
  }

  Widget _quickActionsPanel(BuildContext context) {
    return _panel(
      context,
      title: context.tr('priority_focus'),
      subtitle: context.tr('stay_on_schedule'),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _ActionChip(label: context.tr('schedule_session'), icon: Icons.calendar_today, onTap: () => context.push('/student/schedule_session')),
          _ActionChip(label: context.tr('take_notes'), icon: Icons.edit_note, onTap: () => context.push('/student/notes')),
          _ActionChip(label: context.tr('study_group'), icon: Icons.forum, onTap: () => context.push('/student/chat')),
          _ActionChip(label: context.tr('bookmarks'), icon: Icons.star, onTap: () => context.push('/student/bookmarks')),
        ],
      ),
    );
  }

  Widget _focusPanel(
    BuildContext context, {
    required List<Assignment> assignments,
    required NotificationsNotifier? notifications,
  }) {
    return _panel(
      context,
      title: context.tr('upcoming_assignments'),
      subtitle: context.tr('priority_focus'),
      actionLabel: context.tr('view_all'),
      onAction: () => context.push('/student/assignments'),
      child: Column(
        children: [
          for (final a in assignments)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _featuredAssignmentCard(context, a, notifications),
            ),
        ],
      ),
    );
  }

  Widget _resourcesPanel(BuildContext context, List<dynamic> resources) {
    return _panel(
      context,
      title: context.tr('resource_library'),
      subtitle: context.tr('resources'),
      actionLabel: context.tr('view_all'),
      onAction: () => context.push('/student/resources'),
      child: Column(
        children: [
          for (final r in resources.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SectionCard(
                title: r.title,
                subtitle: context.tr(
                  'resource_card',
                  params: {'course': r.course, 'type': r.type},
                ),
                trailing: Icon(
                  r.availableOffline
                      ? Icons.download_done
                      : Icons.cloud_download,
                ),
                onTap: () => context.push('/student/resources/${r.id}'),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/student/resources'),
              icon: const Icon(Icons.arrow_forward),
              label: Text(context.tr('open_library')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel(
    BuildContext context, {
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.22)),
        boxShadow: AppElevations.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (actionLabel != null && onAction != null)
                TextButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _featuredAssignmentCard(
    BuildContext context,
    Assignment a,
    NotificationsNotifier? notifications,
  ) {
    final dayDelta = a.dueDate.difference(DateTime.now()).inDays.abs() + 1;
    final progress = (1 / dayDelta).clamp(0.18, 0.86);
    final isNew = notifications?.hasNewAssignment(a.title) ?? false;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryContainer,
            AppTheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.22),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${a.course}: ${a.title}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '${a.dueDate.month}/${a.dueDate.day}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                context.tr('submission_status'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (isNew)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      context.tr('new_label'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.surfaceHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            a.description?.isNotEmpty == true
                ? a.description!
                : context.tr(
                    'assignment_due',
                    params: {
                      'course': a.course,
                      'date': '${a.dueDate.month}/${a.dueDate.day}',
                    },
                  ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _miniAvatar('ST', AppTheme.secondary),
              const SizedBox(width: 6),
              _miniAvatar('GR', AppTheme.tertiary),
              const Spacer(),
              OutlinedButton(
                onPressed: () => context.push('/student/assignments/${a.id}'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Text(context.tr('view_details')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniAvatar(String label, Color color) {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.24),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.8)),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _dashboardStatCard({
    required IconData icon,
    required String badge,
    required String value,
    required String label,
    required Color accent,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2E5FD0),
            const Color(0xFF5D9CFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.20),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _accentStatCard({
    required IconData icon,
    required String value,
    required String label,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF7AB6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.18),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.onPrimary),
          const SizedBox(height: 18),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.onPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: AppTheme.onPrimary.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionChip({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLow,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppTheme.outline.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
