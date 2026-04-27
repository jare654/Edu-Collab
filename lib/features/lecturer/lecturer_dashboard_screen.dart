import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_notifier.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../core/localization/app_strings.dart';
import '../meetings/meeting_logs_repository.dart';

class LecturerDashboardScreen extends StatelessWidget {
  const LecturerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthNotifier>().user;
    final displayName = user?.name ?? 'Lecturer';
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AppTopBar(title: context.tr('dashboard'), showMenu: !isWide),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heroCard(context, displayName),
                const SizedBox(height: 12),
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Column(
                              children: [
                                _focusAssignments(context),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                _meetingPanel(context),
                                const SizedBox(height: 16),
                                _recentSubmissionsPanel(context),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _focusAssignments(context),
                          const SizedBox(height: 16),
                          _meetingPanel(context),
                          const SizedBox(height: 16),
                          _recentSubmissionsPanel(context),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCard(BuildContext context, String displayName) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  context.tr(
                    'welcome_back_name',
                    params: {'name': displayName},
                  ),
                  style: const TextStyle(
                    color: AppTheme.primaryContainer,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  border: Border.all(color: AppTheme.outline.withValues(alpha: 0.9)),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            context.tr('dashboard'),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryContainer,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('lecturer_dashboard_subtitle'),
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/lecturer/assignments/create'),
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(context.tr('create_assignment')),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => context.push('/lecturer/meetings'),
                child: Text(context.tr('view_logs')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _focusAssignments(BuildContext context) {
    return _dashboardPanel(
      context,
      title: context.tr('assignments'),
      subtitle: context.tr('priority_focus'),
      child: Column(
        children: [
          _focusCard(
            course: 'CS 301',
            title: 'Final Project Critique',
            due: 'Nov 02',
            progress: 0.70,
            accent: AppTheme.primaryContainer,
          ),
          const SizedBox(height: 12),
          _focusCard(
            course: 'MATH 202',
            title: 'Group Paper Review',
            due: 'Nov 15',
            progress: 0.45,
            accent: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _meetingPanel(BuildContext context) {
    return _dashboardPanel(
      context,
      title: context.tr('meeting_oversight'),
      subtitle: context.tr('meeting_oversight_subtitle'),
      child: StreamBuilder<int>(
        stream: _activeSessionsStream(context.read<MeetingLogsRepository>()),
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.secondaryContainer,
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: AppTheme.outline.withValues(alpha: 0.8)),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.video_camera_front_outlined,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            count > 0
                                ? context.tr(
                                    'active_call_badge',
                                    params: {'count': '$count'},
                                  )
                                : context.tr('meeting_logs'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            count > 0
                                ? context.tr('live_badge')
                                : context.tr('attendance_dashboard_subtitle'),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/lecturer/meetings'),
                  icon: const Icon(Icons.insights_outlined),
                  label: Text(context.tr('view_logs')),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _recentSubmissionsPanel(BuildContext context) {
    return _dashboardPanel(
      context,
      title: context.tr('recent_submissions'),
      subtitle: context.tr('stay_on_schedule'),
      child: Column(
        children: [
          _submissionRow(
            'Dagmawit Assefa',
            'Urban Fabric Case Study',
            '2h ago',
          ),
          _submissionRow(
            'Henok Tadesse',
            'Modernist Housing Analysis',
            '5h ago',
          ),
          _submissionRow(
            'Saron Mekuria',
            'Public Space Typology',
            '1d ago',
          ),
        ],
      ),
    );
  }

  Widget _submissionRow(String name, String title, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primary.withValues(alpha: 0.14),
            child: Text(
              name.substring(0, 1),
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _dashboardPanel(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.9)),
        boxShadow: AppElevations.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _focusCard({
    required String course,
    required String title,
    required String due,
    required double progress,
    required Color accent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent == AppTheme.primaryContainer
                ? AppTheme.primaryContainer
                : AppTheme.primary,
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
                  '$course: $title',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              Text(
                'Due $due',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
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
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Design and develop a functional Flutter experience with polished lecturer oversight and collaborative review flow.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _miniAvatar('DS', AppTheme.primaryContainer),
              const SizedBox(width: 6),
              _miniAvatar('AL', const Color(0xFF5EA8FF)),
              const SizedBox(width: 6),
              _miniAvatar('MB', const Color(0xFF62D2C8)),
              const Spacer(),
              OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: const Text('View Details'),
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
        color: color.withValues(alpha: 0.25),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.9)),
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

  Stream<int> _activeSessionsStream(MeetingLogsRepository repo) {
    return repo.watchSessions().map(
      (items) => items.where((e) => e.session.endTime == null).length,
    );
  }
}
