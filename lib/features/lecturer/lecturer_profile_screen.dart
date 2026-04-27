import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../auth/auth_notifier.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/user.dart';

class LecturerProfileScreen extends StatefulWidget {
  const LecturerProfileScreen({super.key});

  @override
  State<LecturerProfileScreen> createState() => _LecturerProfileScreenState();
}

class _LecturerProfileScreenState extends State<LecturerProfileScreen> {
  int _selectedCourse = 0;

  final List<_CourseInfo> _courses = const [
    _CourseInfo(name: 'ARCH-101 • Addis Heritage Studio', groups: 3, students: 68),
    _CourseInfo(name: 'URB-210 • Urban Morphology', groups: 2, students: 42),
    _CourseInfo(name: 'HIS-320 • Heritage Conservation', groups: 4, students: 76),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthNotifier>();
    final user = context.watch<AuthNotifier>().user;
    final displayName = user?.name ?? 'Lecturer';
    final displayEmail = user?.email ?? 'lecturer@school.edu';
    final activeCourse = _courses[_selectedCourse];
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          AppTopBar(title: context.tr('profile')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('faculty_profile'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(context.tr('manage_teaching_preferences'),
                    style: const TextStyle(color: AppTheme.textSecondary)),
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
                    border: Border.all(color: AppTheme.outline.withValues(alpha: 0.2)),
                    boxShadow: AppElevations.soft,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => _pickAvatar(context),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        child: Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppTheme.outline.withValues(alpha: 0.35)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _buildAvatar(user),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.tr('senior_faculty'),
                                style: const TextStyle(color: AppTheme.tertiary, fontWeight: FontWeight.w700, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(displayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                            const SizedBox(height: 4),
                            Text(displayEmail, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _courseManagementCard(activeCourse),
                const SizedBox(height: 12),
                _settingsCard(context.tr('grading_preferences'), Icons.fact_check,
                    [context.tr('rubrics'), context.tr('feedback_templates')]),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: () => auth.logout(), child: Text(context.tr('logout'))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _courseManagementCard(_CourseInfo activeCourse) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(context.tr('course_management'), style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          Text(context.tr('active_courses_label'),
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Column(
            children: [
              for (int i = 0; i < _courses.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedCourse = i),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: i == _selectedCourse ? AppTheme.surface : AppTheme.surfaceLow,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: i == _selectedCourse
                              ? AppTheme.primary.withValues(alpha: 0.3)
                              : AppTheme.outline.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _courses[i].name,
                              style: TextStyle(
                                fontWeight: i == _selectedCourse ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 16, color: AppTheme.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppTheme.outline.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                _statPill(context.tr('groups_assigned'), '${activeCourse.groups}'),
                const SizedBox(width: 8),
                _statPill(context.tr('students'), '${activeCourse.students}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLow,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppTheme.outline.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary)),
          ],
        ),
      ),
    );
  }

  Widget _settingsCard(String title, IconData icon, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.35)),
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
          const SizedBox(height: 8),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item, style: const TextStyle(color: AppTheme.textSecondary)),
                  const Icon(Icons.chevron_right, size: 16, color: AppTheme.textSecondary),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickAvatar(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    final ext = (file.extension ?? 'png').toLowerCase();
    final dataUrl = 'data:image/$ext;base64,${base64Encode(file.bytes!)}';
    try {
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
      return const Icon(Icons.person, color: AppTheme.primary);
    }
    if (avatar.startsWith('data:image')) {
      final payload = avatar.split(',').last;
      try {
        final bytes = base64Decode(payload);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        return const Icon(Icons.person, color: AppTheme.primary);
      }
    }
    if (avatar.startsWith('http')) {
      return Image.network(
        avatar,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.person, color: AppTheme.primary),
      );
    }
    return const Icon(Icons.person, color: AppTheme.primary);
  }
}

class _CourseInfo {
  final String name;
  final int groups;
  final int students;

  const _CourseInfo({required this.name, required this.groups, required this.students});
}
