import 'package:flutter/material.dart';

class AppConstants extends InheritedWidget {
  static AppConstants of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppConstants>();

  AppConstants({Widget child, Key key}) : super(key: key, child: child);

  final Color kDarkPrimary = Colors.black;
  final Color kDarkSecondary = Colors.grey.shade900;
  final Color kDarkTertiary = Colors.grey.shade800;
  final Color kPrimaryOne = Colors.purple.shade700;
  final Color kPrimaryTwo = Colors.purple.shade500;
  final Color kPrimaryThree = Colors.purple.shade300;
  final Color kSecondaryOne = Color(0xffab003c);
  final Color kSecondaryTwo = Color(0xfff50057);
  final Color kSecondaryThree = Color(0xfff73378);

  final Color kTextPrimary = Colors.grey.shade300;
  final Color kTextSecondary = Colors.grey;

  final Color kTextColor = Colors.white;

  @override
  bool updateShouldNotify(AppConstants oldWidget) => false;
}
