class MeetingSession {
  final String id;
  final String groupId;
  final String roomName;
  final DateTime startTime;
  final DateTime? endTime;

  const MeetingSession({
    required this.id,
    required this.groupId,
    required this.roomName,
    required this.startTime,
    this.endTime,
  });

  factory MeetingSession.fromJson(Map<String, dynamic> json) {
    return MeetingSession(
      id: json['id'].toString(),
      groupId: json['group_id'].toString(),
      roomName: json['room_name'].toString(),
      startTime: DateTime.parse(json['start_time'].toString()),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'].toString()),
    );
  }
}

class MeetingAttendance {
  final String id;
  final String sessionId;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String? role;
  final DateTime joinTime;
  final DateTime? leaveTime;

  const MeetingAttendance({
    required this.id,
    required this.sessionId,
    required this.userId,
    this.userName,
    this.userEmail,
    this.role,
    required this.joinTime,
    this.leaveTime,
  });

  factory MeetingAttendance.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    String? name;
    String? email;
    if (user is Map) {
      final meta = user['user_metadata'];
      name = (meta is Map ? meta['full_name'] ?? meta['name'] : null)
          ?.toString();
      email = user['email']?.toString();
    }
    return MeetingAttendance(
      id: json['id'].toString(),
      sessionId: json['session_id'].toString(),
      userId: json['user_id'].toString(),
      userName: name,
      userEmail: email,
      role: json['role']?.toString(),
      joinTime: DateTime.parse(json['join_time'].toString()),
      leaveTime: json['leave_time'] == null
          ? null
          : DateTime.parse(json['leave_time'].toString()),
    );
  }
}
