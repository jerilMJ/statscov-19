import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statscov/models/abstracts/screen_tutorial.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/screens/worldwide_screen/utils/worldwide_screen_tutorial_targets.dart';
import 'package:statscov/utils/exceptions.dart';
import 'package:statscov/utils/tutorial_utils.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class WorldwideScreenTutorial implements ScreenTutorial {
  WorldwideScreenTutorial(this._context, this._tabController) {
    tutorialFinished = true;
    tutorialProvider = Provider.of<TutorialProvider>(_context, listen: false);
    _initKeys();
  }

  BuildContext _context;
  TabController _tabController;
  TutorialUtils _tutorialUtils = TutorialUtils();
  TutorialProvider tutorialProvider;
  bool tutorialFinished;
  WorldwideScreenTutorialTargets _worldwideScreenTutorialTargets =
      WorldwideScreenTutorialTargets();

  void _initKeys() {
    [
      "flipCard",
      "stackedBarCard",
      "topCountriesPlayerCard",
      "playPause",
      "fastForward",
      "reset",
      "dateControls",
      "dataCurveCard",
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

    await Future.delayed(const Duration(milliseconds: 300), () {});
    try {
      switch (tutorialNumber) {
        case 0:
          showTutorialZero();
          break;
        case 1:
          showTutorialOne();
          break;
        case 2:
          showTutorialTwo();
          break;
        case 3:
          showTutorialThree();
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

  void showTutorialZero() async {
    try {
      List<TargetFocus> tutorialZeroTargets =
          _worldwideScreenTutorialTargets.getTutorialZeroTargets(
        tutorialProvider.getKeyFor("flipCard"),
      );

      _tabController.animateTo(0);
      _tutorialUtils.showCoachMark(
        context: _context,
        finish: () {
          tutorialFinished = true;
          tutorialProvider.removeTutorial(0);
        },
        targets: tutorialZeroTargets,
        clickTarget: (focus) {
          var key = focus.keyTarget;
          if (key == tutorialProvider.getKeyFor("flipCard")) {
            tutorialProvider.getStateFunctionFor("flipCard")();
          }
        },
      );
    } catch (e) {
      throw e;
    }
  }

  void showTutorialOne() async {
    try {
      List<TargetFocus> tutorialOneTargets =
          _worldwideScreenTutorialTargets.getTutorialOneTargets(
        tutorialProvider.getKeyFor("dataCurveCard"),
      );

      _tabController.animateTo(1);
      _tutorialUtils.showCoachMark(
        context: _context,
        finish: () {
          tutorialFinished = true;
          tutorialProvider.removeTutorial(1);
        },
        targets: tutorialOneTargets,
      );
    } catch (e) {
      throw e;
    }
  }

  void showTutorialTwo() async {
    try {
      List<TargetFocus> tutorialTwoTargets =
          _worldwideScreenTutorialTargets.getTutorialTwoTargets(
        tutorialProvider.getKeyFor("stackedBarCard"),
      );

      _tabController.animateTo(2);
      _tutorialUtils.showCoachMark(
        context: _context,
        finish: () {
          tutorialFinished = true;
          tutorialProvider.removeTutorial(2);
        },
        targets: tutorialTwoTargets,
      );
    } catch (e) {
      throw e;
    }
  }

  void showTutorialThree() async {
    try {
      List<TargetFocus> tutorialThreeTargets =
          _worldwideScreenTutorialTargets.getTutorialThreeTargets(
        tutorialProvider.getKeyFor("topCountriesPlayerCard"),
        tutorialProvider.getKeyFor("playPause"),
        tutorialProvider.getKeyFor("fastForward"),
        tutorialProvider.getKeyFor("reset"),
        tutorialProvider.getKeyFor("dateControls"),
      );

      _tabController.animateTo(3);
      _tutorialUtils.showCoachMark(
        context: _context,
        finish: () {
          tutorialFinished = true;
          tutorialProvider.removeTutorial(3);
        },
        targets: tutorialThreeTargets,
        alignSkip: Alignment.topLeft,
      );
    } catch (e) {
      throw e;
    }
  }
}
