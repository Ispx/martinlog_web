extension StringExt on String {
  String getDigits() {
    var exp = RegExp(r'[0-9]');
    var matches = exp.allMatches(this);
    var digits = matches.map((e) => e[0]).join("");
    return digits;
  }

  T parseToType<T>() {
    return switch (T) {
      String => this,
      bool => bool.parse(this),
      double => double.parse(this),
      int => int.parse(this),
      dynamic => this as dynamic,
      _ => this,
    };
  }

  DateTime? parseToDateTime() {
    return DateTime.tryParse(this);
  }
}
