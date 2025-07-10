import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import hive_flutter

import 'package:cognitive_drift/main.dart'; // Import your main.dart

void main() {
  // Initialize Hive in tests (you might need a mock path provider for this)
  // For simple widget tests, you can often mock Hive or avoid its initialization
  // if the widget being tested doesn't directly depend on it or if the test
  // focuses on UI rather than data persistence.
  // However, since MyApp directly uses Hive in main, we need a setup.

  setUpAll(() async {
    // Initialize Hive for tests in a temporary directory
    // This is a minimal setup, for more complex scenarios, consider:
    // https://docs.hivedb.dev/#/advanced/testing
    Hive.init('./test_hive_db'); // Use a temporary directory for testing
  });

  tearDownAll(() async {
    // Delete the test Hive directory after all tests are done
    await Hive.deleteFromDisk();
  });


  testWidgets('App starts with OnboardingScreen if onboarding is not complete', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Pass false to simulate onboarding not being complete
    await tester.pumpWidget(const MyApp(onboardingComplete: false)); // FIX: Added onboardingComplete

    // Verify that OnboardingScreen is shown
    expect(find.text('What are Automatic Thoughts?'), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);
  });

  testWidgets('App starts with HomeScreen if onboarding is complete', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Pass true to simulate onboarding being complete
    await tester.pumpWidget(const MyApp(onboardingComplete: true)); // FIX: Added onboardingComplete

    // Verify that HomeScreen is shown (e.g., by checking for 'Dashboard' or 'Log a Thought' text)
    expect(find.text('Cognitive Drift'), findsOneWidget);
    expect(find.text('Log a Thought'), findsOneWidget);
  });
}