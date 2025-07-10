import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart'; // New import for FL Chart

import '../models/thought_log.dart';
import 'log_thought_screen.dart';
import 'thought_history_screen.dart';
import 'insights_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    _DashboardView(),
    ThoughtHistoryScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cognitive Drift'),
        centerTitle: true,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LogThoughtScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Log a Thought'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<ThoughtLog>('thoughtLogs').listenable(),
      builder: (context, Box<ThoughtLog> box, _) {
        if (box.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.psychology_alt, size: 80, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome to Cognitive Drift!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Log your first automatic negative thought to start gaining insights.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Tap the "Log a Thought" button below to begin.',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final List<ThoughtLog> logs = box.values.toList();

        // Calculate most frequent distortion
        final Map<String, int> distortionCounts = {};
        for (var log in logs) {
          distortionCounts[log.distortionType] = (distortionCounts[log.distortionType] ?? 0) + 1;
        }
        final String mostFrequentDistortion = distortionCounts.entries.fold('', (prev, e) => e.value > (distortionCounts[prev] ?? 0) ? e.key : prev);

        // Prepare data for weekly chart (last 7 days)
        final Map<int, int> dailyThoughtCountsIndexed = {}; // Use int for day index (0-6)
        final List<String> dayLabels = []; // For bottom titles

        // Initialize last 7 days with 0 counts
        for (int i = 6; i >= 0; i--) { // Iterate backwards to get correct order for labels and data
          final date = DateTime.now().subtract(Duration(days: i));
          dailyThoughtCountsIndexed[6 - i] = 0; // Map to 0-6 index
          dayLabels.add(_formatDateToShortDay(date));
        }

        // Populate counts
        for (var log in logs) {
          final int daysAgo = DateTime.now().difference(log.dateLogged).inDays;
          if (daysAgo >= 0 && daysAgo < 7) {
            dailyThoughtCountsIndexed[6 - daysAgo] = (dailyThoughtCountsIndexed[6 - daysAgo] ?? 0) + 1;
          }
        }

        final List<FlSpot> spots = dailyThoughtCountsIndexed.entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
            .toList();

        // Determine max Y value for the chart
        double maxYValue = 0;
        if (dailyThoughtCountsIndexed.values.isNotEmpty) {
          maxYValue = dailyThoughtCountsIndexed.values.reduce((a, b) => a > b ? a : b).toDouble();
        }
        // Ensure maxY is at least 1.0 if all values are 0 or empty, and add a buffer
        maxYValue = (maxYValue == 0 ? 1.0 : maxYValue * 1.2);


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
                        'Insights at a Glance',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Total Thoughts Logged: ${logs.length}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Most Frequent Distortion: ${mostFrequentDistortion.isNotEmpty ? mostFrequentDistortion : 'N/A'}',
                        style: Theme.of(context).textTheme.bodyLarge,
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
                        'Thoughts Logged Per Day (Last 7 Days)',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200, // Fixed height for the chart
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false), // FIX: show instead of showTitles
                            titlesData: FlTitlesData(
                              show: true,
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true, // FIX: showTitles is here
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    // Only show integer labels for Y-axis
                                    if (value.toInt().toDouble() == value) {
                                      return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // FIX: Use SideTitles
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // FIX: Use SideTitles
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true, // FIX: showTitles is here
                                  reservedSize: 30, // FIX: reservedSize is here
                                  interval: 1, // FIX: interval is here
                                  getTitlesWidget: (value, meta) { // FIX: getTitlesWidget is here
                                    // Ensure value (index) is within bounds of dayLabels
                                    if (value.toInt() >= 0 && value.toInt() < dayLabels.length) {
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        space: 8.0,
                                        child: Text(dayLabels[value.toInt()], style: const TextStyle(fontSize: 10)),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: const Color(0xff37434d), width: 1),
                            ),
                            minX: 0,
                            maxX: 6, // 7 days (0-6)
                            minY: 0,
                            maxY: maxYValue, // Use calculated max Y
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary.withAlpha(255 * 50 ~/ 100), // FIX: withOpacity replaced
                                    Theme.of(context).colorScheme.primary,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: true), // FIX: added const
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary.withAlpha(255 * 30 ~/ 100), // FIX: withOpacity replaced
                                      Theme.of(context).colorScheme.primary.withAlpha(0), // FIX: withOpacity replaced
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

  String _formatDateToShortDay(DateTime date) {
    final now = DateTime.now();
    // Compare dates only, ignoring time
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);


    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yest.'; // Shorter for yesterday
    }
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
  }
}