class Group {
  final String id;
  final String name;
  final String courseCode;
  final int members;

  const Group({
    required this.id,
    required this.name,
    required this.courseCode,
    required this.members,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    final courseRaw = json['courseCode'] ?? json['course_code'] ?? json['course'];
    return Group(
      id: json['id'].toString(),
      name: json['name'].toString(),
      courseCode: courseRaw?.toString() ?? '',
      members: int.tryParse((json['members'] ?? json['member_count'] ?? '0').toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'course_code': courseCode,
        'members': members,
      };
}
