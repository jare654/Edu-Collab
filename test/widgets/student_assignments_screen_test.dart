import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'package:academic_collab_app/core/models/assignment.dart';
import 'package:academic_collab_app/core/network/connectivity_service.dart';
import 'package:academic_collab_app/features/assignments/assignments_repository.dart';
import 'package:academic_collab_app/features/assignments/student_assignments_notifier.dart';
import 'package:academic_collab_app/features/assignments/student_assignments_screen.dart';

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
  testWidgets('Student assignments screen shows tabs', (tester) async {
    final notifier = StudentAssignmentsNotifier(_FakeAssignmentsRepo());
    await notifier.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ConnectivityService()),
          ChangeNotifierProvider.value(value: notifier),
        ],
        child: const MaterialApp(home: StudentAssignmentsScreen()),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Test Assignment'), findsOneWidget);
  });
}
