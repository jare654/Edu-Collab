import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class SessionStore {
  static const _key = 'auth_user';
  static const _tokenKey = 'auth_token';
  static const _refreshKey = 'auth_refresh_token';
  static const _expiryKey = 'auth_token_expires_at';
  static const _avatarPrefix = 'avatar_';

  Future<User?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> readRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  Future<DateTime?> readTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getInt(_expiryKey);
    if (raw == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(raw);
  }

  Future<void> save(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(user.toJson()));
  }

  Future<void> saveSession(
    User user, {
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(user.toJson()));
    await saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  Future<void> saveTokens({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (accessToken == null || accessToken.isEmpty) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, accessToken);
    }
    if (refreshToken == null || refreshToken.isEmpty) {
      await prefs.remove(_refreshKey);
    } else {
      await prefs.setString(_refreshKey, refreshToken);
    }
    if (expiresAt == null) {
      await prefs.remove(_expiryKey);
    } else {
      await prefs.setInt(_expiryKey, expiresAt.millisecondsSinceEpoch);
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_expiryKey);
  }

  Future<void> saveAvatar(String userId, String? avatar) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_avatarPrefix$userId';
    if (avatar == null || avatar.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, avatar);
    }
  }

  Future<String?> readAvatar(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_avatarPrefix$userId');
  }
}
