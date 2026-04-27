import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/resource.dart';
import 'resources_notifier.dart';

class ResourceDetailScreen extends StatefulWidget {
  final String resourceId;
  const ResourceDetailScreen({super.key, required this.resourceId});

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  bool _isDownloading = false;
  bool _isDownloaded = false;

  void _showResourceMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resource Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Resource'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shared successfully.')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_add),
              title: const Text('Add to Bookmarks'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to bookmarks.')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.orange),
              title: const Text('Report Issue', style: TextStyle(color: Colors.orange)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue reported.')));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDownload(ResourceItem resource) async {
    if (resource.url == null || resource.url!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('unable_open_link'))),
      );
      return;
    }
    setState(() => _isDownloading = true);
    final uri = Uri.parse(resource.url!);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    setState(() {
      _isDownloading = false;
      _isDownloaded = ok;
    });
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('unable_open_link'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ResourcesNotifier>();
    final resource = notifier.items.firstWhere(
      (r) => r.id == widget.resourceId,
      orElse: () => ResourceItem(
        id: widget.resourceId,
        title: context.tr('resource_details'),
        course: context.tr('course'),
        type: 'pdf',
        availableOffline: false,
      ),
    );
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
                    context.tr('resource_details'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: _showResourceMenu,
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
                Wrap(
                  spacing: 8,
                  children: [
                    _pill(context.tr('academic_resource'), AppTheme.secondaryContainer, AppTheme.textPrimary),
                    _pill(context.tr('core_reading'), AppTheme.tertiaryContainer, AppTheme.tertiary),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  resource.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    _MetaRow(icon: Icons.school, label: resource.course),
                    _MetaRow(
                      icon: Icons.calendar_today,
                      label: resource.year ?? context.tr('academic_year_sample'),
                    ),
                    _MetaRow(
                      icon: Icons.description,
                      label: context.tr('pages_count', params: {'count': (resource.pages ?? 0).toString()}),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLow,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            context.tr('available_offline'),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                          ),
                          const SizedBox(width: 8),
                          Icon(resource.availableOffline ? Icons.toggle_on : Icons.toggle_off,
                              color: resource.availableOffline ? AppTheme.primary : AppTheme.textSecondary),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _isDownloading ? null : () => _handleDownload(resource),
                      icon: _isDownloading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Icon(_isDownloaded ? Icons.download_done : Icons.download),
                      label: Text(_isDownloading ? 'Downloading...' : (_isDownloaded ? 'Downloaded' : context.tr('download'))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isDownloaded ? AppTheme.secondary : AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    _toolButton(Icons.edit, selected: true),
                    const SizedBox(width: 8),
                    _toolButton(Icons.highlight),
                    const SizedBox(width: 8),
                    _toolButton(Icons.sticky_note_2),
                    const SizedBox(width: 8),
                    _toolButton(Icons.draw),
                    const SizedBox(width: 8),
                    _toolButton(Icons.zoom_in),
                    const SizedBox(width: 8),
                    _toolButton(Icons.zoom_out),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLow,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: AppTheme.outline.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.chevron_left, color: AppTheme.textSecondary),
                            const SizedBox(width: 8),
                            Text(context.tr('page_of', params: {'page': '04', 'total': '42'}),
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AspectRatio(
                        aspectRatio: 1 / 1.41,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceHighest,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppTheme.outline.withValues(alpha: 0.35)),
                            boxShadow: AppElevations.soft,
                          ),
                          child: Center(
                            child: Text(
                              context.tr('pdf_viewer_placeholder'),
                              style: const TextStyle(color: AppTheme.textSecondary),
                            ),
                          ),
                        ),
                      ),
                      if (resource.url != null && resource.url!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _handleDownload(resource),
                            icon: const Icon(Icons.open_in_new),
                            label: Text(context.tr('open')),
                          ),
                        ),
                      ],
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

  Widget _pill(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  Widget _toolButton(IconData icon, {bool selected = false}) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary.withValues(alpha: 0.1) : AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.3)),
      ),
      child: Icon(icon, color: selected ? AppTheme.primary : AppTheme.textSecondary),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }
}
