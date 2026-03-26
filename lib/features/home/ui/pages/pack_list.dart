import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:tawakad_app/features/home/ui/widgets/pack_list_card_theme.dart';

const uuid = Uuid();
final formatter = DateFormat.Hm();

class PackList {
  PackList({
    required this.title,
    required this.itemCount,
    required this.date,
    PackListCardTheme? cardTheme,
  })  : id = uuid.v4(),
        cardTheme = cardTheme ?? PackListCardTheme.purple;

  final String id;
  final String title;
  final int itemCount;
  final DateTime date;
  final PackListCardTheme cardTheme;

  String get formattedDate => formatter.format(date);
}
