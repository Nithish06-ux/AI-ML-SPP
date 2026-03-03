import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/event_model.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../utils/app_routes.dart';
import '../widgets/qr_generator_widget.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.createEvent),
            icon: const Icon(Icons.add),
            tooltip: 'Create Event',
          ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: eventProvider.upcomingEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return const Center(child: Text('No events found. Create one now.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(event.title),
                  subtitle: Text(
                    '${DateFormat.yMMMd().add_jm().format(event.date)} • ${event.venue}',
                  ),
                  childrenPadding: const EdgeInsets.all(16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(event.description),
                    ),
                    const SizedBox(height: 12),
                    QrGeneratorWidget(qrData: event.qrCodeValue),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.eventAttendance,
                            arguments: event,
                          ),
                          icon: const Icon(Icons.fact_check),
                          label: const Text('Attendance'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.analytics,
                            arguments: event,
                          ),
                          icon: const Icon(Icons.pie_chart_outline),
                          label: const Text('Analytics'),
                        ),
                        IconButton(
                          onPressed: () => _showEditDialog(context, event),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () async {
                            final success = await context
                                .read<EventProvider>()
                                .deleteEvent(event.eventId);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Event deleted'
                                      : eventProvider.error ?? 'Delete failed',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: authProvider.currentUser == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.createEvent),
              icon: const Icon(Icons.add),
              label: const Text('New Event'),
            ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, EventModel event) async {
    final titleController = TextEditingController(text: event.title);
    final descriptionController = TextEditingController(text: event.description);
    final venueController = TextEditingController(text: event.venue);

    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = event.date;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Event'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Required'
                            : null,
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Required'
                            : null,
                      ),
                      TextFormField(
                        controller: venueController,
                        decoration: const InputDecoration(labelText: 'Venue'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Date: ${DateFormat.yMMMd().add_jm().format(selectedDate)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                          );
                          if (date == null || !context.mounted) return;

                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedDate),
                          );
                          if (time == null) return;

                          setState(() {
                            selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final updated = EventModel(
                      eventId: event.eventId,
                      title: titleController.text,
                      description: descriptionController.text,
                      date: selectedDate,
                      venue: venueController.text,
                      createdBy: event.createdBy,
                      qrCodeValue: event.qrCodeValue,
                    );
                    final success = await context
                        .read<EventProvider>()
                        .updateEvent(updated);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Event updated' : 'Update failed'),
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
