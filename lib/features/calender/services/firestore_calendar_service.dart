import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tawakad_app/features/calender/model/cloud_firestore.dart';


class FirestoreCalendarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String collection = 'calendar_events';

  String _dateKey(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> addEvent({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final event = CalendarEventModel(
      id: '',
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      dateKey: _dateKey(startTime),
    );

    await _firestore.collection(collection).add(event.toMap());
  }

  Stream<List<CalendarEventModel>> getEventsForDate(DateTime date) {
    final key = _dateKey(date);

    return _firestore
        .collection(collection)
        .where('dateKey', isEqualTo: key)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CalendarEventModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection(collection).doc(eventId).delete();
  }
}