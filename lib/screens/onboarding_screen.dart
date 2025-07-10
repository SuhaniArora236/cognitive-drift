import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // CRITICAL: Ensure this import is here

import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  Future<void> _setOnboardingComplete() async {
    final settingsBox = Hive.box<bool>('settingsBox');
    await settingsBox.put('onboardingComplete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50, // Light background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                children: const [
                  OnboardingPage(
                    title: 'What are Automatic Thoughts?',
                    description:
                        'These are rapid, unconscious thoughts that pop into your mind throughout the day. They\'re often negative and can impact your mood and behavior.',
                    imagePath: 'assets/images/thought.png',
                  ),
                  OnboardingPage(
                    title: 'Understand Cognitive Distortions',
                    description:
                        'Distortions are biased ways of thinking that can lead us to view reality inaccurately. Learning to identify them is the first step to challenging them.',
                    imagePath: 'assets/images/distortion.png',
                  ),
                  OnboardingPage(
                    title: 'Track, Reflect, Transform',
                    description:
                        'Cognitive Drift helps you log your automatic thoughts, identify the distortions, and reflect on them. Over time, you\'ll gain insights and shift your perspective.',
                    imagePath: 'assets/images/tracking.png',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator( // This should now be recognized as a widget
                    controller: _pageController,
                    count: 3,
                    effect: const ExpandingDotsEffect( // This should now be recognized as a class
                      activeDotColor: Colors.deepPurple,
                      dotColor: Colors.deepPurple,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 2,
                    ),
                  ),
                  _currentPage == 2
                      ? ElevatedButton(
                          onPressed: _setOnboardingComplete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Get Started', style: TextStyle(fontSize: 16)),
                        )
                      : TextButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                          child: Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.deepPurple.shade700,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 200,
            width: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}