class SubmissionItem {
  final String id;
  final String assignmentId;
  final String studentName;
  final String status;
  final String submittedAt;
  final bool submitted;

  const SubmissionItem({
    required this.id,
    required this.assignmentId,
    required this.studentName,
    required this.status,
    required this.submittedAt,
    required this.submitted,
  });

  factory SubmissionItem.fromJson(Map<String, dynamic> json) {
    final studentMap = json['student'];
    final studentName = json['studentName'] ??
        json['student_name'] ??
        (studentMap is Map ? studentMap['full_name'] : null);
    final submittedAtRaw = json['submittedAt'] ?? json['submitted_at'];
    final assignmentIdRaw = json['assignmentId'] ?? json['assignment_id'];
    return SubmissionItem(
      id: json['id'].toString(),
      assignmentId: assignmentIdRaw?.toString() ?? '',
      studentName: studentName?.toString() ?? '',
      status: json['status'].toString(),
      submittedAt: submittedAtRaw?.toString() ?? '',
      submitted: json['submitted'] == true || json['status']?.toString() == 'submitted',
    );
  }
}
