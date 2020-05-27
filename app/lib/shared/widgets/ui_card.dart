import 'package:flutter/material.dart';
import 'package:statscov/utils/constants.dart';

class UiCard extends StatelessWidget {
  UiCard({
    @required this.child,
    this.padding = const EdgeInsets.all(15.0),
    this.margin = const EdgeInsets.all(10.0),
    this.elevation = 5.0,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final EdgeInsetsGeometry margin;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Card(
        elevation: elevation,
        color: color ?? AppConstants.of(context).kDarkElevations[0],
        margin: margin,
        child: Center(
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
