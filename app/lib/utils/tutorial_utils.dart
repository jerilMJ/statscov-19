import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/content_target.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/target_position.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialUtils {
  final kTitleColor = const Color(0xffFFFFFF).withOpacity(0.87);
  final kTextColor = const Color(0xffFFFFFF).withOpacity(0.60);

  TargetFocus createTargetWithKey(
      GlobalKey keyTarget, String title, String description,
      {AlignContent alignment = AlignContent.bottom,
      ShapeLightFocus shape = ShapeLightFocus.Circle}) {
    return TargetFocus(
      identify: title,
      shape: shape,
      keyTarget: keyTarget,
      contents: [
        ContentTarget(
          align: alignment,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kTitleColor,
                    fontSize: 20.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    description,
                    style: TextStyle(color: kTextColor),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  TargetFocus createTargetWithPosition(
      TargetPosition targetPosition, String title, String description,
      {AlignContent alignment = AlignContent.bottom,
      ShapeLightFocus shape = ShapeLightFocus.Circle}) {
    return TargetFocus(
      identify: title,
      shape: shape,
      targetPosition: targetPosition,
      contents: [
        ContentTarget(
          align: alignment,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kTitleColor,
                    fontSize: 20.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    description,
                    style: TextStyle(color: kTextColor),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  void showCoachMark({
    @required BuildContext context,
    @required Function finish,
    @required List<TargetFocus> targets,
    AlignmentGeometry alignSkip = Alignment.bottomRight,
    Function clickTarget,
  }) {
    TutorialCoachMark(
      context,
      targets: targets,
      paddingFocus: 0.0,
      colorShadow: Colors.blueGrey.shade900,
      opacityShadow: 0.9,
      clickTarget: clickTarget,
      alignSkip: alignSkip,
      finish: finish,
    )..show();
  }
}
