import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:academic_collab_app/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Lecturer creates an assignment', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle(const Duration(milliseconds: 800));

    await tester.enterText(find.byType(TextField).at(0), 'lecturer@atelier.edu');
    await tester.enterText(find.byType(TextField).at(1), 'lecturer123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle(const Duration(milliseconds: 800));

    await tester.tap(find.text('Assignments'));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    await tester.enterText(find.byType(TextField).at(0), 'API Integration Studio');
    await tester.enterText(find.byType(TextField).at(1), 'Build and test the full Supabase flow.');
    await tester.enterText(find.byType(TextField).at(2), 'CS101');
    await tester.enterText(find.byType(TextField).at(3), '2026-05-01');

    await tester.ensureVisible(find.text('Publish Assignment'));
    await tester.tap(find.text('Publish Assignment'), warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(milliseconds: 800));

    expect(find.text('Assignments'), findsWidgets);
  });
}
