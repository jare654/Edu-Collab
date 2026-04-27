import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import 'student_assignments_notifier.dart';
import '../../core/localization/app_strings.dart';

class AssignmentSubmissionScreen extends StatefulWidget {
  final String assignmentId;
  const AssignmentSubmissionScreen({super.key, required this.assignmentId});

  @override
  State<AssignmentSubmissionScreen> createState() => _AssignmentSubmissionScreenState();
}

class _AssignmentSubmissionScreenState extends State<AssignmentSubmissionScreen> {
  final TextEditingController _noteController = TextEditingController();
  final List<PlatformFile> _files = [];
  final Map<String, double> _progress = {};
  bool _uploading = false;
  String? _uploadError;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, withData: true);
    if (result == null) return;
    setState(() {
      for (final f in result.files) {
        if (!_files.any((e) => e.name == f.name)) {
          _files.add(f);
          _progress[f.name] = 0;
        }
      }
    });
  }

  Future<void> _simulateUploadProgress() async {
    for (final f in _files) {
      _progress[f.name] = 0.05;
    }
    if (mounted) setState(() {});
    for (int step = 0; step < 10; step++) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      for (final f in _files) {
        final current = _progress[f.name] ?? 0;
        _progress[f.name] = (current + 0.1).clamp(0, 1);
      }
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    context.tr('submit_assignment'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('assignment_submission'),
                  style: const TextStyle(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('case_study_addis'),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('submission_instructions'),
                  style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppElevations.soft,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('submission_files'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLow,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(context.tr('max_file_size'),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLow.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppTheme.outline.withValues(alpha: 0.4), width: 2),
                        ),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundColor: Color(0x1100488D),
                              child: Icon(Icons.cloud_upload, color: AppTheme.primary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.tr('click_to_upload'),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.tr('file_types_allowed'),
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pickFiles,
                          icon: const Icon(Icons.upload_file),
                          label: Text(context.tr('select_files')),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: AppTheme.outline.withValues(alpha: 0.6)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_files.isNotEmpty)
                        Column(
                          children: [
                            for (final f in _files)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLow,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.description, color: AppTheme.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(f.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 6),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(AppRadius.pill),
                                            child: LinearProgressIndicator(
                                              value: _progress[f.name] ?? 0,
                                              minHeight: 4,
                                              backgroundColor: AppTheme.outline.withValues(alpha: 0.2),
                                              valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => setState(() => _files.remove(f)),
                                      icon: const Icon(Icons.close, size: 18),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppElevations.soft,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('submission_notes'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _noteController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: context.tr('submission_notes_hint'),
                          filled: true,
                          fillColor: AppTheme.surfaceLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLow,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppTheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('pre_submission_checklist'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      _checkItem(context.tr('checklist_references'), checked: true),
                      const SizedBox(height: 10),
                      _checkItem(context.tr('checklist_diagrams')),
                      const SizedBox(height: 10),
                      _checkItem(context.tr('checklist_filesize')),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.errorContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: AppTheme.danger, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.tr('checklist_incomplete'),
                                style: const TextStyle(fontSize: 11, color: AppTheme.danger),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.tertiary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: const Border(left: BorderSide(color: AppTheme.tertiary, width: 3)),
                  ),
                  child: Text(
                    context.tr('quote_bibliographies'),
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.tertiary),
                  ),
                ),
                const SizedBox(height: 16),
                if (_uploadError != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: AppTheme.danger),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _uploadError!,
                            style: const TextStyle(color: AppTheme.danger),
                          ),
                        ),
                        TextButton(
                          onPressed: _uploading ? null : () => setState(() => _uploadError = null),
                          child: Text(context.tr('retry')),
                        ),
                      ],
                    ),
                  ),
                if (_uploadError != null) const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _uploading
                        ? null
                        : () async {
                            setState(() {
                              _uploading = true;
                              _uploadError = null;
                            });
                            if (_files.isNotEmpty) {
                              await _simulateUploadProgress();
                            }
                            if (!context.mounted) return;
                            final notifier = context.read<StudentAssignmentsNotifier>();
                            final failMsg = context.tr('upload_failed');
                            final successMsg = context.tr('submission_sent');
                            
                            final firstFile = _files.isNotEmpty ? _files.first : null;
                            final ok = await notifier.submit(
                              widget.assignmentId,
                              note: _noteController.text.trim(),
                              fileBytes: firstFile?.bytes,
                              filename: firstFile?.name,
                            );
                            if (!context.mounted) return;

                            if (!ok) {
                              setState(() {
                                _uploadError = failMsg;
                                _uploading = false;
                              });
                              return;
                            }
                            setState(() => _uploading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(successMsg)),
                            );
                            if (!context.mounted) return;
                            context.pop();
                          },
                    icon: const Icon(Icons.send),
                    label: Text(_uploading ? context.tr('uploading') : context.tr('submit_assignment')),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('due_time', params: {'date': 'Apr 24, 11:59 PM'}),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkItem(String text, {bool checked = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 18,
          width: 18,
          decoration: BoxDecoration(
            color: checked ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: checked ? AppTheme.primary : AppTheme.outline),
          ),
          child: checked
              ? const Icon(Icons.check, size: 14, color: AppTheme.primary)
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))),
      ],
    );
  }
}
