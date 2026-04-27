class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final String? recipientEmail;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.recipientEmail,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['created_at'] ?? json['time'];
    return NotificationItem(
      id: json['id'].toString(),
      title: json['title'].toString(),
      body: json['body'].toString(),
      time: DateTime.parse(createdRaw.toString()),
      recipientEmail: json['recipient_email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'time': time.toIso8601String(),
        'recipient_email': recipientEmail,
      };
}
