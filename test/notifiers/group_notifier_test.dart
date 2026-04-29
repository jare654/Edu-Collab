import 'package:flutter_test/flutter_test.dart';
import 'package:academic_collab_app/core/models/group.dart';
import 'package:academic_collab_app/core/models/group_member.dart';
import 'package:academic_collab_app/features/group/group_repository.dart';
import 'package:academic_collab_app/features/group/group_notifier.dart';

class _FakeGroupRepo implements GroupRepository {
  @override
  Future<List<Group>> fetchGroups() async {
    return const [
      Group(id: 'g1', name: 'Test Group', courseCode: 'ARCH-101', members: 4),
    ];
  }

  @override
  Future<List<GroupMember>> fetchGroupMembers(String groupId) async => [];

  @override
  Future<List<String>> fetchGroupMemberEmails(String groupId) async => [];

  @override
  Future<GroupMemberAddResult> addGroupMember(String groupId, String email, {bool sendEmail = false}) async {
    return GroupMemberAddResult(
      member: GroupMember(id: 'm1', email: email, groupId: groupId),
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
  test('GroupNotifier loads groups', () async {
    final notifier = GroupNotifier(_FakeGroupRepo());
    await notifier.load();
    expect(notifier.items.length, 1);
    expect(notifier.loading, false);
  });
}
