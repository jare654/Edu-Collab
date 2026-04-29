import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:academic_collab_app/features/auth/auth_notifier.dart';
import 'package:academic_collab_app/features/auth/auth_repository.dart';
import 'package:academic_collab_app/features/auth/login_screen.dart';
import 'package:academic_collab_app/core/storage/session_store.dart';
import 'package:academic_collab_app/core/models/user.dart';
import 'package:academic_collab_app/features/auth/auth_session.dart';

class _FakeAuthRepo implements AuthRepository {
  @override
  Future<AuthSession> login(String email, String password) async {
    return AuthSession(
      user: User(id: 'u1', name: 'Test', email: email, role: Role.student),
      accessToken: 'token',
    );
  }

  @override
  Future<void> signUp({required String email, required String password, required String fullName, required String role}) async {}

  @override
  Future<AuthSession> verifySignUp({required String email, required String token}) async {
    return AuthSession(
      user: User(id: 'u1', name: 'Test', email: email, role: Role.student),
      accessToken: 'token',
    );
  }

  @override
  Future<AuthSession?> refreshSession({required String refreshToken}) async => null;

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<User?> fetchCurrentUser({required String accessToken}) async => null;

  @override
  Future<String> uploadAvatar({required String userId, required List<int> bytes, required String extension, required String accessToken}) async => '';

  @override
  Future<User> updateAvatarUrl({required String accessToken, required User user, required String avatarUrl}) async => user;
}

void main() {
  testWidgets('Login screen renders', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>(create: (_) => _FakeAuthRepo()),
          Provider(create: (_) => SessionStore()),
          ChangeNotifierProvider(
            create: (ctx) => AuthNotifier(ctx.read<AuthRepository>(), ctx.read<SessionStore>()),
          ),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    expect(find.text('Log In'), findsOneWidget);
    expect(find.byType(TextField), findsAtLeastNWidgets(2));
  });

  testWidgets('Password visibility toggle works', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>(create: (_) => _FakeAuthRepo()),
          Provider(create: (_) => SessionStore()),
          ChangeNotifierProvider(
            create: (ctx) => AuthNotifier(ctx.read<AuthRepository>(), ctx.read<SessionStore>()),
          ),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    final passwordField = find.byType(TextField).last;
    expect(tester.widget<TextField>(passwordField).obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    expect(tester.widget<TextField>(passwordField).obscureText, isFalse);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    expect(tester.widget<TextField>(passwordField).obscureText, isTrue);
  });
}
