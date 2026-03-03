import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<List<EventModel>> get upcomingEvents => _eventService.getUpcomingEvents();

  Future<bool> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required String venue,
    required String createdBy,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      await _eventService.createEvent(
        title: title,
        description: description,
        date: date,
        venue: venue,
        createdBy: createdBy,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateEvent(EventModel event) async {
    _setLoading(true);
    _error = null;
    try {
      await _eventService.updateEvent(event);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    _setLoading(true);
    _error = null;
    try {
      await _eventService.deleteEvent(eventId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<AppUser>> getRegisteredStudents(String eventId) {
    return _eventService.getRegisteredStudents(eventId);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
