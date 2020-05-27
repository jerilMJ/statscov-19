import 'package:flutter/material.dart';
import 'package:statscov/utils/exceptions.dart';
import 'package:statscov/utils/tutorial_utils.dart';
import 'package:tutorial_coach_mark/content_target.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/target_position.dart';

class CompareScreenTutorialTargets {
  CompareScreenTutorialTargets() {
    _tutorialUtils = TutorialUtils();
  }

  TutorialUtils _tutorialUtils;

  List<TargetFocus> getTutorialZeroTargets(
    GlobalKey searchOption,
    GlobalKey tabOne,
    GlobalKey tabTwo,
    GlobalKey tabThree,
  ) {
    try {
      return [
        _tutorialUtils.createTargetWithKey(
          searchOption,
          'Adding countries',
          'Tap on this icon to add countries to your graph. You can select a '
              'maximum of 16 countries from the list.',
        ),
        _tutorialUtils.createTargetWithKey(
          tabOne,
          '',
          'Compare based on total amount of confirmed cases here.',
        ),
        _tutorialUtils.createTargetWithKey(
          tabTwo,
          '',
          'Compare based on percentage of recovered cases here.',
        ),
        _tutorialUtils.createTargetWithKey(
          tabThree,
          '',
          'Compare based on percentage of deaths here.',
        ),
      ];
    } catch (e) {
      throw e;
    }
  }

  List<TargetFocus> getTutorialOneTargets(
      GlobalKey graphIndicator, GlobalKey popup) {
    if (graphIndicator.currentContext == null) {
      throw const WidgetNotBuiltYetException();
    }
    try {
      var width = popup.currentContext.size.width;
      var height = popup.currentContext.size.height;
      return [
        _tutorialUtils.createTargetWithKey(
          graphIndicator,
          'Graph Controls',
          'These are not only for indicating graph lines. They can also be used to control the plots on the graph.',
          alignment: AlignContent.top,
        ),
        _tutorialUtils.createTargetWithKey(
          graphIndicator,
          'Disable Plot',
          'Tap on the control to disable the plot of a country temporarily.',
          alignment: AlignContent.top,
        ),
        _tutorialUtils.createTargetWithPosition(
          TargetPosition(Size(height / 3, height / 3),
              Offset(width * 6, height - height / 3)),
          'Pin/Remove Plot',
          'Drag the control and drop it into the popup menu options to either pin that country or remove it.',
          alignment: AlignContent.top,
        ),
      ];
    } catch (e) {
      throw e;
    }
  }
}
