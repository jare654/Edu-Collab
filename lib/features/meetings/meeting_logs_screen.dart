import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../core/localization/app_strings.dart';
import 'meeting_logs_repository.dart';

class MeetingLogsScreen extends StatelessWidget {
  const MeetingLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MeetingLogsRepository>();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AppTopBar(
            title: context.tr('meeting_logs'),
            showMenu: false,
            trailing: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.close, color: AppTheme.textSecondary),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.surfaceHigh,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('attendance_dashboard'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('attendance_dashboard_subtitle'),
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: StreamBuilder<List<MeetingLogEntry>>(
              stream: repo.watchSessions(),
              builder: (context, snapshot) {
                final items = snapshot.data;
                if (items == null &&
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _infoBanner(context.tr('meeting_logs_unavailable'));
                }
                final safeItems = items ?? const <MeetingLogEntry>[];
                if (safeItems.isEmpty) {
                  return _emptyState(context);
                }

                final totalSessions = safeItems.length;
                final totalAttendees = safeItems.fold<int>(
                  0,
                  (sum, e) => sum + e.attendeeCount,
                );
                final avgDuration = _avgDuration(safeItems);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _metricRow(
                      context,
                      context.tr('total_sessions'),
                      '$totalSessions',
                    ),
                    const SizedBox(height: 8),
                    _metricRow(
                      context,
                      context.tr('total_attendees'),
                      '$totalAttendees',
                    ),
                    const SizedBox(height: 8),
                    _metricRow(
                      context,
                      context.tr('avg_session_duration'),
                      _formatDuration(avgDuration),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('export_csv_hint'),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _exportCsv(context, safeItems),
                        icon: const Icon(Icons.download),
                        label: Text(context.tr('export_csv')),
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final item in safeItems) _sessionCard(context, item),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Duration _avgDuration(List<MeetingLogEntry> items) {
    if (items.isEmpty) return Duration.zero;
    final total = items.fold<Duration>(
      Duration.zero,
      (sum, e) => sum + e.averageDuration,
    );
    return Duration(seconds: total.inSeconds ~/ items.length);
  }

  Widget _metricRow(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.2)),
        boxShadow: AppElevations.soft,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sessionCard(BuildContext context, MeetingLogEntry entry) {
    final isLive = entry.session.endTime == null;
    return InkWell(
      onTap: () => _showSessionDetails(context, entry),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppTheme.outline.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.tr(
                      'group_id_label',
                      params: {'id': entry.session.groupId},
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      context.tr('live_badge'),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              context.tr(
                'meeting_room_label',
                params: {'room': entry.session.roomName},
              ),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _chip(
                  context,
                  context.tr(
                    'attendees_count',
                    params: {'count': entry.attendeeCount.toString()},
                  ),
                ),
                const SizedBox(width: 8),
                _chip(
                  context,
                  context.tr(
                    'avg_duration_label',
                    params: {'value': _formatDuration(entry.averageDuration)},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(
                'session_started_at',
                params: {'time': _formatDate(entry.session.startTime)},
              ),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionDetails(BuildContext context, MeetingLogEntry entry) {
    final sessionDuration = (entry.session.endTime ?? DateTime.now())
        .difference(entry.session.startTime);
    final metrics = _buildParticipantMetrics(context, entry, sessionDuration);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surfaceLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('session_details'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr(
                    'meeting_room_label',
                    params: {'room': entry.session.roomName},
                  ),
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                _metricRow(
                  context,
                  context.tr('session_duration'),
                  _formatDuration(sessionDuration),
                ),
                const SizedBox(height: 8),
                _metricRow(
                  context,
                  context.tr('total_attendees'),
                  '${entry.attendeeCount}',
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr('attendance_log'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                for (final row in metrics)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppTheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            row.label,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          row.durationLabel,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          row.scoreLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<_ParticipantMetric> _buildParticipantMetrics(
    BuildContext context,
    MeetingLogEntry entry,
    Duration sessionDuration,
  ) {
    return entry.attendance.map((att) {
      final end = att.leaveTime ?? DateTime.now();
      final duration = end.difference(att.joinTime);
      final score = sessionDuration.inSeconds == 0
          ? 0
          : (duration.inSeconds / sessionDuration.inSeconds * 100).round();
      final display = (att.userName?.isNotEmpty ?? false)
          ? att.userName!
          : (att.userEmail?.isNotEmpty ?? false)
          ? att.userEmail!
          : att.userId.substring(0, att.userId.length.clamp(0, 8));
      final label = '$display • ${att.role ?? context.tr('member')}';
      return _ParticipantMetric(
        label: label,
        durationLabel: _formatDuration(duration),
        scoreLabel: context.tr(
          'participation_score',
          params: {'value': '$score'},
        ),
      );
    }).toList();
  }

  Widget _chip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _infoBanner(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(text, style: const TextStyle(color: AppTheme.danger)),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.35)),
      ),
      child: Text(
        context.tr('no_meeting_logs'),
        style: const TextStyle(color: AppTheme.textSecondary),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes == 0) return '<1m';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _exportCsv(BuildContext context, List<MeetingLogEntry> items) {
    final buffer = StringBuffer();
    buffer.writeln(
      'session_id,group_id,room_name,start_time,end_time,user_name,user_email,role,join_time,leave_time,participation',
    );
    for (final entry in items) {
      final session = entry.session;
      for (final att in entry.attendance) {
        final name = att.userName ?? '';
        final email = att.userEmail ?? '';
        final end = att.leaveTime ?? DateTime.now();
        final duration = end.difference(att.joinTime);
        final sessionDuration = (session.endTime ?? DateTime.now()).difference(
          session.startTime,
        );
        final score = sessionDuration.inSeconds == 0
            ? 0
            : (duration.inSeconds / sessionDuration.inSeconds * 100).round();
        buffer.writeln(
          '${session.id},${session.groupId},${session.roomName},${session.startTime.toIso8601String()},'
          '${session.endTime?.toIso8601String() ?? ''},"$name","$email",${att.role ?? ''},'
          '${att.joinTime.toIso8601String()},${att.leaveTime?.toIso8601String() ?? ''},$score',
        );
      }
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surfaceLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('export_csv'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('copy_csv_hint'),
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppTheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      buffer.toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ParticipantMetric {
  final String label;
  final String durationLabel;
  final String scoreLabel;

  const _ParticipantMetric({
    required this.label,
    required this.durationLabel,
    required this.scoreLabel,
  });
}
