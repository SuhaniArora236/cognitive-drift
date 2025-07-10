import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/thought_log.dart';

class ThoughtHistoryScreen extends StatelessWidget {
  const ThoughtHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<ThoughtLog>('thoughtLogs').listenable(),
      builder: (context, Box<ThoughtLog> box, _) {
        if (box.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off, size: 80, color: Colors.grey),
                SizedBox(height: 20),
                Text(
                  'No thoughts logged yet.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final List<ThoughtLog> sortedLogs = box.values.toList()
          ..sort((a, b) => b.dateLogged.compareTo(a.dateLogged)); // Sort by newest first

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: sortedLogs.length,
          itemBuilder: (context, index) {
            final log = sortedLogs[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.1).round()), // FIX: Removed 'alpha:' named argument
                  child: Icon(Icons.psychology, color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(
                  log.automaticThought,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Distortion: ${log.distortionType}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Emotion: ${log.emotion} (Intensity: ${log.intensity}/10)',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Logged: ${log.formattedDate}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                onTap: () async { // Make onTap async because of showDialog and delete logic
                  // Navigate to a detail screen if needed
                  await showDialog( // Wait for dialog to close
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Thought Detail: ${log.formattedDate}'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('Trigger: ${log.trigger}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('Automatic Thought: ${log.automaticThought}'),
                              const SizedBox(height: 8),
                              Text('Distortion Type: ${log.distortionType}'),
                              const SizedBox(height: 8),
                              Text('Emotion: ${log.emotion} (Intensity: ${log.intensity}/10)'),
                              const SizedBox(height: 8),
                              if (log.reframe != null && log.reframe!.isNotEmpty)
                                Text('Reframe: ${log.reframe}'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            onPressed: () async {
                              if (!context.mounted) return; // Mounted check before pop
                              Navigator.of(context).pop(); // Close detail dialog first

                              final bool? confirmDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Deletion'),
                                  content: const Text('Are you sure you want to delete this thought?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        if (!context.mounted) return; // Mounted check
                                        Navigator.pop(context, false);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (!context.mounted) return; // Mounted check
                                        Navigator.pop(context, true);
                                      },
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmDelete == true) {
                                if (!context.mounted) return; // Mounted check before async operation
                                await log.delete(); // Delete using HiveObject's delete method
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Thought deleted.')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}