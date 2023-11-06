import 'package:flutter/material.dart';
import 'package:martinlog_web/style/theme/app_theme.dart';

extension BuildContextExtension on BuildContext {
  AppTheme get appTheme => Theme.of(this).extension<AppTheme>()!;
}
