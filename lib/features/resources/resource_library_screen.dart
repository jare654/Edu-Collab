import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../core/models/resource.dart';
import '../../core/network/connectivity_service.dart';
import 'resources_notifier.dart';
import '../../core/localization/app_strings.dart';

class ResourceLibraryScreen extends StatefulWidget {
  const ResourceLibraryScreen({super.key});

  @override
  State<ResourceLibraryScreen> createState() => _ResourceLibraryScreenState();
}

class _ResourceLibraryScreenState extends State<ResourceLibraryScreen> {
  final _search = TextEditingController();
  int _filter = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ResourcesNotifier>();
    final items = notifier.items;
    final online = context.watch<ConnectivityService>().isOnline;
    final filtered = _filter == 0
        ? items
        : _filter == 1
            ? items.where((r) => r.type.toLowerCase() == 'pdf').toList()
            : items.where((r) => r.availableOffline).toList();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AppTopBar(title: context.tr('resources'), showSearch: false),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('resource_library'),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('resource_library_subtitle'),
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: context.tr('search_resources'),
                filled: true,
                fillColor: AppTheme.surfaceLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _FilterTabs(
              index: _filter,
              onChanged: (value) => setState(() => _filter = value),
            ),
          ),
          const SizedBox(height: 12),
          if (!online)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(context.tr('offline_cached_resources'), style: const TextStyle(color: AppTheme.warning)),
            ),
          if (notifier.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _infoBanner(
                icon: Icons.error,
                color: AppTheme.danger,
                background: AppTheme.errorContainer,
                title: context.tr('resources_unavailable'),
                body: notifier.error!,
              ),
            ),
          if (notifier.loading) const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                for (final r in filtered) ...[
                  _resourceCard(context, r),
                  const SizedBox(height: 12),
                ],
                if (filtered.isEmpty && !notifier.loading)
                  _emptyState(
                    title: context.tr('no_resources_found'),
                    subtitle: context.tr('no_resources_subtitle'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resourceCard(BuildContext context, ResourceItem r) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(_typeIcon(r.type), color: AppTheme.primary),
              ),
              if (r.availableOffline)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 12, color: AppTheme.success),
                      const SizedBox(width: 4),
                      Text(context.tr('downloaded'),
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.success)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            r.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('course_label', params: {'course': r.course}),
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Text(context.tr('resource_size', params: {'type': r.type, 'size': _sizeLabel(r)}),
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/student/resources/${r.id}'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppTheme.outline.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  child: Text(context.tr('view_details')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/student/resources/${r.id}'),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(context.tr('open')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _sizeLabel(ResourceItem r) {
    if (r.sizeMb == null) return '14.2 MB';
    return '${r.sizeMb!.toStringAsFixed(1)} MB';
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.menu_book;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'zip':
        return Icons.archive;
      default:
        return Icons.video_library;
    }
  }

  Widget _emptyState({required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
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

class _FilterTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _FilterTabs({required this.index, required this.onChanged});

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
          _tab(context.tr('all'), 0),
          _tab('PDF', 1),
          _tab(context.tr('offline'), 2),
        ],
      ),
    );
  }

  Widget _tab(String label, int value) {
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
