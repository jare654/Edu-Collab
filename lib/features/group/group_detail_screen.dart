import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/group.dart';
import '../../core/models/group_member.dart';
import '../auth/auth_notifier.dart';
import 'group_notifier.dart';
import 'group_repository_impl.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  bool _loading = false;
  String? _error;
  List<GroupMember> _members = const [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = context.read<GroupRepositoryImpl>();
      final items = await repo.fetchGroupMembers(widget.groupId);
      if (!mounted) return;
      setState(() => _members = items);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = context.tr('unable_load_group_members'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = context.watch<GroupNotifier>().items.firstWhere(
      (g) => g.id == widget.groupId,
      orElse: () => Group(id: widget.groupId, name: context.tr('groups'), courseCode: '', members: 0),
    );
    final role = context.read<AuthNotifier>().role;

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
                    context.tr('group_details'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: _loadMembers,
                  icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
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
                  group.courseCode.isNotEmpty ? group.courseCode : context.tr('project_abay_semester'),
                  style: const TextStyle(
                    color: AppTheme.tertiary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  group.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('group_detail_subtitle'),
                  style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _avatar('E'),
                    _avatar('M'),
                    _avatar('S'),
                    _avatar('+${_members.isEmpty ? group.members : _members.length}'),
                    const SizedBox(width: 8),
                    Text(
                      context.tr(
                        'active_collaborators',
                        params: {'count': (_members.isEmpty ? group.members : _members.length).toString()},
                      ),
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: AppTheme.danger)),
                  ),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLow,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppTheme.outline.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('group_members'),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 12),
                      if (_members.isEmpty)
                        Text(context.tr('no_group_members'),
                            style: const TextStyle(color: AppTheme.textSecondary)),
                      if (_members.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _members
                              .map((m) => Chip(
                                    label: Text(m.email),
                                    backgroundColor: AppTheme.surface,
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final route = role?.name == 'lecturer'
                          ? '/lecturer/chat/group/${widget.groupId}'
                          : '/student/chat/group/${widget.groupId}';
                      context.push(route);
                    },
                    icon: const Icon(Icons.chat),
                    label: Text(context.tr('open_group')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: AppTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppTheme.background, width: 2),
      ),
      child: Center(
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
      ),
    );
  }
}
