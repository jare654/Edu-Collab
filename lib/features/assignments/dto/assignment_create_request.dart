class AssignmentCreateRequest {
  final String title;
  final String courseId;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final String? attachmentUrl;
  final List<String>? assignedEmails;
  final bool? isGroup;

  const AssignmentCreateRequest({
    required this.title,
    required this.courseId,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.attachmentUrl,
    this.assignedEmails,
    this.isGroup,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
        'title': title,
        'course_id': courseId,
        'description': description,
        'due_date': dueDate.toIso8601String(),
        'is_completed': isCompleted,
        'attachment_url': attachmentUrl,
      };
    if (assignedEmails != null) {
      data['assigned_emails'] = assignedEmails;
    }
    if (isGroup != null) {
      data['is_group'] = isGroup;
    }
    return data;
  }
}
