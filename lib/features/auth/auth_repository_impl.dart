import '../../core/data/json_asset_loader.dart';
import '../../core/models/user.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_config.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_error.dart';
import 'auth_repository.dart';
import 'package:dio/dio.dart';
import 'auth_session.dart';
import '../../core/feature_flags.dart';

class AuthRepositoryImpl implements AuthRepository {
  final JsonAssetLoader _loader;

  final ApiClient _client;

  AuthRepositoryImpl(this._loader, this._client);

  User _mapUserFromSupabase(Map<String, dynamic> userMap) {
    final metadata = userMap['user_metadata'] ?? userMap['app_metadata'] ?? {};
    final roleValue = metadata is Map ? (metadata['role'] ?? 'student') : 'student';
    final roleText = roleValue.toString().toLowerCase();
    final nameValue = (metadata is Map ? (metadata['full_name'] ?? metadata['name']) : null)?.toString();
    final avatarValue = (metadata is Map
            ? (metadata['avatar_url'] ?? metadata['avatar'])
            : null)
        ?.toString();
    return User(
      id: userMap['id'].toString(),
      name: nameValue ?? userMap['email'].toString(),
      email: userMap['email'].toString(),
      role: (roleText == 'lecturer' || roleText == 'teacher') ? Role.lecturer : Role.student,
      avatar: avatarValue,
    );
  }

