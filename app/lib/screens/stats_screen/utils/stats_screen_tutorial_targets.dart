import 'package:flutter/material.dart';
import 'package:statscov/utils/tutorial_utils.dart';
import 'package:tutorial_coach_mark/content_target.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/target_position.dart';

class StatsScreenTutorialTargets {
  TutorialUtils _tutorialUtils = TutorialUtils();

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
          'Select a country',
          'Tap this button to select a country from the search menu and view its statistics.',
        ),
        _tutorialUtils.createTargetWithKey(
          tabOne,
          'Straight up numbers',
          'View all the significant data for the selected country here.',
        ),
        _tutorialUtils.createTargetWithKey(
          tabTwo,
          'Visualize with bar-charts',
          'View the data in the form of bar-charts here.',
        ),
        _tutorialUtils.createTargetWithKey(
          tabThree,
          'Visualize with timeseries',
          'This tab shows all the data in timeseries format.',
        ),
      ];
    } catch (e) {
      throw e;
    }
  }

  List<TargetFocus> getTutorialOneTargets(
    GlobalKey numberCards,
    GlobalKey flipCard,
  ) {
    try {
      var cardSize = numberCards.currentContext.size;

      return [
        _tutorialUtils.createTargetWithPosition(
            TargetPosition(
              Size(cardSize.width / 2, cardSize.width / 2),
              Offset(
                  cardSize.width / 2 - cardSize.width / 4, cardSize.height / 2),
            ),
            'Just numbers',
            'These cards show the last updated data on the country you chose.'),
        _tutorialUtils.createTargetWithKey(
          flipCard,
          'Flippable cards',
          'Tap on the cards with this design to flip them over and see what is on the back.',
        ),
      ];
    } catch (e) {
      throw e;
    }
  }

  List<TargetFocus> getTutorialTwoTargets(
    GlobalKey barChartCards,
  ) {
    try {
      var cardSize = barChartCards.currentContext.size;

      return [
        _tutorialUtils.createTargetWithPosition(
          TargetPosition(
            Size(cardSize.width / 2, cardSize.width / 2),
            Offset(
                cardSize.width / 2 - cardSize.width / 4, cardSize.height / 2),
          ),
          'Bar-charts',
          'This is a slideable carousel. Swipe vertically to jump from one carousel to another.',
        ),
      ];
    } catch (e) {
      throw e;
    }
  }

  List<TargetFocus> getTutorialThreeTargets(
    GlobalKey dataCurves,
  ) {
    try {
      var cardSize = dataCurves.currentContext.size;

      return [
        _tutorialUtils.createTargetWithPosition(
          TargetPosition(
            Size(cardSize.width / 2, cardSize.width / 2),
            Offset(
                cardSize.width / 2 - cardSize.width / 4, cardSize.height / 1.5),
          ),
          'Timeseries',
          'The first graph shows the cases which are confirmed (blue), recovered (green) and the cases of death (red).'
              '\nThe second graph shows the progression of individual daily cases (teal)'
              'starting from the date of the first confirmed case.',
          alignment: AlignContent.top,
        ),
      ];
    } catch (e) {
      throw e;
    }
  }
}
