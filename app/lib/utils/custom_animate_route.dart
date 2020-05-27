import 'package:flutter/material.dart';
import 'package:statscov/utils/constants.dart';

class CustomAnimateRoute extends PageRouteBuilder {
  final Widget enterPage;
  final Widget exitPage;
  CustomAnimateRoute(
      {this.exitPage, this.enterPage, Curve curve = Curves.easeIn})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              enterPage,
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final exitAnim = Tween(
                    begin: const Offset(0.0, 0.0), end: const Offset(0.0, 1.0))
                .animate(CurvedAnimation(parent: animation, curve: curve));
            final enterAnim = Tween(
                    begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0))
                .animate(CurvedAnimation(parent: animation, curve: curve));

            return Container(
              color: AppConstants.of(context).kSurfaceColor,
              child: Stack(
                children: <Widget>[
                  SlideTransition(position: exitAnim, child: exitPage),
                  SlideTransition(position: enterAnim, child: enterPage),
                ],
              ),
            );
          },
        );
}
