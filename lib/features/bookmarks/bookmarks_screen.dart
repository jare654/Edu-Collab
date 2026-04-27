import 'package:flutter/material.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../core/localization/app_strings.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AppTopBar(
            title: context.tr('bookmarks'),
            showSearch: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved Content', // Can be localized later
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Quick access to your saved resources, notes, and assignments.',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildBookmarkItem(
            context,
            icon: Icons.article,
            title: 'Heritage Conservation Strategy',
            subtitle: 'Resource • PDF • 1.2MB',
            color: AppTheme.primary,
          ),
          _buildBookmarkItem(
            context,
            icon: Icons.assignment_rounded,
            title: 'Urban Design Field Study',
            subtitle: 'Assignment • Due Apr 22',
            color: AppTheme.tertiary,
          ),
          _buildBookmarkItem(
            context,
            icon: Icons.edit_note,
            title: 'Lecture 4 - Advanced Structures',
            subtitle: 'Note • Modified 2 days ago',
            color: AppTheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Removed from bookmarks')),
              );
            },
            icon: const Icon(Icons.bookmark, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }
}
