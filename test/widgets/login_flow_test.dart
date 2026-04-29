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
import 'package:academic_collab_app/core/localization/app_strings.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class _FakeAuthRepo implements AuthRepository {
  @override
  Future<AuthSession> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return AuthSession(
      user: User(id: 'u1', name: 'Test User', email: email, role: Role.student),
      accessToken: 'token',
    );
  }

  @override
  Future<void> signUp({required String email, required String password, required String fullName, required String role}) async {}

  @override
  Future<AuthSession> verifySignUp({required String email, required String token}) async {
    return AuthSession(
      user: User(id: 'u1', name: 'Test User', email: email, role: Role.student),
      accessToken: 'token',
    );
  }

  @override
  Future<AuthSession?> refreshSession({required String refreshToken}) async {
    return null;
  }

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
  testWidgets('Login flow sets loading state', (tester) async {
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
        child: const MaterialApp(
          localizationsDelegates: [
            AppStringsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    await tester.tap(find.text('Log In'));
    await tester.pump();
    expect(find.text('Signing in...'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
  });
}
