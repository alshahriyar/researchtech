// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:research_tech/main.dart';
import 'package:research_tech/services/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Initialize SharedPreferences with empty values for testing
    SharedPreferences.setMockInitialValues({});

    // Create a mock session
    final session = await UserSession.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(ResearchTechApp(session: session));

    // Verify that the app renders successfully (Login screen should appear)
    expect(find.text('Welcome to ResearchTech'), findsOneWidget);
  });
}
