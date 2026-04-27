import 'package:flutter/material.dart';
import '../../core/models/user.dart';
import '../../core/storage/session_store.dart';
import 'auth_repository.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthRepository _repo;
  final SessionStore _session;
  User? _user;
  String? _accessToken;
  String? _pendingEmail;
  bool _loading = false;
  String? _avatarError;

  User? get user => _user;
  String? get accessToken => _accessToken;
  String? get pendingEmail => _pendingEmail;
  bool get isAuthenticated => _user != null;
  Role? get role => _user?.role;
  bool get loading => _loading;
  String? get avatarError => _avatarError;

  AuthNotifier(this._repo, this._session) {
    _restore();
  }

  Future<User> _mergeAvatar(User user) async {
    final cachedAvatar = await _session.readAvatar(user.id);
    if ((user.avatar == null || user.avatar!.isEmpty) && cachedAvatar != null) {
      return user.copyWith(avatar: cachedAvatar);
    }
    if (user.avatar != null && user.avatar!.isNotEmpty) {
      await _session.saveAvatar(user.id, user.avatar);
    }
    return user;
  }

  Future<void> _restore() async {
    _loading = true;
    notifyListeners();
    _user = await _session.read();
    _accessToken = await _session.readToken();
    final refreshToken = await _session.readRefreshToken();
    final expiresAt = await _session.readTokenExpiry();
    if (_accessToken != null &&
        _accessToken!.isNotEmpty &&
        (expiresAt == null || DateTime.now().isBefore(expiresAt))) {
      final fresh = await _repo.fetchCurrentUser(accessToken: _accessToken!);
      if (fresh != null) {
        _user = await _mergeAvatar(fresh);
        await _session.saveSession(
          _user!,
          accessToken: _accessToken,
          refreshToken: refreshToken,
          expiresAt: expiresAt,
        );
      }
    } else if (refreshToken != null && refreshToken.isNotEmpty) {
      final refreshed = await _repo.refreshSession(refreshToken: refreshToken);
      if (refreshed != null) {
        _user = await _mergeAvatar(refreshed.user);
        _accessToken = refreshed.accessToken;
        await _session.saveSession(
          _user!,
          accessToken: refreshed.accessToken,
          refreshToken: refreshed.refreshToken,
          expiresAt: refreshed.expiresAt,
        );
      }
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final session = await _repo.login(email, password);
      _user = await _mergeAvatar(session.user);
      _accessToken = session.accessToken;
      await _session.saveSession(
        _user!,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        expiresAt: session.expiresAt,
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      // Ensure any previous session doesn't override the new signup flow.
      _user = null;
      _accessToken = null;
      await _session.clear();
      await _repo.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      _pendingEmail = email;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> verifySignUp(String token) async {
    final email = _pendingEmail;
    if (email == null) {
      throw StateError('Missing email');
    }
    _loading = true;
    notifyListeners();
    try {
      final session = await _repo.verifySignUp(email: email, token: token);
      _user = await _mergeAvatar(session.user);
      _accessToken = session.accessToken;
      await _session.saveSession(
        _user!,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        expiresAt: session.expiresAt,
      );
      _pendingEmail = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordReset(String email) async {
    _loading = true;
    notifyListeners();
    try {
      await _repo.sendPasswordReset(email);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    await _session.clear();
    notifyListeners();
  }

  Future<bool> updateAvatarBytes({
    required List<int> bytes,
    required String extension,
    String? fallbackDataUrl,
  }) async {
    if (_user == null) return false;
    var token = _accessToken;
    // Optimistic local update (helps on web if upload fails).
    if (fallbackDataUrl != null && fallbackDataUrl.isNotEmpty) {
      _user = _user!.copyWith(avatar: fallbackDataUrl);
      notifyListeners();
    }
    final expiry = await _session.readTokenExpiry();
    if (token == null || token.isEmpty) {
      final refresh = await _session.readRefreshToken();
      if (refresh != null && refresh.isNotEmpty) {
        final refreshed = await _repo.refreshSession(refreshToken: refresh);
        if (refreshed != null) {
          token = refreshed.accessToken;
          _accessToken = refreshed.accessToken;
          await _session.saveSession(
            refreshed.user,
            accessToken: refreshed.accessToken,
            refreshToken: refreshed.refreshToken,
            expiresAt: refreshed.expiresAt,
          );
        }
      }
    } else if (expiry != null && DateTime.now().isAfter(expiry)) {
      final refresh = await _session.readRefreshToken();
      if (refresh != null && refresh.isNotEmpty) {
        final refreshed = await _repo.refreshSession(refreshToken: refresh);
        if (refreshed != null) {
          token = refreshed.accessToken;
          _accessToken = refreshed.accessToken;
          await _session.saveSession(
            refreshed.user,
            accessToken: refreshed.accessToken,
            refreshToken: refreshed.refreshToken,
            expiresAt: refreshed.expiresAt,
          );
        }
      }
    }
    if (token == null || token.isEmpty) {
      return false;
    }
    _loading = true;
    notifyListeners();
    try {
      final avatarUrl = await _repo.uploadAvatar(
        userId: _user!.id,
        bytes: bytes,
        extension: extension,
        accessToken: token,
      );
      final updated = await _repo.updateAvatarUrl(
        accessToken: token,
        user: _user!,
        avatarUrl: avatarUrl,
      );
      _user = updated;
      _avatarError = null;
      await _session.saveAvatar(_user!.id, avatarUrl);
      await _session.saveSession(
        _user!,
        accessToken: _accessToken,
        refreshToken: await _session.readRefreshToken(),
        expiresAt: await _session.readTokenExpiry(),
      );
      return true;
    } catch (e) {
      _avatarError = e.toString();
      if (fallbackDataUrl != null && fallbackDataUrl.isNotEmpty) {
        await _session.saveAvatar(_user!.id, fallbackDataUrl);
        await _session.saveSession(
          _user!,
          accessToken: _accessToken,
          refreshToken: await _session.readRefreshToken(),
          expiresAt: await _session.readTokenExpiry(),
        );
      }
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
