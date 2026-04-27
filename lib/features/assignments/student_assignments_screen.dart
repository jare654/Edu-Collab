import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/models/assignment.dart';
import '../../core/network/connectivity_service.dart';
import '../notifications/notifications_notifier.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../shared/widgets/app_top_bar.dart';
import 'student_assignments_notifier.dart';
import '../../core/localization/app_strings.dart';
import '../auth/auth_notifier.dart';

class StudentAssignmentsScreen extends StatefulWidget {
  const StudentAssignmentsScreen({super.key});

  @override
  State<StudentAssignmentsScreen> createState() => _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState extends State<StudentAssignmentsScreen> {
  int _tab = 0;
  bool _groupOnly = false;
  bool _dueSoonOnly = false;
  _SortOrder _sortOrder = _SortOrder.earliest;
  
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('filter'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Group Assignments Only'),
              value: _groupOnly,
              onChanged: (val) {
                setState(() => _groupOnly = val ?? false);
                Navigator.pop(context);
              },
            ),
            CheckboxListTile(
              title: const Text('Due Soon'),
              value: _dueSoonOnly,
              onChanged: (val) {
                setState(() => _dueSoonOnly = val ?? false);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('sort_by_due_date'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Earliest First'),
              leading: const Icon(Icons.arrow_upward),
              onTap: () {
                setState(() => _sortOrder = _SortOrder.earliest);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Latest First'),
              leading: const Icon(Icons.arrow_downward),
              onTap: () {
                setState(() => _sortOrder = _SortOrder.latest);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<StudentAssignmentsNotifier>();
    final notifications = context.watch<NotificationsNotifier?>();
    final auth = context.watch<AuthNotifier?>();
    final user = auth?.user;
    final items = notifier.items;
    final online = context.watch<ConnectivityService>().isOnline;
    final isWide = MediaQuery.of(context).size.width >= 900;
    var filtered = _tab == 0
        ? items
        : _tab == 1
            ? items.where((a) => a.status == AssignmentStatus.upcoming).toList()
            : items.where((a) => a.status == AssignmentStatus.completed).toList();
    if (_groupOnly) {
      filtered = filtered.where((a) => a.isGroup).toList();
    }
    if (_dueSoonOnly) {
      final cutoff = DateTime.now().add(const Duration(days: 3));
      filtered = filtered.where((a) => a.dueDate.isBefore(cutoff)).toList();
    }
    filtered.sort((a, b) => _sortOrder == _SortOrder.earliest
        ? a.dueDate.compareTo(b.dueDate)
        : b.dueDate.compareTo(a.dueDate));

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AppTopBar(
            title: context.tr('assignments'),
            showSearch: true,
            showMenu: !isWide,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heroCard(
                  context,
                  name: user?.name ?? 'Student',
                  assignmentCount: items.length,
                  newAssignmentCount: notifications?.assignmentCount ?? 0,
                  online: online,
                ),
                const SizedBox(height: 16),
                _controlPanel(context, notifications, online),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SegmentedTabs(
              index: _tab,
              onChanged: (value) => setState(() => _tab = value),
            ),
          ),
          const SizedBox(height: 12),
          if (notifier.loading)
            const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
          if (notifier.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(notifier.error!, style: const TextStyle(color: AppTheme.danger)),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                for (final a in filtered) ...[
                  _assignmentCard(context, a),
                  const SizedBox(height: 12),
                ],
                if (filtered.isEmpty && !notifier.loading)
                  _emptyState(
                    title: _tab == 0 ? context.tr('no_assignments_yet') : context.tr('nothing_in_this_tab'),
                    subtitle: _tab == 1
                        ? context.tr('upcoming_assignments_here')
                        : _tab == 2
                            ? context.tr('completed_assignments_here')
                            : context.tr('assignments_synced_message'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _assignmentCard(BuildContext context, Assignment a) {
    final status = _statusInfo(context, a.status);
    final notifications = context.watch<NotificationsNotifier?>();
    final typeLabel = a.isGroup ? context.tr('group_assignment') : context.tr('individual_assignment');
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      status.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _Badge(
                    text: typeLabel,
                    color: Colors.white.withValues(alpha: 0.12),
                    textColor: Colors.white,
                  ),
                  _Badge(
                    text: context.tr('assigned_by_lecturer'),
                    color: Colors.white.withValues(alpha: 0.12),
                    textColor: Colors.white,
                  ),
                  if (isNew)
                    _Badge(
                      text: context.tr('new_label'),
                      color: Colors.white.withValues(alpha: 0.18),
                      textColor: Colors.white,
                    ),
                ],
              ),
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            a.course,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            a.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1.25,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _progressForAssignment(a),
              minHeight: 8,
              backgroundColor: AppTheme.surfaceHighest,
              valueColor: AlwaysStoppedAnimation<Color>(status.foreground),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(
                context.tr('due_date', params: {'date': '${a.dueDate.month}/${a.dueDate.day}'}),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/student/assignments/${a.id}'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  child: Text(context.tr('view_details')),
                ),
              ),
              const SizedBox(width: 10),
              if (a.status != AssignmentStatus.completed)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.push('/student/assignments/${a.id}/submit'),
                    child: Text(context.tr('submit')),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroCard(
    BuildContext context, {
    required String name,
    required int assignmentCount,
    required int newAssignmentCount,
    required bool online,
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
              context.tr('welcome_back_name', params: {'name': name}),
              style: const TextStyle(
                color: AppTheme.primaryContainer,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            context.tr('your_assignments'),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryContainer,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('assignments_subtitle'),
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
                label: context.tr('assignments'),
                value: '$assignmentCount',
              ),
              const SizedBox(width: 12),
              _heroMetric(
                label: context.tr('new_label'),
                value: '$newAssignmentCount',
              ),
              const SizedBox(width: 12),
              _heroMetric(
                label: online ? 'Online' : 'Offline',
                value: online ? 'Live' : 'Cached',
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
                fontSize: 22,
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

  Widget _controlPanel(
    BuildContext context,
    NotificationsNotifier? notifications,
    bool online,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.22)),
        boxShadow: AppElevations.soft,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if ((notifications?.assignmentCount ?? 0) > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                context.tr(
                  'new_assignments_waiting',
                  params: {
                    'count': (notifications?.assignmentCount ?? 0).toString(),
                  },
                ),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          _FilterChip(
            icon: Icons.tune,
            label: context.tr('filter'),
            onTap: _showFilterSheet,
          ),
          _FilterChip(
            icon: Icons.swap_vert,
            label: context.tr('sort_by_due_date'),
            onTap: _showSortSheet,
          ),
          if (!online)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.tertiaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                context.tr('offline_cached_data'),
                style: const TextStyle(
                  color: AppTheme.tertiary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _progressForAssignment(Assignment assignment) {
    return switch (assignment.status) {
      AssignmentStatus.completed => 1,
      AssignmentStatus.submitted => 0.82,
      AssignmentStatus.upcoming => 0.42,
    };
  }

  Widget _emptyState({required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(20),
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

enum _SortOrder { earliest, latest }

class _StatusInfo {
  final String label;
  final Color background;
  final Color foreground;

  const _StatusInfo(this.label, this.background, this.foreground);
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _Badge({required this.text, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textColor),
      ),
    );
  }
}

_StatusInfo _statusInfo(BuildContext context, AssignmentStatus status) {
  return switch (status) {
    AssignmentStatus.upcoming =>
      _StatusInfo(context.tr('due_soon'), AppTheme.errorContainer, AppTheme.danger),
    AssignmentStatus.completed =>
      _StatusInfo(context.tr('completed'), AppTheme.surfaceHigh, AppTheme.textSecondary),
    AssignmentStatus.submitted =>
      _StatusInfo(context.tr('submitted'), AppTheme.secondaryContainer, AppTheme.textPrimary),
  };
}

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FilterChip({required this.icon, required this.label, required this.onTap});

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

class _SegmentedTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _SegmentedTabs({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          _tabButton(context.tr('all'), 0),
          _tabButton(context.tr('upcoming'), 1),
          _tabButton(context.tr('completed'), 2),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int value) {
    final selected = index == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: selected ? AppElevations.soft : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
