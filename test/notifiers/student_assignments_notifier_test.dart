import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'package:academic_collab_app/core/models/assignment.dart';
import 'package:academic_collab_app/features/assignments/assignments_repository.dart';
import 'package:academic_collab_app/features/assignments/student_assignments_notifier.dart';

class _FakeAssignmentsRepo implements AssignmentsRepository {
  @override
  Future<List<Assignment>> fetchStudentAssignments() async {
    return [
      Assignment(
        id: 'a1',
        title: 'Test Assignment',
        course: 'ARCH-101',
        dueDate: DateTime(2026, 4, 2),
        status: AssignmentStatus.upcoming,
      ),
    ];
  }

  @override
  Future<void> submitAssignment(
    String assignmentId, {
    String? note,
    List<MultipartFile> files = const [],
    Uint8List? fileBytes,
    String? filename,
  }) async {}
}

void main() {
  test('StudentAssignmentsNotifier loads assignments', () async {
    final notifier = StudentAssignmentsNotifier(_FakeAssignmentsRepo());
    await notifier.load();
    expect(notifier.items.length, 1);
    expect(notifier.loading, false);
    expect(notifier.error, isNull);
  });
}
