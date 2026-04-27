import '../../../core/models/notification_item.dart';

class NotificationsResponse {
  final List<NotificationItem> items;
  final int? total;

  const NotificationsResponse({
    required this.items,
    this.total,
  });

  factory NotificationsResponse.fromJson(dynamic data) {
    if (data is List) {
      return NotificationsResponse(items: _parseList(data));
    }
    if (data is Map) {
      final itemsData =
          data['items'] ?? data['data'] ?? data['notifications'] ?? data['results'];
      final totalValue = data['total'] ?? data['count'];
      return NotificationsResponse(
        items: _parseList(itemsData),
        total: _parseInt(totalValue),
      );
    }
    return const NotificationsResponse(items: []);
  }

  static List<NotificationItem> _parseList(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => NotificationItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
