import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/assignment.dart';
import 'student_assignments_notifier.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../core/localization/app_strings.dart';

class AssignmentDetailScreen extends StatelessWidget {
  final String assignmentId;
  const AssignmentDetailScreen({super.key, required this.assignmentId});

  void _showAssignmentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Assignment Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.contact_mail),
              title: const Text('Contact Lecturer'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact feature coming soon.')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Code'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Join code copied to clipboard.')));
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
    final assignment = notifier.items.firstWhere(
      (a) => a.id == assignmentId,
      orElse: () => Assignment(
        id: assignmentId,
        title: context.tr('assignment_details'),
        course: context.tr('course'),
        dueDate: DateTime.now(),
        status: AssignmentStatus.upcoming,
      ),
    );
    final dueSoon = assignment.dueDate.isBefore(DateTime.now().add(const Duration(days: 3)));
    final dueText = _formatDue(assignment.dueDate);
    final statusLabel = _statusLabel(context, assignment.status);
    final statusColor = assignment.status == AssignmentStatus.completed
        ? AppTheme.success
        : assignment.status == AssignmentStatus.submitted
            ? AppTheme.primary
            : AppTheme.warning;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceLow,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr('assignment_details'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: () => _showAssignmentMenu(context),
                  icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.course,
                  style: TextStyle(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  assignment.title,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (dueSoon)
                      _pill(context.tr('due_soon'), AppTheme.errorContainer, AppTheme.danger),
                    _pill(
                      assignment.isGroup ? context.tr('group_assignment') : context.tr('individual_assignment'),
                      AppTheme.surfaceLow,
                      AppTheme.textSecondary,
                    ),
                    _pill(statusLabel, AppTheme.surfaceLow, AppTheme.textSecondary),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.tertiaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event, color: AppTheme.tertiary),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('due_date_label'),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(dueText,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppElevations.soft,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('assignment_brief'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          Text(context.tr('view_rubric'), style: const TextStyle(fontSize: 12, color: AppTheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        assignment.description?.isNotEmpty == true
                            ? assignment.description!
                            : context.tr('assignment_brief_body'),
                        style: const TextStyle(color: AppTheme.textSecondary, height: 1.5),
                      ),
                    ],
                  ),
                ),
                if (assignment.attachmentUrl != null && assignment.attachmentUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _attachmentCard(
                    icon: Icons.picture_as_pdf,
                    title: _filenameFromUrl(assignment.attachmentUrl!),
                    meta: context.tr('download'),
                    onTap: () => _openUrl(context, assignment.attachmentUrl!),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLow,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppTheme.outline.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('submission_status'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(radius: 5, backgroundColor: statusColor),
                          const SizedBox(width: 10),
                          Text(statusLabel,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: AppTheme.outline),
                      const SizedBox(height: 8),
                      _statusRow(context.tr('attempts'), '0 / 3'),
                      const SizedBox(height: 8),
                      _statusRow(context.tr('grade'), context.tr('not_graded'), italic: true),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/student/assignments/$assignmentId/submit'),
                          icon: const Icon(Icons.upload_file),
                          label: Text(context.tr('submit_assignment')),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppTheme.outline.withValues(alpha: 0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('feedback_and_grade'),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(context.tr('not_graded'),
                          style: const TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _attachmentCard({
    required IconData icon,
    required String title,
    required String meta,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(meta, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.download, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  static Widget _statusRow(String label, String value, {bool italic = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w700, fontStyle: italic ? FontStyle.italic : FontStyle.normal),
        ),
      ],
    );
  }

  static Widget _pill(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: foreground),
      ),
    );
  }

  static String _formatDue(DateTime due) {
    final hour = due.hour.toString().padLeft(2, '0');
    final minute = due.minute.toString().padLeft(2, '0');
    return '${due.month}/${due.day}/${due.year} • $hour:$minute';
  }

  static String _statusLabel(BuildContext context, AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.submitted:
        return context.tr('submitted');
      case AssignmentStatus.completed:
        return context.tr('completed');
      case AssignmentStatus.upcoming:
        return context.tr('in_progress');
    }
  }

  static String _filenameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : url;
    } catch (_) {
      return url;
    }
  }

  static Future<void> _openUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('unable_open_link'))),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('unable_open_link'))),
      );
    }
  }
}
