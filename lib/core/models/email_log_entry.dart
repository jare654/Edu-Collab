enum EmailLogType { assignment, groupInvite }
enum EmailLogStatus { sent, failed }

class EmailLogEntry {
  final String id;
  final EmailLogType type;
  final String recipient;
  final String subject;
  final EmailLogStatus status;
  final DateTime timestamp;
  final String? message;

  const EmailLogEntry({
    required this.id,
    required this.type,
    required this.recipient,
    required this.subject,
    required this.status,
    required this.timestamp,
    this.message,
  });
}
