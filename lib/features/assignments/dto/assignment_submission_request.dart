class AssignmentSubmissionRequest {
  final String assignmentId;
  final String studentId;
  final String submissionUrl;
  final DateTime submittedAt;

  const AssignmentSubmissionRequest({
    required this.assignmentId,
    required this.studentId,
    required this.submissionUrl,
    required this.submittedAt,
  });

  Map<String, dynamic> toJson() => {
        'assignment_id': assignmentId,
        'student_id': studentId,
        'submission_url': submissionUrl,
        'submitted_at': submittedAt.toIso8601String(),
      };
}
