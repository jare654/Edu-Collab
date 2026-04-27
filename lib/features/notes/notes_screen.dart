import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../shared/widgets/app_top_bar.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/student/notes/create'),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: AppTheme.onPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80), // Padding for FAB
        children: [
          AppTopBar(
            title: 'Notes',
            showSearch: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Notebook',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Capture ideas, lecture summaries, and study points.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 15, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildNoteCard(
            context,
            title: 'Sustainable Architecture Concepts',
            snippet: 'Key principles: \n1. Energy efficiency \n2. Sustainable materials...',
            date: 'Today, 10:45 AM',
            color: AppTheme.primary,
          ),
          _buildNoteCard(
            context,
            title: 'Group Project Brainstorming',
            snippet: 'Ideas for the final presentation. We need to focus on...',
            date: 'Yesterday',
            color: AppTheme.tertiary,
          ),
          _buildNoteCard(
            context,
            title: 'Urban Planning Laws',
            snippet: 'Zoning codes, historical district restrictions...',
            date: 'Apr 12, 2026',
            color: AppTheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, {required String title, required String snippet, required String date, required Color color}) {
    return GestureDetector(
      onTap: () => context.push('/student/notes/view'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppTheme.outline.withValues(alpha: 0.4)),
          boxShadow: AppElevations.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              snippet,
              style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              date,
              style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
