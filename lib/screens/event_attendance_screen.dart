import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/attendance_model.dart';
import '../models/event_model.dart';
import '../providers/attendance_provider.dart';

class EventAttendanceScreen extends StatelessWidget {
  const EventAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final event = ModalRoute.of(context)!.settings.arguments as EventModel;
    final attendanceProvider = context.watch<AttendanceProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Attendance: ${event.title}')),
      body: StreamBuilder<List<AttendanceModel>>(
        stream: attendanceProvider.attendanceByEvent(event.eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return const Center(child: Text('No attendance records yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('Student ID: ${record.studentId}'),
                  subtitle: Text(
                    'Marked: ${DateFormat.yMMMd().add_jm().format(record.timestamp)}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
