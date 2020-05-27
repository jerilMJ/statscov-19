import 'package:flutter/material.dart';

class AppConstants extends InheritedWidget {
  AppConstants({Widget child, Key key}) : super(key: key, child: child);

  static AppConstants of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppConstants>();

  final String kAppTitle = 'StatsCOV-19';
  final Color kSurfaceColor = const Color(0xff121212);
  final Color kAccentColor = Colors.purple.shade200;
  final List<Color> kDarkElevations = [
    Colors.grey.shade900,
    Colors.grey.shade800,
    Colors.grey.shade700,
  ];

  final List<Color> kTextWhite = [
    const Color(0xffFFFFFF).withOpacity(0.87),
    const Color(0xffFFFFFF).withOpacity(0.60),
    const Color(0xffFFFFFF).withOpacity(0.38),
  ];

  final List<Color> kTextBlack = [
    const Color(0xff000000).withOpacity(0.87),
    const Color(0xff000000).withOpacity(0.60),
    const Color(0xff000000).withOpacity(0.38),
  ];

  final TextStyle kTitleTextStyle = TextStyle(
    fontSize: 15.0,
    color: const Color(0xffFFFFFF).withOpacity(0.38),
    fontWeight: FontWeight.bold,
  );

  final TextStyle kBigCounterTextStyle = TextStyle(
    fontSize: 40.0,
    color: const Color(0xffFFFFFF).withOpacity(0.87),
    fontWeight: FontWeight.bold,
  );

  final TextStyle kSmallCounterTextStyle = TextStyle(
    fontSize: 25.0,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  final TextStyle kDateTextStyle = TextStyle(
    fontSize: 15.0,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  @override
  bool updateShouldNotify(AppConstants oldWidget) => false;
}
