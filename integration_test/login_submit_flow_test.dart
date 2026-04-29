import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:academic_collab_app/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login to submit assignment flow', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle(const Duration(milliseconds: 800));

    expect(find.text('Sign in to your studio'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'student@atelier.edu');
    await tester.enterText(find.byType(TextField).at(1), 'student123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    await tester.tap(find.text('Assignments'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    await tester.tap(find.text('View details').first);
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    await tester.ensureVisible(find.text('Submit Assignment'));
    await tester.tap(find.text('Submit Assignment'), warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(find.text('Submit Assignment'), findsOneWidget);
  });
}
