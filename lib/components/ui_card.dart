import 'package:flutter/material.dart';
import 'package:statscov/utils/constants.dart';

class UiCard extends StatelessWidget {
  UiCard({@required this.child, this.padding = const EdgeInsets.all(0.0)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.all(20.0),
      color: AppConstants.of(context).kDarkSecondary,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
