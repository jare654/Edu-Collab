import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/app_tokens.dart';
import '../auth/auth_notifier.dart';
import 'meet_notifier.dart';
import 'chat_repository.dart';
import '../../core/localization/app_strings.dart';
import '../meetings/meeting_service.dart';
import '../../core/feature_flags.dart';
import '../group/group_notifier.dart';
import '../../core/models/group.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  const GroupChatScreen({super.key, required this.groupId});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final String _sender;
  late final ChatRepository _repo;

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upload Attachment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Photo Gallery'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo selector simulated.')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera opening simulated.')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document selector simulated.')));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _repo = context.read<ChatRepository>();
    final auth = context.read<AuthNotifier>();
    final user = auth.user;
    _sender = user?.name ?? 'You';
    _repo.connect(widget.groupId, _sender, token: auth.accessToken);
  }

  @override
  void dispose() {
    _repo.disconnect();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ChatRepository>();
    final meet = context.watch<MeetNotifier>();
    final group = context.watch<GroupNotifier>().items.firstWhere(
          (g) => g.id == widget.groupId,
          orElse: () => Group(id: widget.groupId, name: context.tr('group_details'), courseCode: '', members: 0),
        );
    final messages = repo.messagesFor(widget.groupId);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr(
                          'chat_group_meta',
                          params: {
                            'course': group.courseCode.isEmpty ? '—' : group.courseCode,
                            'members': '${group.members}',
                            'online': repo.isConnected ? '1' : '0',
                          },
                        ),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: repo.isConnected ? AppTheme.success : AppTheme.danger,
                    shape: BoxShape.circle,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.videocam, color: meet.isNativeAvailable ? AppTheme.primary : AppTheme.textSecondary.withValues(alpha: 0.5)),
                  onPressed: meet.isNativeAvailable
                    ? () => _startMeet(context, meet)
                    : () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video calls are disabled by admin.'))),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, color: AppTheme.textSecondary),
                  onPressed: () {
                    final role = context.read<AuthNotifier>().user?.role;
                    final base = role?.name == 'lecturer' ? '/lecturer' : '/student';
                    context.push('$base/groups/${widget.groupId}');
                  },
                ),
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.surfaceHigh,
                  child: Icon(Icons.person, color: AppTheme.primary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLow,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppTheme.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.tr('schedule_meet_prompt'),
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showMeetSheet(context),
                    child: Text(context.tr('schedule')),
                  ),
                  if (FeatureFlags.enableVideoCalls)
                    TextButton(
                      onPressed: () => _startCall(context),
                      child: Text(context.tr('join_call')),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final m = messages[i];
                final isMine = m.isMine;
                return Row(
                  mainAxisAlignment: isMine
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMine)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceHigh,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 18,
                          color: AppTheme.primary,
                        ),
                      ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: isMine
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (!isMine)
                            Text(
                              m.sender,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.secondary,
                              ),
                            ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMine
                                  ? AppTheme.primary
                                  : AppTheme.surface,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              boxShadow: AppElevations.soft,
                            ),
                            child: Text(
                              m.content,
                              style: TextStyle(
                                color: isMine
                                    ? AppTheme.onPrimary
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(m.time),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  onPressed: _showAttachmentMenu,
                  icon: const Icon(
                    Icons.add_circle,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: context.tr('type_message'),
                      filled: true,
                      fillColor: AppTheme.surfaceLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppRadius.lg),
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _send(context, _sender),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 44,
                  width: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary,
                  ),
                  child: IconButton(
                    onPressed: () => _send(context, _sender),
                    icon: const Icon(Icons.send, color: AppTheme.onPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _send(BuildContext context, String sender) {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    context.read<ChatRepository>().sendMessage(widget.groupId, sender, text);
    _msgController.clear();
  }

  void _startMeet(BuildContext context, MeetNotifier meet) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting native meeting experience...')),
    );
  }

  void _showMeetSheet(BuildContext context) {
    final titleController = TextEditingController();
    final timeController = TextEditingController();
    final locationController = TextEditingController();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('setup_meet'),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: context.tr('topic')),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: timeController,
                decoration: InputDecoration(labelText: context.tr('date_time')),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: context.tr('location_link'),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.tr('cancel')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final notifier = context.read<MeetNotifier>();
                        notifier.scheduleMeet(
                          time: DateTime.now().add(const Duration(hours: 2)),
                          title: titleController.text.isEmpty
                              ? context.tr('group_meet')
                              : titleController.text,
                          location: locationController.text.isEmpty
                              ? context.tr('study_room_link')
                              : locationController.text,
                        );
                        Navigator.pop(context);
                      },
                      child: Text(context.tr('schedule')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startCall(BuildContext context) async {
    final auth = context.read<AuthNotifier>();
    final user = auth.user;
    if (user == null) return;
    await context.read<MeetingService>().joinOrCreate(
      groupId: widget.groupId,
      user: user,
    );
  }
}