  @override
  Future<AuthSession> login(String email, String password) async {
    try {
      final response = await _client.dio.post(
        '${ApiConfig.authBaseUrl}${ApiEndpoints.authLogin}',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(headers: {
          'apikey': ApiConfig.anonKey,
          'Authorization': 'Bearer ${ApiConfig.anonKey}',
          'Accept': 'application/json',
        }),
      );
      final data = response.data;
      if (data is Map && data['user'] is Map) {
        final userMap = Map<String, dynamic>.from(data['user'] as Map);
        final user = _mapUserFromSupabase(userMap);
        final token = data['access_token']?.toString();
        final refresh = data['refresh_token']?.toString();
        final expiresIn = int.tryParse(data['expires_in']?.toString() ?? '');
        final expiresAt = expiresIn == null ? null : DateTime.now().add(Duration(seconds: expiresIn));
        return AuthSession(user: user, accessToken: token, refreshToken: refresh, expiresAt: expiresAt);
      }
      throw ApiError('Unexpected auth response');
    } catch (e) {
      final _ = mapDioError(e);
    }
    if (FeatureFlags.allowLocalAuth) {
      final raw = await _loader.loadList('assets/data/users.json');
      for (final row in raw) {
        final userEmail = row['email']?.toString().toLowerCase();
        final pass = row['password']?.toString() ?? '';
        if (userEmail == email.toLowerCase() && pass == password) {
          return AuthSession(user: User.fromJson(row));
        }
      }
    }
    throw StateError('Invalid credentials');
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      await _client.dio.post(
        '${ApiConfig.authBaseUrl}/signup',
        data: {
          'email': email,
          'password': password,
          'data': {
            'full_name': fullName,
            'role': role,
          },
        },
        options: Options(headers: {
          'apikey': ApiConfig.anonKey,
          'Authorization': 'Bearer ${ApiConfig.anonKey}',
          'Accept': 'application/json',
        }),
      );
    } catch (e) {
      final _ = mapDioError(e);
      rethrow;
    }
  }

  @override
  Future<AuthSession> verifySignUp({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _client.dio.post(
        '${ApiConfig.authBaseUrl}/verify',
        data: {
          'type': 'signup',
          'email': email,
          'token': token,
        },
        options: Options(headers: {
          'apikey': ApiConfig.anonKey,
          'Authorization': 'Bearer ${ApiConfig.anonKey}',
          'Accept': 'application/json',
        }),
      );
      final data = response.data;
      if (data is Map && data['user'] is Map) {
        final userMap = Map<String, dynamic>.from(data['user'] as Map);
        final user = _mapUserFromSupabase(userMap);
        final tokenValue = data['access_token']?.toString();
        final refresh = data['refresh_token']?.toString();
        final expiresIn = int.tryParse(data['expires_in']?.toString() ?? '');
        final expiresAt = expiresIn == null ? null : DateTime.now().add(Duration(seconds: expiresIn));
        return AuthSession(user: user, accessToken: tokenValue, refreshToken: refresh, expiresAt: expiresAt);
      }
      throw ApiError('Unexpected verify response');
    } catch (e) {
      final _ = mapDioError(e);
      rethrow;
    }
  }

  @override
  Future<AuthSession?> refreshSession({required String refreshToken}) async {
    try {
      final response = await _client.dio.post(
        '${ApiConfig.authBaseUrl}/token?grant_type=refresh_token',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {
          'apikey': ApiConfig.anonKey,
          'Authorization': 'Bearer ${ApiConfig.anonKey}',
          'Accept': 'application/json',
        }),
      );
      final data = response.data;
      if (data is Map && data['user'] is Map) {
        final userMap = Map<String, dynamic>.from(data['user'] as Map);
        final user = _mapUserFromSupabase(userMap);
        final tokenValue = data['access_token']?.toString();
        final refresh = data['refresh_token']?.toString();
        final expiresIn = int.tryParse(data['expires_in']?.toString() ?? '');
        final expiresAt = expiresIn == null ? null : DateTime.now().add(Duration(seconds: expiresIn));
        return AuthSession(user: user, accessToken: tokenValue, refreshToken: refresh, expiresAt: expiresAt);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _client.dio.post(
        '${ApiConfig.authBaseUrl}/recover',
        data: {'email': email},
        options: Options(headers: {
          'apikey': ApiConfig.anonKey,
          'Authorization': 'Bearer ${ApiConfig.anonKey}',
          'Accept': 'application/json',
        }),
      );
    } catch (e) {
      final _ = mapDioError(e);
      rethrow;
    }
  }

  @override
  Future<User?> fetchCurrentUser({required String accessToken}) async {
    try {
      final response = await _client.dio.get(
        '${ApiConfig.authBaseUrl}/user',
        options: Options(headers: {
          'apikey': ApiConfig.anonKey,
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        }),
      );
      final data = response.data;
      if (data is Map && data['user'] is Map) {
        final userMap = Map<String, dynamic>.from(data['user'] as Map);
        return _mapUserFromSupabase(userMap);
      }
      if (data is Map && data['id'] != null) {
        final userMap = Map<String, dynamic>.from(data);
        return _mapUserFromSupabase(userMap);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required List<int> bytes,
    required String extension,
    required String accessToken,
  }) async {
    final ext = extension.isNotEmpty ? extension : 'png';
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final storagePath = '$userId/$fileName';
    final uploadUrl = '${ApiConfig.storageBaseUrl}/object/${ApiConfig.avatarsBucket}/$storagePath';
    try {
      final response = await _client.dio.put(
        uploadUrl,
        data: bytes,
        options: Options(headers: {
          'apikey': ApiConfig.anonKey,
          'Authorization': 'Bearer $accessToken',
          'x-upsert': 'true',
          Headers.contentTypeHeader: 'image/$ext',
        }),
      );
      if ((response.statusCode ?? 500) >= 400) {
        throw ApiError('Upload failed (${response.statusCode})');
      }
    } catch (e) {
      if (e is DioException) {
        final code = e.response?.statusCode;
        final body = e.response?.data?.toString() ?? e.message;
        throw ApiError('Avatar upload failed (${code ?? 'unknown'}): $body');
      }
      final _ = mapDioError(e);
      throw ApiError('Avatar upload failed: $e');
    }
    return '${ApiConfig.avatarsPublicBase}/$storagePath';
  }

  @override
  Future<User> updateAvatarUrl({
    required String accessToken,
    required User user,
    required String avatarUrl,
  }) async {
    try {
      final response = await _client.dio.put(
        '${ApiConfig.authBaseUrl}/user',
        data: {
          'data': {
            'avatar_url': avatarUrl,
          },
        },
        options: Options(headers: {
          'apikey': ApiConfig.anonKey,
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        }),
      );
      final data = response.data;
      if (data is Map && data['user'] is Map) {
        final userMap = Map<String, dynamic>.from(data['user'] as Map);
        return _mapUserFromSupabase(userMap);
      }
    } catch (_) {}
    return user.copyWith(avatar: avatarUrl);
  }
}
