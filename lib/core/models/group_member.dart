class GroupMember {
  final String id;
  final String groupId;
  final String email;

  const GroupMember({
    required this.id,
    required this.groupId,
    required this.email,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'].toString(),
      groupId: (json['group_id'] ?? json['groupId']).toString(),
      email: (json['email'] ?? json['user_email'] ?? json['student_email']).toString(),
    );
  }
}
