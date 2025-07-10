import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/thought_log.dart'; // Import the model and lists

// REMOVED: import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LogThoughtScreen extends StatefulWidget {
  const LogThoughtScreen({super.key});

  @override
  State<LogThoughtScreen> createState() => _LogThoughtScreenState();
}

class _LogThoughtScreenState extends State<LogThoughtScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _triggerController = TextEditingController();
  final TextEditingController _automaticThoughtController = TextEditingController();
  final TextEditingController _reframeController = TextEditingController();

  String? _selectedDistortionType;
  String? _selectedEmotion;
  double _intensity = 5.0; // Default intensity

  @override
  void dispose() {
    _triggerController.dispose();
    _automaticThoughtController.dispose();
    _reframeController.dispose();
    super.dispose();
  }

  Future<void> _saveThought() async {
    if (_formKey.currentState!.validate()) {
      final newThought = ThoughtLog(
        trigger: _triggerController.text.trim(),
        automaticThought: _automaticThoughtController.text.trim(),
        distortionType: _selectedDistortionType!,
        emotion: _selectedEmotion!,
        intensity: _intensity.round(),
        reframe: _reframeController.text.trim().isEmpty ? null : _reframeController.text.trim(),
        dateLogged: DateTime.now(),
      );

      final thoughtLogsBox = Hive.box<ThoughtLog>('thoughtLogs');
      await thoughtLogsBox.add(newThought);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thought logged successfully!')),
        );
        Navigator.of(context).pop(); // Go back to the previous screen (Home)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log a New Thought'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What triggered this thought?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _triggerController,
                decoration: const InputDecoration(
                  labelText: 'Trigger (e.g., "Someone ignored my message")',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a trigger.';
                  }
                  return null;
                },
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              Text(
                'What was the automatic thought?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _automaticThoughtController,
                decoration: const InputDecoration(
                  labelText: 'Automatic Thought (e.g., "They hate me")',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.psychology_alt),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the automatic thought.';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Text(
                'What type of cognitive distortion is this?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedDistortionType,
                decoration: const InputDecoration(
                  labelText: 'Distortion Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: distortionTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDistortionType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a distortion type.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'What emotion did you feel?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedEmotion,
                decoration: const InputDecoration(
                  labelText: 'Emotion Felt',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sentiment_satisfied_alt),
                ),
                items: emotionTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedEmotion = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an emotion.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Intensity of emotion (1-10): ${_intensity.round()}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _intensity,
                min: 1,
                max: 10,
                divisions: 9,
                label: _intensity.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _intensity = value;
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
                inactiveColor: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.3).round()),
              ),
              const SizedBox(height: 20),
              Text(
                'Optional: What\'s another explanation or reframe?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reframeController,
                decoration: const InputDecoration(
                  labelText: 'Reframe Prompt (e.g., "Maybe they\'re just busy?")',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lightbulb),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveThought,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Thought'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }
}