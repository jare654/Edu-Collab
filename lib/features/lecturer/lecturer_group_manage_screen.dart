import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/group.dart';
import '../../core/models/group_member.dart';
import '../../core/models/email_log_entry.dart';
import '../group/group_notifier.dart';
import '../group/group_repository_impl.dart';
import '../notifications/email_log_notifier.dart';
import '../auth/auth_notifier.dart';
import '../meetings/meeting_service.dart';
import '../../core/feature_flags.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

class LecturerGroupManageScreen extends StatefulWidget {
  const LecturerGroupManageScreen({super.key});

  @override
  State<LecturerGroupManageScreen> createState() =>
      _LecturerGroupManageScreenState();
}

class _LecturerGroupManageScreenState extends State<LecturerGroupManageScreen> {
  String? _selectedGroupId;
  List<GroupMember> _members = const [];
  bool _loadingMembers = false;
  String? _memberError;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _startingCall = false;

  @override
  void dispose() {
    _emailController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _startGroupCall(BuildContext context) async {
    if (!FeatureFlags.enableVideoCalls) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video calls are disabled by admin.')),
      );
      return;
    }
    final groupId = _selectedGroupId;
    final user = context.read<AuthNotifier>().user;
    if (groupId == null || user == null) return;
    setState(() => _startingCall = true);
    try {
      await context.read<MeetingService>().joinOrCreate(
        groupId: groupId,
        user: user,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('call_unavailable_short'))),
      );
    } finally {
      if (mounted) {
        setState(() => _startingCall = false);
      }
    }
  }

  Future<void> _startDirectCall(
    BuildContext context,
    GroupMember member,
  ) async {
    if (!FeatureFlags.enableVideoCalls) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video calls are disabled by admin.')),
      );
      return;
    }
    final user = context.read<AuthNotifier>().user;
    if (user == null) return;
    setState(() => _startingCall = true);
    try {
      await context.read<MeetingService>().joinOrCreateDirect(
        peerEmail: member.email,
        user: user,
        groupId: _selectedGroupId,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('call_unavailable_short'))),
      );
    } finally {
      if (mounted) {
        setState(() => _startingCall = false);
      }
    }
  }

  Future<void> _loadMembers(BuildContext context, String groupId) async {
    setState(() {
      _loadingMembers = true;
      _memberError = null;
    });
    try {
      final members = await context
          .read<GroupRepositoryImpl>()
          .fetchGroupMembers(groupId);
      if (!context.mounted) return;
      setState(() => _members = members);
    } catch (_) {
      if (!context.mounted) return;
      setState(() => _memberError = context.tr('unable_load_group_members'));
    } finally {
      if (mounted) {
        setState(() => _loadingMembers = false);
      }
    }
  }

  Future<void> _addMember(BuildContext context) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('enter_member_email'))));
      return;
    }
    final groupId = _selectedGroupId;
    if (groupId == null) return;
    setState(() {
      _memberError = null;
    });
    try {
      final repo = context.read<GroupRepositoryImpl>();
      final logNotifier = context.read<EmailLogNotifier>();
      final inviteSubject = context.tr('group_invite_subject');
      final memberAddedMsg = context.tr('member_added_email_sent');
      final memberAddedFailMsg = context.tr('member_added_email_failed');

      final result = await repo.addGroupMember(groupId, email, sendEmail: true);
      if (!context.mounted) return;

      setState(() {
        _members = [result.member, ..._members];
        _emailController.clear();
      });

      logNotifier.addEntry(
        EmailLogEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: EmailLogType.groupInvite,
          recipient: email,
          subject: inviteSubject,
          status: result.emailSent
              ? EmailLogStatus.sent
              : EmailLogStatus.failed,
          timestamp: DateTime.now(),
          message: result.message,
        ),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.emailSent ? memberAddedMsg : memberAddedFailMsg),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('member_add_failed'))));
    }
  }

  Future<void> _removeMember(BuildContext context, GroupMember member) async {
    try {
      await context.read<GroupRepositoryImpl>().removeGroupMember(member.id);
      if (!context.mounted) return;
      setState(
        () => _members = _members.where((m) => m.id != member.id).toList(),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('member_remove_failed'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<GroupNotifier>().items;
    final logs = context.watch<EmailLogNotifier>().entries;
    final selected = _selectedGroupId == null && groups.isNotEmpty
        ? groups.first.id
        : _selectedGroupId;
    if (selected != _selectedGroupId && groups.isNotEmpty) {
      _selectedGroupId = selected;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (selected != null) {
          _loadMembers(context, selected);
        }
      });
    }
    final query = _searchController.text.trim().toLowerCase();
    final filteredMembers = query.isEmpty
        ? _members
        : _members.where((m) => m.email.toLowerCase().contains(query)).toList();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AppTopBar(title: context.tr('group_management')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('group_management'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('group_management_subtitle'),
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _GroupSelector(
              groups: groups,
              selectedId: selected,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedGroupId = value);
                _loadMembers(context, value);
              },
            ),
          ),
          if (FeatureFlags.enableVideoCalls)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startingCall
                      ? null
                      : () => _startGroupCall(context),
                  icon: const Icon(Icons.video_call),
                  label: Text(
                    _startingCall
                        ? context.tr('starting_call')
                        : context.tr('start_group_call'),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _MemberComposer(
              controller: _emailController,
              onAdd: () => _addMember(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: _MemberActions(
              searchController: _searchController,
              onImport: () => _importCsv(context),
              onClear: () => setState(() => _searchController.clear()),
              onSearch: (_) => setState(() {}),
            ),
          ),
          if (_loadingMembers)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_memberError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                _memberError!,
                style: const TextStyle(color: AppTheme.danger),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                for (final member in filteredMembers)
                  _MemberCard(
                    member: member,
                    onRemove: () => _removeMember(context, member),
                    onCall: FeatureFlags.enableVideoCalls
                        ? () => _startDirectCall(context, member)
                        : null,
                  ),
                if (filteredMembers.isEmpty && !_loadingMembers)
                  _emptyState(
                    context.tr('no_group_members'),
                    context.tr('no_group_members_subtitle'),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: _EmailLogPanel(entries: logs),
          ),
        ],
      ),
    );
  }

  Future<void> _importCsv(BuildContext context) async {
    final groupId = _selectedGroupId;
    if (groupId == null) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    if (!context.mounted) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;
    final content = utf8.decode(bytes);
    final lines = content.split(RegExp(r'\r?\n'));
    final emails = <String>{};
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final parts = line.split(RegExp(r'[;,]'));
      for (final part in parts) {
        final candidate = part.trim();
        if (candidate.isEmpty) continue;
        if (candidate.toLowerCase() == 'email') continue;
        if (candidate.contains('@')) {
          emails.add(candidate);
        }
      }
    }
    if (emails.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('no_emails_found_csv'))),
      );
      return;
    }
    final repo = context.read<GroupRepositoryImpl>();
    final logNotifier = context.read<EmailLogNotifier>();
    final inviteSubject = context.tr('group_invite_subject');

    int success = 0;
    int failed = 0;
    for (final email in emails) {
      try {
        final result = await repo.addGroupMember(
          groupId,
          email,
          sendEmail: true,
        );
        if (!context.mounted) return;
        _members = [result.member, ..._members];
        logNotifier.addEntry(
          EmailLogEntry(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: EmailLogType.groupInvite,
            recipient: email,
            subject: inviteSubject,
            status: result.emailSent
                ? EmailLogStatus.sent
                : EmailLogStatus.failed,
            timestamp: DateTime.now(),
            message: result.message,
          ),
        );
        success += 1;
      } catch (_) {
        failed += 1;
      }
    }
    if (!context.mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr(
            'csv_import_result',
            params: {
              'success': success.toString(),
              'failed': failed.toString(),
            },
          ),
        ),
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

