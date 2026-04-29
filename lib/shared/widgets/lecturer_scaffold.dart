import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_bottom_nav.dart';
import '../../features/auth/auth_notifier.dart';
import '../../features/meetings/meeting_logs_repository.dart';
import '../../features/meetings/meeting_service.dart';

class LecturerScaffold extends StatelessWidget {
  final Widget child;
  final int index;
  final ValueChanged<int> onTap;

  const LecturerScaffold({
    super.key,
    required this.child,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>().user;
    final repo = context.read<MeetingLogsRepository>();
    return StreamBuilder<List<MeetingLogEntry>>(
      stream: repo.watchSessions(),
      builder: (context, snapshot) {
        final items = LecturerNavItems.localized(context);
        final missedCount = auth == null
            ? 0
            : _countMissedCalls(snapshot.data ?? const [], auth.email);
        final navItems = List<NavItem>.from(items);
        if (navItems.length > 4) {
          navItems[4] = navItems[4].copyWith(badgeCount: missedCount);
        }
        final width = MediaQuery.of(context).size.width;
        final useRail = width >= 900;
        return Scaffold(
          body: useRail
              ? SafeArea(
                  child: Row(
                    children: [
                      AppSideNav(
                        index: index,
                        items: navItems,
                        onTap: onTap,
                        title: 'Academic\nCollab',
                        brandAssetPath:
                            'assets/images/academic_collab_mark.png',
                      ),
                      Expanded(child: child),
                    ],
                  ),
                )
              : child,
          bottomNavigationBar: useRail
              ? null
              : AppBottomNav(index: index, items: navItems, onTap: onTap),
        );
      },
    );
  }

  int _countMissedCalls(List<MeetingLogEntry> sessions, String email) {
    final normalized = email.trim().toLowerCase();
    var count = 0;
    for (final entry in sessions) {
      if (entry.session.endTime == null) continue;
      final directEmails = MeetingService.parseDirectParticipantEmails(
        entry.session.groupId,
      );
      if (!directEmails.contains(normalized)) continue;
      final answered = entry.attendance.any(
        (a) => a.userEmail?.trim().toLowerCase() == normalized,
      );
      if (!answered) count++;
    }
    return count;
  }
}
