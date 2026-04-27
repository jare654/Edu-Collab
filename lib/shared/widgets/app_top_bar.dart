import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/models/user.dart';
import '../../features/notifications/notifications_notifier.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';
import '../../features/auth/auth_notifier.dart';

class AppTopBar extends StatelessWidget {
  final String title;
  final bool showMenu;
  final bool showSearch;
  final bool showAvatar;
  final VoidCallback? onMenu;
  final VoidCallback? onSearch;
  final Widget? trailing;

  const AppTopBar({
    super.key,
    required this.title,
    this.showMenu = true,
    this.showSearch = false,
    this.showAvatar = true,
    this.onMenu,
    this.onSearch,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier?>();
    final user = auth?.user;
    final notifications = context.watch<NotificationsNotifier?>();
    final unreadCount = notifications?.items.length ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLow.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.outline.withValues(alpha: 0.25)),
          boxShadow: AppElevations.soft,
        ),
        child: Row(
          children: [
            if (showMenu)
              IconButton(
                onPressed: onMenu,
                icon: const Icon(Icons.menu_rounded, color: AppTheme.primary),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.surfaceHigh,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            if (!showMenu) const SizedBox(width: 4),
            const SizedBox(width: 10),
            _TopBrand(title: title),
            const Spacer(),
            if (showSearch)
              IconButton(
                onPressed: onSearch,
                icon: const Icon(Icons.search, color: AppTheme.textSecondary),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.surfaceHigh,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            const SizedBox(width: 8),
            _TopActionButton(
              icon: Icons.notifications_none_rounded,
              badgeCount: unreadCount,
              onTap: user?.role == Role.student
                  ? () => context.push('/student/notifications')
                  : null,
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            if (showAvatar) ...[
              const SizedBox(width: 8),
              _TopAvatar(avatarUrl: user?.avatar),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopBrand extends StatelessWidget {
  final String title;

  const _TopBrand({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                AppTheme.surfaceHigh,
                AppTheme.primary.withValues(alpha: 0.18),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.32)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/academic_collab.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.auto_awesome_mosaic,
                color: AppTheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Academic Collab',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TopAvatar extends StatelessWidget {
  final String? avatarUrl;

  const _TopAvatar({this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final child = avatarUrl != null && avatarUrl!.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              avatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.person,
                color: AppTheme.primary,
              ),
            ),
          )
        : const Icon(Icons.person, color: AppTheme.primary);
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: AppTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.16),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TopActionButton extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final VoidCallback? onTap;

  const _TopActionButton({
    required this.icon,
    this.badgeCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: AppTheme.textSecondary),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.surfaceHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppTheme.surface, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.24),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                badgeCount > 9 ? '9+' : '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
