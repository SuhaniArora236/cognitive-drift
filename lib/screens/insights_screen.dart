import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart'; // New import for FL Chart
import '../models/thought_log.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<ThoughtLog>('thoughtLogs').listenable(),
      builder: (context, Box<ThoughtLog> box, _) {
        if (box.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lightbulb_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Log more thoughts to unlock insights!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final List<ThoughtLog> logs = box.values.toList();

        // Calculate distortion frequency
        final Map<String, int> distortionCounts = {};
        for (var log in logs) {
          distortionCounts[log.distortionType] = (distortionCounts[log.distortionType] ?? 0) + 1;
        }

        final List<BarChartGroupData> distortionBarGroups = [];
        final List<String> distortionLabels = [];
        int distortionIndex = 0;
        final int maxDistortionValue = distortionCounts.values.isEmpty ? 1 : distortionCounts.values.reduce((a, b) => a > b ? a : b);

        // FIX: Separate toList() and sort()
        final sortedDistortionEntries = distortionCounts.entries.toList();
        sortedDistortionEntries.sort((a, b) => b.value.compareTo(a.value)); // Sort descending

        sortedDistortionEntries.forEach((entry) { // Use the sorted list here
            distortionLabels.add(entry.key);
            distortionBarGroups.add(
              BarChartGroupData(
                x: distortionIndex,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.toDouble(),
                    color: Theme.of(context).colorScheme.primary,
                    width: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
            distortionIndex++;
          });


        // Calculate emotion frequency
        final Map<String, int> emotionCounts = {};
        for (var log in logs) {
          emotionCounts[log.emotion] = (emotionCounts[log.emotion] ?? 0) + 1;
        }

        final List<PieChartSectionData> emotionPieSections = [];
        int totalEmotions = emotionCounts.values.fold(0, (sum, count) => sum + count);
        int colorIndex = 0;
        final List<Color> pieColors = [
          Colors.blue.shade300, Colors.red.shade300, Colors.green.shade300,
          Colors.yellow.shade300, Colors.purple.shade300, Colors.orange.shade300,
          Colors.teal.shade300, Colors.pink.shade300, Colors.brown.shade300
        ]; // Example colors

        // FIX: Separate toList() and sort()
        final sortedEmotionEntries = emotionCounts.entries.toList();
        sortedEmotionEntries.sort((a, b) => b.value.compareTo(a.value)); // Sort descending

        sortedEmotionEntries.forEach((entry) { // Use the sorted list here
            final double percentage = (entry.value / totalEmotions) * 100;
            emotionPieSections.add(
              PieChartSectionData(
                color: pieColors[colorIndex % pieColors.length],
                value: entry.value.toDouble(),
                title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                titlePositionPercentageOffset: 0.55, // Adjust text position
              ),
            );
            colorIndex++;
          });


        // Basic "You often experience..." insights (can be expanded)
        String commonInsight = _generateSimpleInsight(logs);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Distortion Patterns',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250, // Fixed height for chart
                        child: BarChart(
                          BarChartData(
                            barGroups: distortionBarGroups,
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index >= 0 && index < distortionLabels.length) {
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        space: 4.0,
                                        child: Text(
                                          distortionLabels[index],
                                          style: const TextStyle(fontSize: 10),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: maxDistortionValue / 3 > 1 ? (maxDistortionValue / 3).roundToDouble() : 1, // Dynamic interval
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt().toDouble() == value) {
                                      return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                                    }
                                    return const Text('');
                                  },
                                  reservedSize: 28,
                                ),
                              ),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emotion Frequency',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: PieChart(
                          PieChartData(
                            sections: emotionPieSections,
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            pieTouchData: PieTouchData(enabled: false), // Disable touch for simplicity
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personalized Insight',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        commonInsight,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // A very basic insight generator. Can be made much more sophisticated.
  String _generateSimpleInsight(List<ThoughtLog> logs) {
    if (logs.isEmpty) return 'Log more thoughts to see personalized insights!';

    final Map<String, Map<String, int>> triggerDistortionMatrix = {};
    for (var log in logs) {
      final triggerCategory = _categorizeTrigger(log.trigger);
      triggerDistortionMatrix.putIfAbsent(triggerCategory, () => {});
      triggerDistortionMatrix[triggerCategory]![log.distortionType] =
          (triggerDistortionMatrix[triggerCategory]![log.distortionType] ?? 0) + 1;
    }

    String mostCommonTriggerDistortion = 'It seems you\'re gaining awareness of your thinking patterns.';
    int maxCount = 0;

    triggerDistortionMatrix.forEach((trigger, distortions) {
      distortions.forEach((distortion, count) {
        if (count > maxCount) {
          maxCount = count;
          mostCommonTriggerDistortion = 'You often experience "${distortion.toLowerCase()}" thinking when triggered by "${trigger.toLowerCase()}".';
        }
      });
    });

    return mostCommonTriggerDistortion;
  }

  String _categorizeTrigger(String trigger) {
    final lowerTrigger = trigger.toLowerCase();
    if (lowerTrigger.contains('social') || lowerTrigger.contains('people') || lowerTrigger.contains('friends')) {
      return 'Social situations';
    } else if (lowerTrigger.contains('work') || lowerTrigger.contains('job') || lowerTrigger.contains('career')) {
      return 'Work/Career related issues';
    } else if (lowerTrigger.contains('family') || lowerTrigger.contains('partner') || lowerTrigger.contains('relationship')) {
      return 'Relationships';
    } else if (lowerTrigger.contains('health') || lowerTrigger.contains('sickness')) {
      return 'Health concerns';
    } else if (lowerTrigger.contains('money') || lowerTrigger.contains('finance')) {
      return 'Financial issues';
    }
    return 'General situations';
  }
}