extension DateTimeExt on DateTime {
  static DateTime get toUtc => DateTime.now().toUtc();
  String yyyyMMdd() => "$year-$month-$day";
}
