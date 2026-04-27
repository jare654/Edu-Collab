import 'auth_session.dart';
import '../../core/models/user.dart';

abstract class AuthRepository {
  Future<AuthSession> login(String email, String password);
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  });
  Future<AuthSession> verifySignUp({
    required String email,
    required String token,
  });
  Future<AuthSession?> refreshSession({required String refreshToken});
  Future<void> sendPasswordReset(String email);
  Future<User?> fetchCurrentUser({required String accessToken});
  Future<String> uploadAvatar({
    required String userId,
    required List<int> bytes,
    required String extension,
    required String accessToken,
  });
  Future<User> updateAvatarUrl({
    required String accessToken,
    required User user,
    required String avatarUrl,
  });
}
