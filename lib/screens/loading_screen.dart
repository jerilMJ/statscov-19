import 'package:flutter/material.dart';
import 'package:statscov/utils/custom_icons.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:statscov/components/load_box.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              LoadBox(),
            ],
          ),
          Center(
            child: TyperAnimatedTextKit(
              text: [
                '.....',
              ],
              textStyle:
                  TextStyle(fontSize: MediaQuery.of(context).size.width / 10),
              speed: Duration(milliseconds: 200),
            ),
          )
        ],
      ),
    );
  }
}
