import 'package:flutter/material.dart';
import 'package:statscov/utils/tutorial_utils.dart';
import 'package:tutorial_coach_mark/content_target.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/target_position.dart';

class WorldwideScreenTutorialTargets {
  TutorialUtils _tutorialUtils;

  WorldwideScreenTutorialTargets() {
    _tutorialUtils = TutorialUtils();
  }

  List<TargetFocus> getTutorialZeroTargets(
    GlobalKey flipCard,
  ) {
    try {
      return [
        _tutorialUtils.createTargetWithKey(
          flipCard,
          'Flippable cards',
          'Tap on the cards with this design to flip them over.',
        ),
      ];
    } catch (e) {
      throw e;
    }
  }

  List<TargetFocus> getTutorialOneTargets(
    GlobalKey dataCurveCard,
  ) {
    try {
      var cardSize = dataCurveCard.currentContext.size;

      return [
        _tutorialUtils.createTargetWithPosition(
          TargetPosition(
            Size(cardSize.width / 2, cardSize.width / 2),
            Offset(
                cardSize.width / 2 - cardSize.width / 4, cardSize.height / 2),
          ),
          'The curve',
          'Use the slider to adjust the smoothness of the curve.',
          alignment: AlignContent.top,
        ),
      ];
    } catch (e) {
      throw e;
    }
  }

  List<TargetFocus> getTutorialTwoTargets(
    GlobalKey stackedBarCard,
  ) {
    try {
      var cardSize = stackedBarCard.currentContext.size;

      return [
        _tutorialUtils.createTargetWithPosition(
          TargetPosition(
            Size(cardSize.width / 2, cardSize.width / 2),
            Offset(
                cardSize.width / 2 - cardSize.width / 4, cardSize.height / 2),
          ),
          'Proportions of cases',
          'Countries are ordered by the most amount of confirmed cases. Click on the button to see an expanded list.',
          alignment: AlignContent.top,
        ),
      ];
    } catch (e) {
      throw e;
    }
  }

  List<TargetFocus> getTutorialThreeTargets(
    GlobalKey topCountriesPlayerCard,
    GlobalKey playPause,
    GlobalKey fastForward,
    GlobalKey reset,
    GlobalKey dateControls,
  ) {
    try {
      var cardSize = topCountriesPlayerCard.currentContext.size;

      return [
        _tutorialUtils.createTargetWithPosition(
          TargetPosition(
            Size(cardSize.width / 2, cardSize.width / 2),
            Offset(
                cardSize.width / 2 - cardSize.width / 4, cardSize.height / 2),
          ),
          'The race',
          'Countries are ordered by the most amount of confirmed cases each day. '
              'Start the player to make the chart go live.',
          alignment: AlignContent.top,
        ),
        _tutorialUtils.createTargetWithKey(
          playPause,
          'Play/Pause',
          'Tap on this button to play/pause the race.',
          alignment: AlignContent.top,
        ),
        _tutorialUtils.createTargetWithKey(
          fastForward,
          'Fast Forward',
          'Go to the last slide with this button.',
          alignment: AlignContent.top,
        ),
        _tutorialUtils.createTargetWithKey(
          reset,
          'Reset',
          'Reset the race using this button.',
          alignment: AlignContent.top,
        ),
        _tutorialUtils.createTargetWithKey(
          dateControls,
          'Date chooser',
          'Choose a specific date from here',
          alignment: AlignContent.top,
        ),
      ];
    } catch (e) {
      throw e;
    }
  }
}
