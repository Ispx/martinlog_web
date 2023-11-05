import 'package:flutter/material.dart';

sealed class AppTheme {
  final ColorScheme colorScheme;
  ThemeData get themeData => ThemeData.from(
        colorScheme: colorScheme,
        useMaterial3: true,
      );
  AppTheme(this.colorScheme);
}

class DefaultAppTheme extends AppTheme {
  DefaultAppTheme() : super(const ColorScheme.light());
}
