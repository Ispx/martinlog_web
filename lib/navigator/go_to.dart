import 'package:flutter/material.dart';

class GoTo {
  static final GoTo _i = GoTo._();
  factory GoTo() => _i;
  GoTo._();
  Object? arguments;
  static final _navigatorState = GlobalKey<NavigatorState>();

  static Future<T?> goTo<T>(String routeName, {Object? arguments}) async =>
      _navigatorState.currentState?.pushNamed(routeName, arguments: arguments);
  static void pop<T>([T? result]) async =>
      _navigatorState.currentState?.pop(result);
  static Future<T?> removeAllAndGoTo<T>(String routeName,
          {Object? arguments}) async =>
      _navigatorState.currentState?.pushNamedAndRemoveUntil(
        routeName,
        (e) => false,
        arguments: arguments,
      );
  static Future<T?> removeAllPreviousAndGoTo<T>(String routeName,
          {Object? arguments}) async =>
      _navigatorState.currentState?.pushNamedAndRemoveUntil(
        routeName,
        (e) => false,
        arguments: arguments,
      );

  void setArguments(Object? arguments) => this.arguments = arguments;

  static Future<T?> replaceAndGoTo<T>(String routeName,
          {Object? arguments}) async =>
      _navigatorState.currentState?.pushReplacementNamed(
        routeName,
        arguments: arguments,
      );

  static GlobalKey<NavigatorState> get navigatorState => _navigatorState;
}
