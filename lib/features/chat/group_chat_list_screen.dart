import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../core/models/group.dart';
import 'chat_repository.dart';
import '../group/group_notifier.dart';
import '../../core/localization/app_strings.dart';
import '../auth/auth_notifier.dart';
import '../../core/feature_flags.dart';

class GroupChatListScreen extends StatefulWidget {
  const GroupChatListScreen({super.key});

  @override
  State<GroupChatListScreen> createState() => _GroupChatListScreenState();
}

class _GroupChatListScreenState extends State<GroupChatListScreen> {
  String? _selectedCourse;
  final TextEditingController _serverController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _serverReady = false;
  String _searchText = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_serverReady) {
      _serverController.text = context.read<ChatRepository>().serverUrl;
      _serverReady = true;
    }
    final localizedAll = context.tr('all_courses');
    if (_selectedCourse == null || _selectedCourse == 'All Courses') {
      _selectedCourse = localizedAll;
    }
  }

  @override
  void dispose() {
    _serverController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<GroupNotifier>();
    final groups = notifier.items;
    final role = context.watch<AuthNotifier>().role;
    final baseRoute = role?.name == 'lecturer' ? '/lecturer/chat' : '/student/chat';
    final allCoursesLabel = context.tr('all_courses');
    final selectedCourse = _selectedCourse ?? allCoursesLabel;
    final courseOptions = <String>{
      allCoursesLabel,
      ...groups.map((g) => g.courseCode),
    }.toList();
    final resolvedCourse = courseOptions.contains(selectedCourse) ? selectedCourse : allCoursesLabel;
    var filtered = resolvedCourse == allCoursesLabel
        ? groups
        : groups.where((g) => g.courseCode == resolvedCourse).toList();
    if (_searchText.isNotEmpty) {
      final term = _searchText.toLowerCase();
      filtered = filtered
          .where((g) =>
              g.name.toLowerCase().contains(term) ||
              g.courseCode.toLowerCase().contains(term))
          .toList();
    }
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AppTopBar(title: context.tr('chat')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('collaboration_hub'),
                  style: const TextStyle(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('your_groups'),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          if (FeatureFlags.showChatConfig) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _serverController,
                onSubmitted: (value) => context.read<ChatRepository>().updateServerUrl(value.trim()),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.link),
                  hintText: 'ws://<laptop-ip>:8081/ws',
                  labelText: context.tr('chat_server_url'),
                  filled: true,
                  fillColor: AppTheme.surfaceLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.lg), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchText = value.trim()),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: context.tr('search_cohorts'),
                filled: true,
                fillColor: AppTheme.surfaceLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.lg), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DropdownButtonFormField<String>(
              key: ValueKey(resolvedCourse),
              initialValue: resolvedCourse,
              items: [
                for (final c in courseOptions) DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedCourse = value);
              },
              decoration: InputDecoration(
                labelText: context.tr('select_course'),
                filled: true,
                fillColor: AppTheme.surfaceLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.lg), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (notifier.loading) const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
          if (notifier.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _infoBanner(
                icon: Icons.error,
                color: AppTheme.danger,
                background: AppTheme.errorContainer,
                title: context.tr('chat_unavailable'),
                body: notifier.error!,
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                for (final g in filtered) _groupChatCard(context, g, baseRoute),
                if (filtered.isEmpty && !notifier.loading)
                  _emptyState(
                    title: context.tr('no_groups_yet'),
                    subtitle: context.tr('chat_empty_subtitle'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupChatCard(BuildContext context, Group g, String baseRoute) {
    return InkWell(
      onTap: () => context.push('$baseRoute/group/${g.id}'),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppTheme.outline.withValues(alpha: 0.2)),
          boxShadow: AppElevations.soft,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.hub, color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        g.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      Text(
                        context.tr('chat_group_subtitle', params: {'course': g.courseCode}),
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr('chat_preview_sample'),
                        style: const TextStyle(color: AppTheme.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(context.tr('minutes_ago', params: {'count': '2'}),
                        style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                    const SizedBox(height: 6),
                    Container(
                      height: 22,
                      width: 22,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: const Center(
                        child: Text('3',
                            style: TextStyle(color: AppTheme.onPrimary, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _miniAvatar('D'),
                _miniAvatar('M'),
                _miniAvatar('S'),
                _miniAvatar('+${g.members - 3}'),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => context.push('$baseRoute/group/${g.id}'),
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(context.tr('open_chat')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    side: BorderSide(color: AppTheme.outline.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniAvatar(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      height: 28,
      width: 28,
      decoration: BoxDecoration(
        color: AppTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.5), width: 2),
      ),
      child: Center(
        child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _emptyState({required String title, required String subtitle}) {
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
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(body, style: const TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
