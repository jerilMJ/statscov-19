import 'package:flutter/material.dart';
import 'package:statscov/utils/tutorial_utils.dart';
import 'package:tutorial_coach_mark/content_target.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/target_position.dart';

class MapScreenTutorialTargets {
  MapScreenTutorialTargets() {
    _tutorialUtils = TutorialUtils();
  }

  TutorialUtils _tutorialUtils;

  List<TargetFocus> getTutorialZeroTargets(
    GlobalKey worldMap,
    GlobalKey playPause,
    GlobalKey lastEntry,
    GlobalKey reset,
    GlobalKey dateControls,
  ) {
    try {
      var size = worldMap.currentContext.size;

      return [
        _tutorialUtils.createTargetWithPosition(
          TargetPosition(Size(size.width / 3, size.width / 3),
              Offset(size.width / 2 - size.width / 6, size.height / 2)),
          'World Map',
          'This is the map of the world with the markers indicating the countries affected by the pandemic.\n'
              'Tap the markers to bring up the appropriate details.\n'
              'You can also see how the pandemic spread by playing the slideshow.',
        ),
        _tutorialUtils.createTargetWithKey(
          playPause,
          'Play/Pause',
          'Tap on this button to play/pause the slideshow.',
          alignment: AlignContent.top,
        ),
        _tutorialUtils.createTargetWithKey(
          lastEntry,
          'Latest',
          'Go to the last entry with this button.',
          alignment: AlignContent.top,
        ),
        _tutorialUtils.createTargetWithKey(
          reset,
          'Reset',
          'Reset the slideshow using this button.',
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
