import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../../core/models/lecturer_assignment.dart';
import 'lecturer_assignments_notifier.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/group.dart';
import '../group/group_notifier.dart';
import '../group/group_repository_impl.dart';
import '../notifications/email_log_notifier.dart';
import '../../core/models/email_log_entry.dart';

class LecturerCreateAssignmentScreen extends StatefulWidget {
  const LecturerCreateAssignmentScreen({super.key});

  @override
  State<LecturerCreateAssignmentScreen> createState() => _LecturerCreateAssignmentScreenState();
}

class _LecturerCreateAssignmentScreenState extends State<LecturerCreateAssignmentScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController promptController = TextEditingController();
  final TextEditingController courseController = TextEditingController();
  final TextEditingController dueController = TextEditingController();
  final TextEditingController recipientsController = TextEditingController();
  bool isGroup = false;
  bool sendEmail = false;
  String? selectedGroupId;
  bool loadingGroupEmails = false;
  String? groupEmailError;
  String? emailDebugMessage;
  bool? emailDebugOk;

  @override
  void dispose() {
    titleController.dispose();
    promptController.dispose();
    courseController.dispose();
    dueController.dispose();
    recipientsController.dispose();
    super.dispose();
  }

  Future<void> _loadGroupEmails(BuildContext context, String groupId) async {
    setState(() {
      loadingGroupEmails = true;
      groupEmailError = null;
    });
    try {
      final emails = await context.read<GroupRepositoryImpl>().fetchGroupMemberEmails(groupId);
      if (emails.isEmpty) {
        setState(() {
          groupEmailError = context.tr('no_group_emails_found');
        });
      } else {
        recipientsController.text = emails.join(', ');
      }
    } catch (_) {
      setState(() {
        groupEmailError = context.tr('unable_load_group_emails');
      });
    } finally {
      if (mounted) {
        setState(() => loadingGroupEmails = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<GroupNotifier>().items;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceLow,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr('create_assignment'),
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
                  context.tr('assignments_new'),
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('curate_assignment'),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('curate_assignment_subtitle'),
                  style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
                ),
                if (emailDebugMessage != null) ...[
                  const SizedBox(height: 10),
                  _EmailDebugBanner(
                    ok: emailDebugOk ?? false,
                    message: emailDebugMessage!,
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _LabeledField(
                  label: context.tr('assignment_title'),
                  hint: context.tr('assignment_title_hint'),
                  controller: titleController,
                ),
                const SizedBox(height: 12),
                _LabeledField(
                  label: context.tr('detailed_prompt'),
                  hint: context.tr('detailed_prompt_hint'),
                  maxLines: 5,
                  controller: promptController,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _LabeledField(
                        label: context.tr('course'),
                        hint: 'URB-210',
                        controller: courseController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LabeledField(
                        label: context.tr('due_date_field'),
                        hint: 'Apr 22, 2026',
                        controller: dueController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _LabeledField(
                  label: context.tr('assign_to_emails'),
                  hint: context.tr('assign_to_emails_hint'),
                  controller: recipientsController,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _AssignmentTypeToggle(
                  isGroup: isGroup,
                  onChanged: (value) => setState(() => isGroup = value),
                ),
                if (isGroup) ...[
                  const SizedBox(height: 8),
                  _GroupPicker(
                    groups: groups,
                    selectedId: selectedGroupId,
                    loading: loadingGroupEmails,
                    errorText: groupEmailError,
                    onChanged: (id) async {
                      setState(() {
                        selectedGroupId = id;
                        groupEmailError = null;
                      });
                      if (id == null) return;
                      await _loadGroupEmails(context, id);
                      if (!mounted) return;
                    },
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  context.tr('group_assignment_note'),
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: sendEmail,
                  onChanged: (value) => setState(() => sendEmail = value),
                  title: Text(context.tr('send_email_notification')),
                  subtitle: Text(context.tr('send_email_notification_subtitle')),
                  activeThumbColor: AppTheme.primary,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLow,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppTheme.outline.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(context.tr('attach_materials'))),
                      const Icon(Icons.upload, color: AppTheme.textSecondary),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                     Expanded(
                       child: OutlinedButton(
                         onPressed: () {
                           if (titleController.text.trim().isEmpty) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text('Please enter a title to save a draft.')),
                             );
                             return;
                           }
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Draft saved successfully.')),
                           );
                           Navigator.pop(context);
                         },
                         style: OutlinedButton.styleFrom(
                           padding: const EdgeInsets.symmetric(vertical: 12),
                           side: BorderSide(color: AppTheme.outline.withValues(alpha: 0.6)),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                         ),
                         child: Text(context.tr('save_draft')),
                       ),
                     ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty || courseController.text.trim().isEmpty) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(context.tr('fill_title_course'))),
                            );
                            return;
                          }
                          final rawRecipients = recipientsController.text.trim();
                          final assignedEmails = rawRecipients.isEmpty
                              ? <String>[]
                              : rawRecipients
                                  .split(',')
                                  .map((e) => e.trim().toLowerCase())
                                  .where((e) => e.isNotEmpty)
                                  .toSet()
                                  .toList();
                          if (assignedEmails.isEmpty) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(context.tr('add_recipient_emails'))),
                            );
                            return;
                          }
                          final notifier = context.read<LecturerAssignmentsNotifier>();
                          final assignment = LecturerAssignment(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleController.text.trim(),
                            course: courseController.text.trim(),
                            submitted: 0,
                            total: 0,
                            isGroup: isGroup,
                          );
                          final emailResult = await notifier.create(
                            assignment,
                            description: promptController.text.trim(),
                            dueDate: DateTime.tryParse(dueController.text.trim()),
                            assignedEmails: assignedEmails,
                            isGroup: isGroup,
                            sendEmail: sendEmail,
                          );
                          if (!context.mounted) return;
                          if (notifier.error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(notifier.error!)),
                            );
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.tr('assignment_created'))),
                          );
                          if (sendEmail) {
                              setState(() {
                                emailDebugOk = emailResult.ok;
                                emailDebugMessage = (emailResult.message == null || emailResult.message!.isEmpty)
                                    ? (emailResult.ok
                                    ? context.tr('email_sent_success')
                                    : context.tr('email_sent_failed'))
                                    : emailResult.message!;
                              });
                              final log = EmailLogEntry(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                type: EmailLogType.assignment,
                                recipient: assignedEmails.join(', '),
                                subject: assignment.title,
                                status: emailResult.ok ? EmailLogStatus.sent : EmailLogStatus.failed,
                                timestamp: DateTime.now(),
                                message: emailResult.message,
                              );
                              if (!context.mounted) return;
                              context.read<EmailLogNotifier>().addEntry(log);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(emailResult.ok
                                      ? context.tr('email_sent_success')
                                      : (emailResult.message?.isNotEmpty ?? false)
                                          ? emailResult.message!
                                          : context.tr('email_sent_failed')),
                                ),
                              );
                            }
                            if (!context.mounted) return;
                            Navigator.pop(context);
                        },
                        icon: const Icon(Icons.send),
                        label: Text(context.tr('publish_assignment')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final int maxLines;
  final TextEditingController? controller;

  const _LabeledField({
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _AssignmentTypeToggle extends StatelessWidget {
  final bool isGroup;
  final ValueChanged<bool> onChanged;

  const _AssignmentTypeToggle({required this.isGroup, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final selected = [!isGroup, isGroup];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('assignment_type').toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 6),
        ToggleButtons(
          isSelected: selected,
          onPressed: (index) => onChanged(index == 1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          fillColor: AppTheme.primary,
          selectedColor: Colors.white,
          color: AppTheme.textSecondary,
          borderColor: AppTheme.outline.withValues(alpha: 0.9),
          selectedBorderColor: AppTheme.primary,
          constraints: const BoxConstraints(minHeight: 44),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(context.tr('individual_assignment')),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(context.tr('group_assignment')),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmailDebugBanner extends StatelessWidget {
  final bool ok;
  final String message;

  const _EmailDebugBanner({required this.ok, required this.message});

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppTheme.success : AppTheme.danger;
    final background = ok ? AppTheme.success.withValues(alpha: 0.15) : AppTheme.errorContainer;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle : Icons.error, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupPicker extends StatelessWidget {
  final List<Group> groups;
  final String? selectedId;
  final bool loading;
  final String? errorText;
  final ValueChanged<String?> onChanged;

  const _GroupPicker({
    required this.groups,
    required this.selectedId,
    required this.loading,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('select_group'),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppTheme.outline.withValues(alpha: 0.9)),
            boxShadow: AppElevations.soft,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedId,
              isExpanded: true,
              hint: Text(context.tr('select_group')),
              items: groups
                  .map(
                    (g) => DropdownMenuItem(
                      value: g.id,
                      child: Text(context.tr('group_option', params: {'course': g.courseCode, 'name': g.name})),
                    ),
                  )
                  .toList(),
              onChanged: loading ? null : onChanged,
            ),
          ),
        ),
        if (loading)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(context.tr('loading_group_emails'),
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(errorText!, style: const TextStyle(color: AppTheme.danger, fontSize: 12)),
          ),
      ],
    );
  }
}
