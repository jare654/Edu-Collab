import '../../core/models/lecturer_assignment.dart';

class AssignmentCreateResult {
  final List<LecturerAssignment> items;
  final bool emailSent;
  final String? emailMessage;

  const AssignmentCreateResult({
    required this.items,
    required this.emailSent,
    this.emailMessage,
  });
}

class EmailSendResult {
  final bool ok;
  final String? message;

  const EmailSendResult({required this.ok, this.message});
}

abstract class LecturerAssignmentsRepository {
  Future<List<LecturerAssignment>> fetchAssignments();
  Future<AssignmentCreateResult> createAssignment(
    LecturerAssignment assignment, {
    String? description,
    DateTime? dueDate,
    List<String>? assignedEmails,
    bool? isGroup,
    bool sendEmail = false,
  });
  Future<EmailSendResult> resendAssignmentEmails(LecturerAssignment assignment);
}
