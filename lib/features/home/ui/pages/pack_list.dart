import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

const uuid = Uuid();
final formatter = DateFormat.Hm();

class PackList {
  PackList({
    required this.title,
    required this.itemCount,
    required this.date,
  }) : id = uuid.v4();

  final String id;
  final String title;
  final int itemCount;
  final DateTime date;

  String get formattedDate {
    return formatter.format(date);
  }
}
