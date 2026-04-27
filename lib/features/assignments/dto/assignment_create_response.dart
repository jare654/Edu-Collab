class AssignmentCreateResponse {
  final String id;
  final String title;
  final String course;
  final String dueDate;

  const AssignmentCreateResponse({
    required this.id,
    required this.title,
    required this.course,
    required this.dueDate,
  });

  factory AssignmentCreateResponse.fromJson(Map<String, dynamic> json) {
    return AssignmentCreateResponse(
      id: json['id'].toString(),
      title: json['title'].toString(),
      course: json['course'].toString(),
      dueDate: json['dueDate'].toString(),
    );
  }
}
