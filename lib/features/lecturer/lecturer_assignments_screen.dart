import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../core/models/lecturer_assignment.dart';
import 'lecturer_assignments_notifier.dart';
import '../../core/localization/app_strings.dart';
import '../notifications/email_log_notifier.dart';
import '../../core/models/email_log_entry.dart';
import '../../core/feature_flags.dart';
import '../auth/auth_notifier.dart';
import '../meetings/meeting_service.dart';

class LecturerAssignmentsScreen extends StatefulWidget {
  const LecturerAssignmentsScreen({super.key});

  @override
  State<LecturerAssignmentsScreen> createState() =>
      _LecturerAssignmentsScreenState();
}

class _LecturerAssignmentsScreenState extends State<LecturerAssignmentsScreen> {
  String? _openingAssignmentId;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<LecturerAssignmentsNotifier>();
    final items = notifier.items;
    final logs = context.watch<EmailLogNotifier>().entries;
    final individual = items.where((a) => !a.isGroup).toList();
    final group = items.where((a) => a.isGroup).toList();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AppTopBar(title: context.tr('assignments')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('assignments'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push('/lecturer/assignments/create'),
                  icon: const Icon(Icons.add),
                  label: Text(context.tr('create')),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.tr('individual_assignments'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                if (notifier.loading)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),
                if (notifier.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _infoBanner(
                      icon: Icons.error,
                      color: AppTheme.danger,
                      background: AppTheme.errorContainer,
                      title: context.tr('assignments_unavailable'),
                      body: notifier.error!,
                    ),
                  ),
                for (final a in individual) _assignmentCard(context, a),
                if (individual.isEmpty && !notifier.loading)
                  _emptyState(
                    title: context.tr('no_individual_assignments'),
                    subtitle: context.tr('no_individual_assignments_subtitle'),
                  ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.tr('group_assignments'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                for (final a in group) _assignmentCard(context, a),
                if (group.isEmpty && !notifier.loading)
                  _emptyState(
                    title: context.tr('no_group_assignments'),
                    subtitle: context.tr('no_group_assignments_subtitle'),
                  ),
                const SizedBox(height: 12),
                _EmailLogPanel(entries: logs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _assignmentCard(BuildContext context, LecturerAssignment assignment) {
    final canResend =
        assignment.assignedEmails != null &&
        assignment.assignedEmails!.isNotEmpty;
    final canDirectCall =
        FeatureFlags.enableVideoCalls &&
        !assignment.isGroup &&
        (assignment.assignedEmails?.isNotEmpty ?? false);
    final isOpening = _openingAssignmentId == assignment.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryContainer, AppTheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.22),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.assignment, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (!assignment.isGroup &&
                    assignment.assignedEmails != null &&
                    assignment.assignedEmails!.length == 1) ...[
                  const SizedBox(height: 8),
                  _singleAssigneePreview(assignment.assignedEmails!.first),
                ],
                const SizedBox(height: 6),
                Text(
                  '${assignment.course} • ${assignment.submittedLabel}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (canDirectCall)
                IconButton(
                  tooltip: context.tr('call_student'),
                  onPressed: isOpening
                      ? null
                      : () => _startQuickCall(context, assignment),
                  icon: isOpening
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.videocam_outlined, size: 18),
                  color: Colors.white,
                ),
              if (isOpening)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    context.tr('opening_call'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              IconButton(
                onPressed: () => context.push(
                  '/lecturer/assignments/${assignment.id}/submissions',
                ),
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              if (canResend)
                TextButton(
                  onPressed: () async {
                    final result = await context
                        .read<LecturerAssignmentsNotifier>()
                        .resendEmails(assignment);
                    if (!context.mounted) return;
                    context.read<EmailLogNotifier>().addEntry(
                      EmailLogEntry(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        type: EmailLogType.assignment,
                        recipient: assignment.assignedEmails?.join(', ') ?? '',
                        subject: assignment.title,
                        status: result.ok
                            ? EmailLogStatus.sent
                            : EmailLogStatus.failed,
                        timestamp: DateTime.now(),
                        message: result.message,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result.ok
                              ? context.tr('email_resend_success')
                              : context.tr('email_resend_failed'),
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: Text(context.tr('resend_email')),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _singleAssigneePreview(String email) {
    final normalized = email.trim();
    final local = normalized.split('@').first;
    final parts = local
        .split(RegExp(r'[._-]+'))
        .where((e) => e.trim().isNotEmpty)
        .toList();
    final displayName = parts.isEmpty
        ? normalized
        : parts
              .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
              .join(' ');
    final initials = parts.isEmpty
        ? normalized.substring(0, 1).toUpperCase()
        : parts.take(2).map((part) => part[0].toUpperCase()).join();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
            child: Text(
              initials,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  normalized,
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startQuickCall(
    BuildContext context,
    LecturerAssignment assignment,
  ) async {
    final emails = assignment.assignedEmails ?? const [];
    if (emails.isEmpty) return;

    if (emails.length > 1) {
      context.push('/lecturer/assignments/${assignment.id}/submissions');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('select_student_to_call'))),
      );
      return;
    }

    final user = context.read<AuthNotifier>().user;
    if (user == null) return;

    try {
      setState(() => _openingAssignmentId = assignment.id);
      await context.read<MeetingService>().joinOrCreateDirect(
        peerEmail: emails.first,
        user: user,
        groupId: assignment.id,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('call_unavailable_short'))),
      );
    } finally {
      if (mounted) {
        setState(() => _openingAssignmentId = null);
      }
    }
  }

  Widget _emptyState({required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
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
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailLogPanel extends StatelessWidget {
  final List<EmailLogEntry> entries;

  const _EmailLogPanel({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Text(
            context.tr('email_delivery_log'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (entries.isEmpty)
            Text(
              context.tr('no_email_logs'),
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          for (final e in entries.take(4))
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        e.status == EmailLogStatus.sent
                            ? Icons.check_circle
                            : Icons.error,
                        color: e.status == EmailLogStatus.sent
                            ? AppTheme.success
                            : AppTheme.danger,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${e.recipient} • ${e.subject}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        _shortTime(e.timestamp),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (e.message != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 24, bottom: 6),
                    child: Text(
                      e.message!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  String _shortTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
