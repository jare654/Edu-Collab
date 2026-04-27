class LecturerAssignment {
  final String id;
  final String title;
  final String course;
  final int submitted;
  final int total;
  final bool isGroup;
  final List<String>? assignedEmails;
  final DateTime? dueDate;
  final String? description;

  const LecturerAssignment({
    required this.id,
    required this.title,
    required this.course,
    required this.submitted,
    required this.total,
    required this.isGroup,
    this.assignedEmails,
    this.dueDate,
    this.description,
  });

  factory LecturerAssignment.fromJson(Map<String, dynamic> json) {
    final courseRaw = json['course'] ?? json['course_id'];
    final submittedRaw = json['submitted'] ?? json['submitted_count'] ?? json['submitted_total'];
    final totalRaw = json['total'] ?? json['total_students'] ?? json['total_count'];
    final assignedRaw = json['assigned_emails'];
    final dueRaw = json['due_date'] ?? json['dueDate'];
    final descRaw = json['description'];
    final emails = assignedRaw is List
        ? assignedRaw.map((e) => e.toString()).toList()
        : null;
    return LecturerAssignment(
      id: json['id'].toString(),
      title: json['title'].toString(),
      course: courseRaw?.toString() ?? '',
      submitted: int.tryParse(submittedRaw?.toString() ?? '') ?? 0,
      total: int.tryParse(totalRaw?.toString() ?? '') ?? 0,
      isGroup: json['isGroup'] == true || json['is_group'] == true,
      assignedEmails: emails,
      dueDate: dueRaw == null ? null : DateTime.tryParse(dueRaw.toString()),
      description: descRaw?.toString(),
    );
  }

  String get submittedLabel => '$submitted/$total submitted';
}
