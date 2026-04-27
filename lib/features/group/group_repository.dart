import '../../core/models/group.dart';
import '../../core/models/group_member.dart';

class GroupMemberAddResult {
  final GroupMember member;
  final bool emailSent;
  final String? message;

  const GroupMemberAddResult({
    required this.member,
    required this.emailSent,
    this.message,
  });
}

abstract class GroupRepository {
  Future<List<Group>> fetchGroups();
  Future<List<GroupMember>> fetchGroupMembers(String groupId);
  Future<List<String>> fetchGroupMemberEmails(String groupId);
  Future<GroupMemberAddResult> addGroupMember(String groupId, String email, {bool sendEmail});
  Future<void> removeGroupMember(String memberId);
  Future<Group> createGroup({
    required String name,
    required String courseCode,
    String? description,
  });
}
