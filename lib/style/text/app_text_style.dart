import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

abstract class AppTextStyle {
  static TextStyle displayLarge(BuildContext context) {
    return Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 14.sp);
  }

  static TextStyle displayMedium(BuildContext context) {
    return Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 12.sp);
  }

  static TextStyle displaySmall(BuildContext context) {
    return Theme.of(context).textTheme.displaySmall!.copyWith(fontSize: 10.sp);
  }

  static TextStyle mobileDisplayLarge(BuildContext context) {
    return Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 20.sp);
  }

  static TextStyle mobileDisplayMedium(BuildContext context) {
    return Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 16.sp);
  }

  static TextStyle mobileDisplaySmall(BuildContext context) {
    return Theme.of(context).textTheme.displaySmall!.copyWith(fontSize: 14.sp);
  }
}
