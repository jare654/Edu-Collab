import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/user.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../auth/auth_notifier.dart';
import 'meeting_logs_repository.dart';
import 'meeting_models.dart';
import 'meeting_service.dart';

enum _CallStatusFilter { all, answered, missed }

enum _CallTypeFilter { all, direct, group }

class CallLogsScreen extends StatefulWidget {
  const CallLogsScreen({super.key});

  @override
  State<CallLogsScreen> createState() => _CallLogsScreenState();
}

class _CallLogsScreenState extends State<CallLogsScreen> {
  _CallStatusFilter _status = _CallStatusFilter.all;
  _CallTypeFilter _type = _CallTypeFilter.all;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MeetingLogsRepository>();
    final auth = context.watch<AuthNotifier>().user;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AppTopBar(title: context.tr('calls')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('calls_subtitle'),
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                _filterWrap(context),
                const SizedBox(height: 16),
                if (auth == null)
                  _emptyState(context, context.tr('call_logs_unavailable'))
                else
                  StreamBuilder<List<MeetingLogEntry>>(
                    stream: repo.watchSessions(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          snapshot.data == null) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return _emptyState(
                          context,
                          context.tr('call_logs_unavailable'),
                        );
                      }

                      final entries = _filterEntries(
                        _buildEntries(snapshot.data ?? const [], auth.email),
                      );
                      if (entries.isEmpty) {
                        return _emptyState(context, context.tr('no_call_logs'));
                      }

                      return Column(
                        children: [
                          for (final entry in entries)
                            _callCard(context, auth, entry),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_CallLogItem> _buildEntries(
    List<MeetingLogEntry> sessions,
    String currentEmail,
  ) {
    final normalizedCurrent = currentEmail.trim().toLowerCase();
    final items = <_CallLogItem>[];

    for (final entry in sessions) {
      final attendance = entry.attendance;
      final answered = attendance.any(
        (a) => a.userEmail?.trim().toLowerCase() == normalizedCurrent,
      );
      final directParticipants = MeetingService.parseDirectParticipantEmails(
        entry.session.groupId,
      );
      final isDirect = directParticipants.isNotEmpty;

      if (isDirect) {
        final involvesCurrent = directParticipants.contains(normalizedCurrent);
        if (!involvesCurrent && !answered) continue;

        final peerEmail = directParticipants.firstWhere(
          (email) => email != normalizedCurrent,
          orElse: () => '',
        );
        final peerAttendance = attendance.where((a) {
          return a.userEmail?.trim().toLowerCase() == peerEmail;
        }).toList();
        final peerName = peerAttendance.isNotEmpty
            ? (peerAttendance.first.userName ??
                  peerAttendance.first.userEmail ??
                  context.tr('unknown_contact'))
            : (peerEmail.isEmpty ? context.tr('unknown_contact') : peerEmail);

        items.add(
          _CallLogItem(
            session: entry.session,
            title: peerName,
            subtitle: context.tr('individual_call'),
            answered: answered,
            missed: !answered && entry.session.endTime != null,
            isDirect: true,
            isLive: entry.session.endTime == null,
          ),
        );
        continue;
      }

      if (!answered) continue;
      items.add(
        _CallLogItem(
          session: entry.session,
          title: context.tr('group_id_label', params: {'id': entry.session.groupId}),
          subtitle: context.tr('group_call'),
          answered: true,
          missed: false,
          isDirect: false,
          isLive: entry.session.endTime == null,
        ),
      );
    }

    items.sort((a, b) => b.session.startTime.compareTo(a.session.startTime));
    return items;
  }

  List<_CallLogItem> _filterEntries(List<_CallLogItem> items) {
    return items.where((item) {
      final statusOk = switch (_status) {
        _CallStatusFilter.all => true,
        _CallStatusFilter.answered => item.answered,
        _CallStatusFilter.missed => item.missed,
      };
      final typeOk = switch (_type) {
        _CallTypeFilter.all => true,
        _CallTypeFilter.direct => item.isDirect,
        _CallTypeFilter.group => !item.isDirect,
      };
      return statusOk && typeOk;
    }).toList();
  }

  Widget _filterWrap(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _filterChip(
          context,
          label: context.tr('all_calls'),
          selected: _status == _CallStatusFilter.all,
          onTap: () => setState(() => _status = _CallStatusFilter.all),
        ),
        _filterChip(
          context,
          label: context.tr('answered_calls'),
          selected: _status == _CallStatusFilter.answered,
          onTap: () => setState(() => _status = _CallStatusFilter.answered),
        ),
        _filterChip(
          context,
          label: context.tr('missed_calls'),
          selected: _status == _CallStatusFilter.missed,
          onTap: () => setState(() => _status = _CallStatusFilter.missed),
        ),
        _filterChip(
          context,
          label: context.tr('all_call_types'),
          selected: _type == _CallTypeFilter.all,
          onTap: () => setState(() => _type = _CallTypeFilter.all),
        ),
        _filterChip(
          context,
          label: context.tr('individual_call'),
          selected: _type == _CallTypeFilter.direct,
          onTap: () => setState(() => _type = _CallTypeFilter.direct),
        ),
        _filterChip(
          context,
          label: context.tr('group_call'),
          selected: _type == _CallTypeFilter.group,
          onTap: () => setState(() => _type = _CallTypeFilter.group),
        ),
      ],
    );
  }

  Widget _filterChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withValues(alpha: 0.14)
              : AppTheme.surfaceLow,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected
                ? AppTheme.primary.withValues(alpha: 0.45)
                : AppTheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppTheme.primary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _callCard(
    BuildContext context,
    User auth,
    _CallLogItem item,
  ) {
    final statusColor = item.missed ? AppTheme.danger : AppTheme.success;
    final statusLabel = item.missed
        ? context.tr('missed_call')
        : context.tr('answered_call');
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
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              item.missed ? Icons.call_missed : Icons.videocam,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  '${item.subtitle} • $statusLabel',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(item.session.startTime),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (item.isLive)
            TextButton.icon(
              onPressed: () async {
                await context.read<MeetingService>().joinActiveSession(
                  session: item.session,
                  user: auth,
                );
              },
              icon: const Icon(Icons.play_circle_outline),
              label: Text(context.tr('join_call')),
            ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.35)),
      ),
      child: Text(text, style: const TextStyle(color: AppTheme.textSecondary)),
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute';
  }
}

class _CallLogItem {
  final MeetingSession session;
  final String title;
  final String subtitle;
  final bool answered;
  final bool missed;
  final bool isDirect;
  final bool isLive;

  const _CallLogItem({
    required this.session,
    required this.title,
    required this.subtitle,
    required this.answered,
    required this.missed,
    required this.isDirect,
    required this.isLive,
  });
}
