import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required String venue,
    required String createdBy,
  }) async {
    final docRef = _firestore.collection('events').doc();

    final event = EventModel(
      eventId: docRef.id,
      title: title.trim(),
      description: description.trim(),
      date: date,
      venue: venue.trim(),
      createdBy: createdBy,
      qrCodeValue: docRef.id,
    );

    await docRef.set(event.toMap());
  }

  Stream<List<EventModel>> getUpcomingEvents() {
    return _firestore
        .collection('events')
        .orderBy('date')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  Future<void> updateEvent(EventModel event) async {
    await _firestore.collection('events').doc(event.eventId).update(event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    final batch = _firestore.batch();
    batch.delete(_firestore.collection('events').doc(eventId));

    final attendanceDocs = await _firestore
        .collection('attendance')
        .where('eventId', isEqualTo: eventId)
        .get();
    for (final doc in attendanceDocs.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<List<AppUser>> getRegisteredStudents(String eventId) async {
    // Example query: all attendance entries for an event, then fetch each user profile.
    final attendanceSnapshot = await _firestore
        .collection('attendance')
        .where('eventId', isEqualTo: eventId)
        .get();

    final studentIds = attendanceSnapshot.docs
        .map((doc) => doc.data()['studentId'] as String?)
        .whereType<String>()
        .toSet();

    if (studentIds.isEmpty) return [];

    final usersSnapshot = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: studentIds.toList())
        .get();

    return usersSnapshot.docs.map(AppUser.fromFirestore).toList();
  }
}
