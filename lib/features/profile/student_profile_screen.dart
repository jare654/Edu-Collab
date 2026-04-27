import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../auth/auth_notifier.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/models/user.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../core/localization/app_strings.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthNotifier>();
    final user = context.watch<AuthNotifier>().user;
    final displayName = user?.name ?? 'Student';
    final displayEmail = user?.email ?? 'student@school.edu';
    final connectivity = context.watch<ConnectivityService>();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AppTopBar(title: context.tr('profile')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryContainer,
                  child: Icon(Icons.person, color: AppTheme.primary),
                ),
                const SizedBox(width: 8),
                Text(context.tr('profile_settings'), style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: AppElevations.soft,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => _pickAvatar(context),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        child: Stack(
                          children: [
                            Container(
                              height: 96,
                              width: 96,
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(AppRadius.xl),
                                border: Border.all(color: AppTheme.outline.withValues(alpha: 0.35)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: _buildAvatar(user),
                            ),
                            Positioned(
                              bottom: -4,
                              right: -4,
                              child: Container(
                                height: 36,
                                width: 36,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, size: 16, color: AppTheme.onPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.tr('architecture_student'),
                                style: const TextStyle(color: AppTheme.tertiary, fontWeight: FontWeight.w700, fontSize: 11)),
                            const SizedBox(height: 6),
                            Text(displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            const Text(
                              'Specializing in Sustainable Urban Environments. Minor in Digital Fabrication.',
                              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: AppElevations.soft,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('semester_gpa'),
                          style: TextStyle(color: AppTheme.onPrimary.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
                      SizedBox(height: 6),
                      const Text('3.92',
                          style: TextStyle(color: AppTheme.onPrimary, fontWeight: FontWeight.w700, fontSize: 26)),
                      SizedBox(height: 12),
                      Divider(color: AppTheme.onPrimary.withValues(alpha: 0.2)),
                      SizedBox(height: 8),
                      Text(context.tr('upcoming_milestone'),
                          style: TextStyle(color: AppTheme.onPrimary.withValues(alpha: 0.7), fontSize: 11)),
                      Text(context.tr('final_thesis_proposal'),
                          style: const TextStyle(color: AppTheme.onPrimary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _settingsCard(
                  title: context.tr('account_settings'),
                  icon: Icons.manage_accounts,
                  children: [
                    _SettingsRow(
                      title: context.tr('email_address'),
                      subtitle: displayEmail,
                    ),
                    _SettingsRow(
                      title: context.tr('change_password'),
                      subtitle: context.tr('last_updated_months', params: {'count': '4'}),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _settingsCard(
                  title: context.tr('notification_preferences'),
                  icon: Icons.notifications_active,
                  children: [
                    _ToggleRow(
                      title: context.tr('course_updates'),
                      subtitle: context.tr('course_updates_subtitle'),
                      initial: true,
                    ),
                    _ToggleRow(
                      title: context.tr('atelier_announcements'),
                      subtitle: context.tr('atelier_announcements_subtitle'),
                      initial: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(context.tr('offline_mode_demo')),
                  value: !connectivity.isOnline,
                  onChanged: (v) => connectivity.setOnline(!v),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => auth.logout(),
                    child: Text(context.tr('logout')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAvatar(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null) return;
      final ext = (file.extension ?? 'png').toLowerCase();
      final dataUrl = 'data:image/$ext;base64,${base64Encode(file.bytes!)}';
      if (!context.mounted) return;
      final auth = context.read<AuthNotifier>();
      final ok = await auth.updateAvatarBytes(
        bytes: file.bytes!,
        extension: ext,
        fallbackDataUrl: dataUrl,
      );
      if (!context.mounted) return;
      if (!ok) {
        final msg = auth.avatarError ?? context.tr('upload_failed');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('upload_failed'))),
      );
    }
  }

  Widget _buildAvatar(User? user) {
    final avatar = user?.avatar;
    if (avatar == null || avatar.isEmpty) {
      return const Icon(Icons.person, size: 48, color: AppTheme.primary);
    }
    if (avatar.startsWith('data:image')) {
      final payload = avatar.split(',').last;
      try {
        final bytes = base64Decode(payload);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        return const Icon(Icons.person, size: 48, color: AppTheme.primary);
      }
    }
    if (avatar.startsWith('http')) {
      return Image.network(
        avatar,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.person, size: 48, color: AppTheme.primary),
      );
    }
    return const Icon(Icons.person, size: 48, color: AppTheme.primary);
  }
}

class _SettingsRow extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SettingsRow({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool initial;

  const _ToggleRow({required this.title, required this.subtitle, this.initial = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        Switch(value: initial, onChanged: (_) {}),
      ],
    );
  }
}

Widget _settingsCard({required String title, required IconData icon, required List<Widget> children}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      border: Border.all(color: AppTheme.outline.withValues(alpha: 0.2)),
      boxShadow: AppElevations.soft,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 12),
        for (final child in children) ...[
          child,
          const SizedBox(height: 10),
        ],
      ],
    ),
  );
}
