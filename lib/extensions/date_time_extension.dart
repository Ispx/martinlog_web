import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  static DateTime get toUtc => DateTime.now().toUtc();
  DateTime get toBrazillianHour => this.toUtc().subtract(const Duration(hours: 3));
  String get yyyyMMdd => "$year-$month-$day";
  String get ddMMyyyyHHmmss => DateFormat("dd/MM/yyyy HH:mm:ss").format(this);
  String get yyyyMMddyHHmmss => DateFormat("yyyy-MM-dd HH:mm:ss").format(this);
  String get ddMMyyyy => DateFormat("dd/MM/yyyy").format(this);
}
