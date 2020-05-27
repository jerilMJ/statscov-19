import 'package:flutter/material.dart';
import 'package:statscov/utils/constants.dart';

class JumpAlert extends StatelessWidget {
  const JumpAlert({
    this.text = '',
    this.actionText = 'OK',
    Key key,
  }) : super(key: key);

  final String text;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.bounceInOut,
      child: AlertDialog(
        title: Column(
          children: <Widget>[
            Text(
              text,
              style: TextStyle(
                color: AppConstants.of(context).kTextWhite[1],
                fontSize: 15.0,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: MaterialButton(
                child: Text(
                  actionText,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
    );
  }
}
