import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/attendance_model.dart';
import '../models/event_model.dart';
import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../utils/app_routes.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            onPressed: () async {
              await authProvider.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: StreamBuilder<List<EventModel>>(
              stream: eventProvider.upcomingEvents,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final events = snapshot.data ?? [];
                if (events.isEmpty) {
                  return const Center(child: Text('No upcoming events.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(event.title),
                        subtitle: Text(
                          '${DateFormat.yMMMd().add_jm().format(event.date)} • ${event.venue}',
                        ),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final success = await context
                                    .read<AttendanceProvider>()
                                    .registerForEvent(
                                      eventId: event.eventId,
                                      studentId: user.uid,
                                    );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Attendance marked'
                                          : attendanceProvider.error ??
                                              'Unable to mark attendance',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Register'),
                            ),
                            OutlinedButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.qrScanner,
                                arguments: event,
                              ),
                              child: const Text('Scan QR'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AttendanceModel>>(
              stream: attendanceProvider.attendanceByStudent(user.uid),
              builder: (context, snapshot) {
                final records = snapshot.data ?? [];
                return Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Attendance History',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: records.length,
                            itemBuilder: (context, index) {
                              final record = records[index];
                              return ListTile(
                                dense: true,
                                title: Text('Event: ${record.eventId}'),
                                subtitle: Text(
                                  DateFormat.yMMMd().add_jm().format(
                                        record.timestamp,
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.analytics),
        icon: const Icon(Icons.bar_chart),
        label: const Text('My Analytics'),
      ),
    );
  }
}
