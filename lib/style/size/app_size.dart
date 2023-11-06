import 'package:responsive_sizer/responsive_sizer.dart';

class AppSize {
  static AppSize? _i;
  AppSize._() {
    _i ??= this;
  }
  factory AppSize() => _i ?? AppSize._();
  static double get elevation => 0.5.w;
  static double get margin => 0.5.w;

  static double get padding => 0.5.w;

  static double get icon => 1.w;
}
