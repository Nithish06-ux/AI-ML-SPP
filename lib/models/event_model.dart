import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventId;
  final String title;
  final String description;
  final DateTime date;
  final String venue;
  final String createdBy;
  final String qrCodeValue;

  const EventModel({
    required this.eventId,
    required this.title,
    required this.description,
    required this.date,
    required this.venue,
    required this.createdBy,
    required this.qrCodeValue,
  });

  factory EventModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return EventModel(
      eventId: data['eventId'] as String? ?? doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      venue: data['venue'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      qrCodeValue: data['qrCodeValue'] as String? ?? doc.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'venue': venue,
      'createdBy': createdBy,
      'qrCodeValue': qrCodeValue,
    };
  }
}
