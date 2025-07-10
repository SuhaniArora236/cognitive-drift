import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/thought_log.dart'; // To access the ThoughtLog box

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmClearData(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Data?'),
          content: const Text(
              'Are you sure you want to clear ALL logged thoughts and app data? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear Data'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await Hive.box<ThoughtLog>('thoughtLogs').clear();
      // Potentially clear other boxes like settingsBox if needed for a full reset
      // await Hive.box<bool>('settingsBox').clear(); // If you want to force re-onboarding

      if (context.mounted) { // Mounted check after async operation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Management',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Clear All Logged Data'),
                  subtitle: const Text('Deletes all your saved thoughts.'),
                  onTap: () => _confirmClearData(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text('Export Logs (CSV) - Optional'),
                  subtitle: const Text('Not implemented in MVP, but planned!'),
                  onTap: () {
                    // TODO: Implement CSV/PDF export
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export functionality coming soon!')),
                    );
                  },
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
                  'Reminders',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: const Text('Enable Daily Reminder'),
                  subtitle: const Text('Not implemented in MVP, but planned!'),
                  trailing: Switch(
                    value: false, // Placeholder
                    onChanged: (bool value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Daily reminders coming soon!')),
                      );
                      // TODO: Implement reminder logic using android_alarm_manager_plus or flutter_local_notifications
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}