class _GroupSelector extends StatelessWidget {
  final List<Group> groups;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const _GroupSelector({
    required this.groups,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey(selectedId),
      initialValue: selectedId,
      items: [
        for (final g in groups)
          DropdownMenuItem(
            value: g.id,
            child: Text(
              context.tr(
                'group_option',
                params: {'course': g.courseCode, 'name': g.name},
              ),
            ),
          ),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: context.tr('select_group'),
        filled: true,
        fillColor: AppTheme.surfaceLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _MemberComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;

  const _MemberComposer({required this.controller, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
            context.tr('add_member'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: context.tr('member_email_hint'),
              filled: true,
              fillColor: AppTheme.surfaceLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add),
              label: Text(context.tr('add_member')),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final GroupMember member;
  final VoidCallback onRemove;
  final VoidCallback? onCall;

  const _MemberCard({
    required this.member,
    required this.onRemove,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppTheme.surfaceHigh,
            child: Icon(Icons.person, color: AppTheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              member.email,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (onCall != null)
            IconButton(
              onPressed: onCall,
              icon: const Icon(Icons.videocam, color: AppTheme.primary),
              tooltip: context.tr('call_student'),
            ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, color: AppTheme.danger),
            tooltip: context.tr('remove_member'),
          ),
        ],
      ),
    );
  }
}

class _MemberActions extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onImport;
  final VoidCallback onClear;
  final ValueChanged<String> onSearch;

  const _MemberActions({
    required this.searchController,
    required this.onImport,
    required this.onClear,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          onChanged: onSearch,
          decoration: InputDecoration(
            hintText: context.tr('search_members'),
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onImport,
                icon: const Icon(Icons.upload_file),
                label: Text(context.tr('import_csv')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton(
                onPressed: onClear,
                child: Text(context.tr('clear_search')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmailLogPanel extends StatelessWidget {
  final List<EmailLogEntry> entries;

  const _EmailLogPanel({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          for (final e in entries.take(6))
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
