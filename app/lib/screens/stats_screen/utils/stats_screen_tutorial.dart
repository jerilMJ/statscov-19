import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statscov/models/abstracts/screen_tutorial.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/screens/stats_screen/utils/stats_screen_tutorial_targets.dart';
import 'package:statscov/utils/exceptions.dart';
import 'package:statscov/utils/tutorial_utils.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class StatsScreenTutorial implements ScreenTutorial {
  StatsScreenTutorial(this._context, this._tabController) {
    tutorialFinished = true;
    _tutorialProvider = Provider.of<TutorialProvider>(_context, listen: false);
    _initKeys();
  }

  BuildContext _context;
  TabController _tabController;
  TutorialProvider _tutorialProvider;
  bool tutorialFinished;
  StatsScreenTutorialTargets _statsScreenTutorialTargets =
      StatsScreenTutorialTargets();
  TutorialUtils _tutorialUtils = TutorialUtils();

  void _initKeys() {
    [
      "searchOption",
      "tabOne",
      "tabTwo",
      "tabThree",
      "numberCards",
      "flipCard",
      "barChartCards",
      "dataCurves",
    ].forEach((name) {
      _tutorialProvider.addKey(name, GlobalKey());
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
    _tutorialProvider.addTutorial(tutorialNumber);
    await _tutorialProvider.waitUntilAtFront(tutorialNumber);

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
      _tutorialProvider.removeTutorial(tutorialNumber);
      throw const WidgetNotBuiltYetException();
    }
  }

  void showTutorialZero() {
    try {
      _tabController.animateTo(0);

      List<TargetFocus> tutorialZeroTargets =
          _statsScreenTutorialTargets.getTutorialZeroTargets(
        _tutorialProvider.getKeyFor("searchOption"),
        _tutorialProvider.getKeyFor("tabOne"),
        _tutorialProvider.getKeyFor("tabTwo"),
        _tutorialProvider.getKeyFor("tabThree"),
      );

      _tutorialUtils.showCoachMark(
        context: _context,
        targets: tutorialZeroTargets,
        clickTarget: (focus) {
          var key = focus.keyTarget;
          if (key == _tutorialProvider.getKeyFor("tabOne")) {
            _tabController.animateTo(1);
          } else if (key == _tutorialProvider.getKeyFor("tabTwo")) {
            _tabController.animateTo(2);
          }
        },
        finish: () {
          tutorialFinished = true;
          _tutorialProvider.removeTutorial(0);
        },
      );
    } catch (e) {
      throw e;
    }
  }

  void showTutorialOne() {
    try {
      _tabController.animateTo(0);

      List<TargetFocus> tutorialOneTargets =
          _statsScreenTutorialTargets.getTutorialOneTargets(
        _tutorialProvider.getKeyFor("numberCards"),
        _tutorialProvider.getKeyFor("flipCard"),
      );

      _tutorialUtils.showCoachMark(
        context: _context,
        finish: () {
          tutorialFinished = true;
          _tutorialProvider.removeTutorial(1);
        },
        clickTarget: (focus) {
          var key = focus.keyTarget;
          if (key == _tutorialProvider.getKeyFor("flipCard")) {
            _tutorialProvider.getStateFunctionFor("flipCard")();
          }
        },
        targets: tutorialOneTargets,
      );
    } catch (e) {
      throw e;
    }
  }

  void showTutorialTwo() {
    try {
      _tabController.animateTo(1);

      List<TargetFocus> tutorialTwoTargets =
          _statsScreenTutorialTargets.getTutorialTwoTargets(
        _tutorialProvider.getKeyFor("barChartCards"),
      );

      _tutorialUtils.showCoachMark(
        context: _context,
        finish: () {
          tutorialFinished = true;
          _tutorialProvider.removeTutorial(2);
        },
        targets: tutorialTwoTargets,
      );
    } catch (e) {
      throw e;
    }
  }

  void showTutorialThree() {
    try {
      _tabController.animateTo(2);

      List<TargetFocus> tutorialThreeTargets =
          _statsScreenTutorialTargets.getTutorialThreeTargets(
        _tutorialProvider.getKeyFor("dataCurves"),
      );

      _tutorialUtils.showCoachMark(
        context: _context,
        finish: () {
          tutorialFinished = true;
          _tutorialProvider.removeTutorial(3);
        },
        targets: tutorialThreeTargets,
      );
    } catch (e) {
      throw e;
    }
  }
}
