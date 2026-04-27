class MessageItem {
  final String id;
  final String sender;
  final String content;
  final DateTime time;
  final bool isMine;

  const MessageItem({
    required this.id,
    required this.sender,
    required this.content,
    required this.time,
    required this.isMine,
  });

  factory MessageItem.fromJson(Map<String, dynamic> json) {
    return MessageItem(
      id: json['id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      time: DateTime.tryParse(json['time']?.toString() ?? '') ?? DateTime.now(),
      isMine: json['isMine'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender': sender,
        'content': content,
        'time': time.toIso8601String(),
        'isMine': isMine,
      };
}
