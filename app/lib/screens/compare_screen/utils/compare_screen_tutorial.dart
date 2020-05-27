import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statscov/models/abstracts/screen_tutorial.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/screens/compare_screen/utils/compare_screen_tutorial_targets.dart';
import 'package:statscov/utils/exceptions.dart';
import 'package:statscov/utils/tutorial_utils.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class CompareScreenTutorial implements ScreenTutorial {
  CompareScreenTutorial(this._context, this._tabController) {
    tutorialFinished = true;
    _tutorialProvider = Provider.of<TutorialProvider>(_context, listen: false);
    _initKeys();
  }

  BuildContext _context;
  TutorialProvider _tutorialProvider;
  bool tutorialFinished;
  TabController _tabController;
  TutorialUtils _tutorialUtils = TutorialUtils();
  CompareScreenTutorialTargets _compareScreenTutorialTargets =
      CompareScreenTutorialTargets();

  void tutorialNotFinished() {
    tutorialFinished = false;
  }

  void tutorialIsFinished() {
    tutorialFinished = true;
  }

  void _initKeys() {
    [
      "addOption",
      "tabOne",
      "tabTwo",
      "tabThree",
      "graphIndicator",
      "popup",
    ].forEach((name) {
      _tutorialProvider.addKey(name, GlobalKey());
    });
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
      List<TargetFocus> tutorialZeroTargets =
          _compareScreenTutorialTargets.getTutorialZeroTargets(
        _tutorialProvider.getKeyFor("addOption"),
        _tutorialProvider.getKeyFor("tabOne"),
        _tutorialProvider.getKeyFor("tabTwo"),
        _tutorialProvider.getKeyFor("tabThree"),
      );

      _tutorialUtils.showCoachMark(
        context: _context,
        finish: () {
          tutorialFinished = true;
          _tutorialProvider.removeTutorial(0);
        },
        targets: tutorialZeroTargets,
        clickTarget: (focus) {
          var key = focus.keyTarget;
          if (key == _tutorialProvider.getKeyFor("tabOne")) {
            _tabController.animateTo(1);
          } else if (key == _tutorialProvider.getKeyFor("tabTwo")) {
            _tabController.animateTo(2);
          }
        },
      );
    } catch (e) {
      throw e;
    }
  }

  void showTutorialOne() {
    try {
      var count = 0;
      List<TargetFocus> tutorialOneTargets =
          _compareScreenTutorialTargets.getTutorialOneTargets(
        _tutorialProvider.getKeyFor("graphIndicator"),
        _tutorialProvider.getKeyFor("popup"),
      );

      _tutorialUtils.showCoachMark(
        context: _context,
        finish: () {
          tutorialFinished = true;
          _tutorialProvider.getStateFunctionFor("hidePopup")();
          _tutorialProvider.removeTutorial(1);
        },
        targets: tutorialOneTargets,
        clickTarget: (focus) {
          var key = focus.keyTarget;
          if (key == _tutorialProvider.getKeyFor("graphIndicator")) {
            switch (count) {
              case 1:
                _tutorialProvider.getStateFunctionFor("disablePlot")();
                _tutorialProvider.getStateFunctionFor("showPopup")();
                break;
              default:
                break;
            }
            count++;
          } else if (key == _tutorialProvider.getKeyFor("popup")) {
            _tutorialProvider.getStateFunctionFor("hidePopup")();
          }
        },
      );
    } catch (e) {
      throw e;
    }
  }
}
