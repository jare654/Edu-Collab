import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:academic_collab_app/features/lecturer/lecturer_create_assignment_screen.dart';
import 'package:academic_collab_app/features/lecturer/lecturer_assignments_notifier.dart';
import 'package:academic_collab_app/features/lecturer/lecturer_assignments_repository.dart';
import 'package:academic_collab_app/core/models/lecturer_assignment.dart';
import 'package:academic_collab_app/core/localization/app_strings.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:academic_collab_app/features/group/group_notifier.dart';
import 'package:academic_collab_app/features/group/group_repository.dart';
import 'package:academic_collab_app/core/models/group.dart';
import 'package:academic_collab_app/core/models/group_member.dart';
import 'package:academic_collab_app/features/notifications/email_log_notifier.dart';

class _FakeLecturerAssignmentsRepo implements LecturerAssignmentsRepository {
  @override
  Future<List<LecturerAssignment>> fetchAssignments() async {
    return const [];
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
    return AssignmentCreateResult(items: [assignment], emailSent: true);
  }

  @override
  Future<EmailSendResult> resendAssignmentEmails(LecturerAssignment assignment) async {
    return const EmailSendResult(ok: true);
  }
}

class _FakeGroupRepo implements GroupRepository {
  @override
  Future<List<Group>> fetchGroups() async => [];

  @override
  Future<List<String>> fetchGroupMemberEmails(String groupId) async => [];

  @override
  Future<List<GroupMember>> fetchGroupMembers(String groupId) async => [];

  @override
  Future<GroupMemberAddResult> addGroupMember(String groupId, String email, {bool sendEmail = false}) async {
    return GroupMemberAddResult(
      member: GroupMember(id: 'm1', groupId: groupId, email: email),
      emailSent: true,
    );
  }

  @override
  Future<void> removeGroupMember(String memberId) async {}

  @override
  Future<Group> createGroup({
    required String name,
    required String courseCode,
    String? description,
  }) async {
    return Group(id: 'g2', name: name, courseCode: courseCode, members: 0);
  }
}

void main() {
  testWidgets('Lecturer create assignment submits', (tester) async {
    final notifier = LecturerAssignmentsNotifier(_FakeLecturerAssignmentsRepo());
    final groupNotifier = GroupNotifier(_FakeGroupRepo());
    final emailLogNotifier = EmailLogNotifier();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: notifier),
          ChangeNotifierProvider.value(value: groupNotifier),
          ChangeNotifierProvider.value(value: emailLogNotifier),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppStringsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: LecturerCreateAssignmentScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final titleField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == 'e.g., Heritage Mapping: Addis Ababa',
    );
    final courseField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == 'URB-210',
    );
    final emailsField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == 'student1@school.edu, student2@school.edu',
    );
    await tester.ensureVisible(titleField);
    await tester.enterText(titleField, 'Test Assignment');
    await tester.pump();
    await tester.ensureVisible(courseField);
    await tester.enterText(courseField, 'URB-210');
    await tester.pump();
    await tester.ensureVisible(emailsField);
    await tester.enterText(emailsField, 'test@school.edu');
    await tester.pump();
    await tester.ensureVisible(find.text('Publish Assignment'));
    await tester.tap(find.text('Publish Assignment'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    expect(notifier.items.isNotEmpty, true);
  });
}
