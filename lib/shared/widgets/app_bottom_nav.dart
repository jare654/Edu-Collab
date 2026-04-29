import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../core/localization/app_strings.dart';

class AppBottomNav extends StatelessWidget {
  final int index;
  final List<NavItem> items;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.index,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : AppTheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? const Color(0xFF23314A)
                : AppTheme.outline.withValues(alpha: 0.95),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x161E3A8A),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < items.length; i++)
              _NavButton(
                item: items[i],
                active: i == index,
                onTap: () => onTap(i),
              ),
          ],
        ),
      ),
    );
  }
}

class AppSideNav extends StatelessWidget {
  final int index;
  final List<NavItem> items;
  final ValueChanged<int> onTap;
  final String title;
  final String? brandAssetPath;

  const AppSideNav({
    super.key,
    required this.index,
    required this.items,
    required this.onTap,
    required this.title,
    this.brandAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 104,
      margin: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : AppTheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? const Color(0xFF23314A)
              : AppTheme.outline.withValues(alpha: 0.95),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x121E3A8A),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          _BrandBadge(assetPath: brandAssetPath),
          const SizedBox(height: 16),
          Text(
            title.replaceAll('\n', ' '),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SideNavButton(
                        item: items[i],
                        active: i == index,
                        onTap: () => onTap(i),
                      ),
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

class _BrandBadge extends StatelessWidget {
  final String? assetPath;

  const _BrandBadge({this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x262563EB),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Colors.white),
          child: assetPath == null
              ? const Icon(Icons.auto_awesome_mosaic, color: AppTheme.primary)
              : Image.asset(
                  assetPath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.auto_awesome_mosaic,
                    color: AppTheme.primary,
                  ),
                ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final int badgeCount;

  const NavItem(this.icon, this.label, {this.badgeCount = 0});

  NavItem copyWith({IconData? icon, String? label, int? badgeCount}) {
    return NavItem(
      icon ?? this.icon,
      label ?? this.label,
      badgeCount: badgeCount ?? this.badgeCount,
    );
  }
}

class _NavButton extends StatelessWidget {
  final NavItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = active ? Colors.white : AppTheme.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x262563EB),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NavIcon(item: item, color: iconColor, size: 24),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? Colors.white : AppTheme.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideNavButton extends StatelessWidget {
  final NavItem item;
  final bool active;
  final VoidCallback onTap;

  const _SideNavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : AppTheme.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: active
              ? Border.all(color: AppTheme.primary.withValues(alpha: 0.95))
              : null,
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x1E2563EB),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            _NavIcon(item: item, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final NavItem item;
  final Color color;
  final double size;

  const _NavIcon({required this.item, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(item.icon, color: color, size: size),
        if (item.badgeCount > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.all(Radius.circular(999)),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  item.badgeCount > 99 ? '99+' : '${item.badgeCount}',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class StudentNavItems {
  static List<NavItem> items = const [];
  static List<NavItem> localized(BuildContext context) => [
    NavItem(Icons.home, context.tr('home')),
    NavItem(Icons.assignment, context.tr('assignments')),
    NavItem(Icons.groups, context.tr('groups')),
    NavItem(Icons.chat_bubble_outline, context.tr('chat')),
    NavItem(Icons.call_outlined, context.tr('calls')),
    NavItem(Icons.person, context.tr('profile')),
  ];
}

class LecturerNavItems {
  static List<NavItem> localized(BuildContext context) => [
    NavItem(Icons.dashboard, context.tr('dashboard')),
    NavItem(Icons.assignment, context.tr('assignments')),
    NavItem(Icons.groups, context.tr('groups')),
    NavItem(Icons.chat_bubble_outline, context.tr('chat')),
    NavItem(Icons.call_outlined, context.tr('calls')),
    NavItem(Icons.bar_chart, context.tr('analytics')),
    NavItem(Icons.person, context.tr('profile')),
  ];
}
