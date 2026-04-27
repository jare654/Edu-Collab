import '../../core/models/user.dart';

class AuthSession {
  final User user;
  final String? accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  const AuthSession({
    required this.user,
    this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });
}
