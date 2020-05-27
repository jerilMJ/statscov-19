import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statscov/models/abstracts/screen_tutorial.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/screens/map_screen/utils/map_screen_tutorial_targets.dart';
import 'package:statscov/utils/exceptions.dart';
import 'package:statscov/utils/tutorial_utils.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class MapScreenTutorial implements ScreenTutorial {
  MapScreenTutorial(this._context) {
    tutorialFinished = true;
    tutorialProvider = Provider.of<TutorialProvider>(_context, listen: false);
    _initKeys();
  }

  BuildContext _context;
  TutorialUtils _tutorialUtils = TutorialUtils();
  TutorialProvider tutorialProvider;
  bool tutorialFinished;
  MapScreenTutorialTargets _mapScreenTutorialTargets =
      MapScreenTutorialTargets();

  void _initKeys() {
    [
      'worldMap',
      'playPause',
      'lastEntry',
      'reset',
      'dateControls',
    ].forEach((name) {
      tutorialProvider.addKey(name, GlobalKey());
    });
  }

  void tutorialNotFinished() {
    tutorialFinished = false;
  }

  void tutorialIsFinished() {
    tutorialFinished = true;
  }

  Future<void> showTutorial(int tutorialNumber) async {
    tutorialFinished = false;
    tutorialProvider.addTutorial(tutorialNumber);
    await tutorialProvider.waitUntilAtFront(tutorialNumber);

    try {
      switch (tutorialNumber) {
        case 0:
          showTutorialZero();
          break;
        default:
          break;
      }
    } catch (e) {
      tutorialFinished = true;
      tutorialProvider.removeTutorial(tutorialNumber);
      throw const WidgetNotBuiltYetException();
    }
  }

  void showTutorialZero() {
    try {
      List<TargetFocus> tutorialZeroTargets =
          _mapScreenTutorialTargets.getTutorialZeroTargets(
        tutorialProvider.getKeyFor('worldMap'),
        tutorialProvider.getKeyFor('playPause'),
        tutorialProvider.getKeyFor('lastEntry'),
        tutorialProvider.getKeyFor('reset'),
        tutorialProvider.getKeyFor('dateControls'),
      );

      _tutorialUtils.showCoachMark(
        context: _context,
        finish: () {
          tutorialFinished = true;
          tutorialProvider.removeTutorial(0);
        },
        targets: tutorialZeroTargets,
        alignSkip: Alignment.topLeft,
      );
    } catch (e) {
      throw e;
    }
  }
}
