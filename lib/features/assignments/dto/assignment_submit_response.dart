class AssignmentSubmitResponse {
  final String submissionId;
  final String status;

  const AssignmentSubmitResponse({
    required this.submissionId,
    required this.status,
  });

  factory AssignmentSubmitResponse.fromJson(Map<String, dynamic> json) {
    final idRaw = json['submissionId'] ?? json['id'];
    final statusRaw = json['status'] ?? json['state'];
    return AssignmentSubmitResponse(
      submissionId: idRaw?.toString() ?? '',
      status: statusRaw?.toString() ?? 'submitted',
    );
  }
}
