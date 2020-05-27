import 'package:intl/intl.dart';

class DateUtils {
  final DateFormat dateFormat1 = DateFormat('yyyy-MM-dd');
  final DateFormat dateFormat2 = DateFormat('dd MMM yyyy');

  String toDateOnlyString(DateTime dateTime) {
    return dateFormat1.format(dateTime);
  }

  String prettifyDate(DateTime dateTime) {
    return dateFormat2.format(dateTime);
  }
}
