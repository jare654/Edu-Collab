import 'package:flutter_test/flutter_test.dart';
import 'package:academic_collab_app/core/models/lecturer_assignment.dart';
import 'package:academic_collab_app/features/lecturer/lecturer_assignments_repository.dart';
import 'package:academic_collab_app/features/lecturer/lecturer_assignments_notifier.dart';

class _FakeLecturerAssignmentsRepo implements LecturerAssignmentsRepository {
  @override
  Future<List<LecturerAssignment>> fetchAssignments() async {
    return const [
      LecturerAssignment(
        id: 'la1',
        title: 'Test Lecturer Assignment',
        course: 'ARCH-302',
        submitted: 2,
        total: 5,
        isGroup: false,
      ),
    ];
  }

  @override
  Future<AssignmentCreateResult> createAssignment(
    LecturerAssignment assignment, {
    String? description,
    DateTime? dueDate,
    List<String>? assignedEmails,
    bool? isGroup,
    bool sendEmail = false,
  }) async {
    return AssignmentCreateResult(
      items: [assignment],
      emailSent: true,
    );
  }

  @override
  Future<EmailSendResult> resendAssignmentEmails(LecturerAssignment assignment) async {
    return const EmailSendResult(ok: true);
  }
}

void main() {
  test('LecturerAssignmentsNotifier loads assignments', () async {
    final notifier = LecturerAssignmentsNotifier(_FakeLecturerAssignmentsRepo());
    await notifier.load();
    expect(notifier.items.length, 1);
    expect(notifier.loading, false);
  });
}
