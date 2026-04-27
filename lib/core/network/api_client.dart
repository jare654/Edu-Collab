import 'package:dio/dio.dart';
import '../storage/session_store.dart';
import 'api_config.dart';

class ApiClient {
  final Dio dio;

  ApiClient(String baseUrl, SessionStore session)
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'apikey': ApiConfig.anonKey,
              'Authorization': 'Bearer ${ApiConfig.anonKey}',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await session.readToken();
        final expiry = await session.readTokenExpiry();
        String? accessToken = token;
        if (accessToken != null &&
            expiry != null &&
            DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 1)))) {
          final refreshed = await _refreshToken(session);
          if (refreshed != null) {
            accessToken = refreshed;
          }
        }
        if (accessToken != null && accessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        } else {
          options.headers['Authorization'] = 'Bearer ${ApiConfig.anonKey}';
        }
        options.headers['apikey'] = ApiConfig.anonKey;
        handler.next(options);
      },
    ));
  }

  Future<String?> _refreshToken(SessionStore session) async {
    final refresh = await session.readRefreshToken();
    if (refresh == null || refresh.isEmpty) return null;
    try {
      final refreshDio = Dio(BaseOptions(
        headers: {
          'apikey': ApiConfig.anonKey,
          'Authorization': 'Bearer ${ApiConfig.anonKey}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ));
      final response = await refreshDio.post(
        '${ApiConfig.authBaseUrl}/token?grant_type=refresh_token',
        data: {'refresh_token': refresh},
      );
      final data = response.data;
      if (data is Map) {
        final newToken = data['access_token']?.toString();
        final newRefresh = data['refresh_token']?.toString();
        final expiresIn = int.tryParse(data['expires_in']?.toString() ?? '');
        final expiresAt =
            expiresIn == null ? null : DateTime.now().add(Duration(seconds: expiresIn));
        await session.saveTokens(
          accessToken: newToken,
          refreshToken: newRefresh,
          expiresAt: expiresAt,
        );
        return newToken;
      }
    } catch (_) {}
    return null;
  }
}
