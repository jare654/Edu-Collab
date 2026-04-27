enum AssignmentStatus { upcoming, completed, submitted }

class Assignment {
  final String id;
  final String title;
  final String course;
  final DateTime dueDate;
  final AssignmentStatus status;
  final bool isGroup;
  final List<String> assignedEmails;
  final String? description;
  final String? attachmentUrl;

  const Assignment({
    required this.id,
    required this.title,
    required this.course,
    required this.dueDate,
    required this.status,
    this.isGroup = false,
    this.assignedEmails = const [],
    this.description,
    this.attachmentUrl,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    final dueRaw = json['dueDate'] ?? json['due_date'];
    final courseRaw = json['course'] ?? json['course_id'];
    final isCompleted = json['is_completed'] == true;
    final status = switch ((json['status'] ?? '').toString()) {
      'completed' => AssignmentStatus.completed,
      'submitted' => AssignmentStatus.submitted,
      _ => isCompleted ? AssignmentStatus.completed : AssignmentStatus.upcoming,
    };
    final isGroup =
        json['is_group'] == true || json['isGroup'] == true || json['group'] == true;
    final assignedRaw = json['assigned_emails'];
    final assignedEmails = assignedRaw is List
        ? assignedRaw
            .map((e) => e.toString().trim().toLowerCase())
            .where((e) => e.isNotEmpty)
            .toList()
        : const <String>[];
    return Assignment(
      id: json['id'].toString(),
      title: json['title'].toString(),
      course: courseRaw?.toString() ?? '',
      dueDate: DateTime.parse(dueRaw?.toString() ?? DateTime.now().toIso8601String()),
      status: status,
      isGroup: isGroup,
      assignedEmails: assignedEmails,
      description: json['description']?.toString(),
      attachmentUrl: json['attachment_url']?.toString() ?? json['attachmentUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'course_id': course,
        'due_date': dueDate.toIso8601String(),
        'status': status.name,
        'is_group': isGroup,
        'assigned_emails': assignedEmails,
        'description': description,
        'attachment_url': attachmentUrl,
      };
}
