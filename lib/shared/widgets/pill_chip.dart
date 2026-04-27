import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PillChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? background;
  final Color? foreground;

  const PillChip({
    super.key,
    required this.label,
    this.icon,
    this.background,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final bg = background ?? AppTheme.surfaceLow;
    final fg = foreground ?? AppTheme.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
          ),
        ],
      ),
    );
  }
}
