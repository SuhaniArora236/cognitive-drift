import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'models/thought_log.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter widgets are initialized

  // Get the application documents directory for Hive storage
  final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);

  // Register the generated adapter for ThoughtLog
  Hive.registerAdapter(ThoughtLogAdapter());

  // Open the Hive boxes that we'll use throughout the app
  await Hive.openBox<bool>('settingsBox'); // To store app settings like onboarding status
  await Hive.openBox<ThoughtLog>('thoughtLogs'); // To store all thought entries

  // Determine initial route based on onboarding status
  final settingsBox = Hive.box<bool>('settingsBox');
  final bool onboardingComplete = settingsBox.get('onboardingComplete', defaultValue: false)!;

  runApp(MyApp(onboardingComplete: onboardingComplete));
}

class MyApp extends StatelessWidget {
  final bool onboardingComplete;
  const MyApp({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cognitive Drift',
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, // Primary color for the app
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white, // Text color for app bar
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData( // FIX: Changed to CardThemeData
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        textTheme: TextTheme(
          headlineSmall: TextStyle(color: Colors.deepPurple.shade700, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.grey.shade800),
          bodyMedium: TextStyle(color: Colors.grey.shade700),
        ),
      ),
      home: onboardingComplete ? const HomeScreen() : const OnboardingScreen(), // Use direct check
    );
  }
}