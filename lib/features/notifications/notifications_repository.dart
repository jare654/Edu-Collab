import '../../core/models/notification_item.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_error.dart';
import 'dto/notifications_response.dart';
import '../auth/auth_notifier.dart';

class NotificationsRepository {
  final ApiClient _client;
  final AuthNotifier _auth;

  NotificationsRepository(this._client, this._auth);

  Future<List<NotificationItem>> fetchNotifications() async {
    try {
      final email = _auth.user?.email;
      if (email == null || email.isEmpty) {
        return const [];
      }
      final normalizedEmail = email.trim().toLowerCase();
      final path =
          '${ApiEndpoints.notifications}?recipient_email=eq.${Uri.encodeComponent(normalizedEmail)}&order=created_at.desc';
      final response = await _client.dio.get(path);
      final parsed = NotificationsResponse.fromJson(response.data);
      return parsed.items;
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
