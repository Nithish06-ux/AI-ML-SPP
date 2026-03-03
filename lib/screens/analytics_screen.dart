import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event_model.dart';
import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.read<AttendanceProvider>();
    final eventProvider = context.read<EventProvider>();
    final user = context.read<AuthProvider>().currentUser;
    final eventArg = ModalRoute.of(context)?.settings.arguments;

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Analytics')),
      body: FutureBuilder<List<double>>(
        future: _loadAnalytics(
          attendanceProvider: attendanceProvider,
          eventProvider: eventProvider,
          userId: user?.uid,
          eventArg: eventArg,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? [0, 100];
          return Center(
            child: SizedBox(
              width: 340,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 52,
                  sections: [
                    PieChartSectionData(
                      value: data[0],
                      title: '${data[0].toStringAsFixed(1)}%\nPresent',
                      radius: 110,
                      color: Colors.green,
                      titleStyle: const TextStyle(color: Colors.white),
                    ),
                    PieChartSectionData(
                      value: data[1],
                      title: '${data[1].toStringAsFixed(1)}%\nAbsent',
                      radius: 110,
                      color: Colors.redAccent,
                      titleStyle: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<double>> _loadAnalytics({
    required AttendanceProvider attendanceProvider,
    required EventProvider eventProvider,
    required String? userId,
    required Object? eventArg,
  }) async {
    if (eventArg is EventModel) {
      // Admin event-level analytics.
      final users = await eventProvider.getRegisteredStudents(eventArg.eventId);
      final totalStudents = users.length;
      final presentPercent = await attendanceProvider.getEventAttendancePercentage(
        eventId: eventArg.eventId,
        totalStudents: totalStudents,
      );
      final absent = (100 - presentPercent).clamp(0, 100);
      return [presentPercent, absent];
    }

    // Student overall analytics.
    if (userId == null) return [0, 100];
    final events = await eventProvider.upcomingEvents.first;
    final presentPercent = await attendanceProvider.getAttendancePercentage(
      studentId: userId,
      totalEvents: events.length,
    );
    final absent = (100 - presentPercent).clamp(0, 100);
    return [presentPercent, absent];
  }
}
