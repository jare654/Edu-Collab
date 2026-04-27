import 'package:flutter/material.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/theme/app_theme.dart';
import '../../core/localization/app_strings.dart';

class EmptyErrorStateScreen extends StatelessWidget {
  const EmptyErrorStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AppTopBar(title: context.tr('academic_atelier')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('nothing_here_yet'),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  context.tr('no_records_found'),
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.outline.withValues(alpha: 0.35)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.inbox, size: 48, color: AppTheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('no_data_available'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('content_will_appear'),
                    style: const TextStyle(color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    label: context.tr('refresh'),
                    icon: Icons.refresh,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Refreshing content...')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
