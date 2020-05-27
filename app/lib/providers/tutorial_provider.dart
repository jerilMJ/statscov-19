import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:rxdart/subjects.dart';
import 'package:statscov/models/abstracts/screen_tutorial.dart';

/// Provider for providing tutorial to the screens.
///
/// Keeps hold of the keys used, callback functions for interactive
/// tutorials and a tutorial queue to avoid tutorial collisions.
class TutorialProvider with ChangeNotifier {
  TutorialProvider() {
    _tutorialQueue = Queue<int>();
    _tutorialQueueController = BehaviorSubject<Queue<int>>();
    _tutorialQueueStream = _tutorialQueueController.stream;
  }

  Map<String, GlobalKey> keys = {};
  Map<String, Function> stateFunctions = {};
  ScreenTutorial screenTutorial;
  Queue<int> _tutorialQueue;
  BehaviorSubject<Queue<int>> _tutorialQueueController;
  Stream<Queue<int>> _tutorialQueueStream;

  int get tutorialDelay => 600;
  int get shortTutorialDelay => 100; // in milliseconds

  Future waitUntilAtFront(int tutorialNumber) {
    return _tutorialQueueStream
        .firstWhere((queue) => queue.first == tutorialNumber || queue.isEmpty);
  }

  void addTutorial(int tutorialNumber) {
    if (!_tutorialQueue.contains(tutorialNumber)) {
      _tutorialQueue.add(tutorialNumber);
      _tutorialQueueController.add(_tutorialQueue);
    }
  }

  void removeTutorial(int tutorialNumber) {
    _tutorialQueue.remove(tutorialNumber);
    _tutorialQueueController.add(_tutorialQueue);
  }

  void addKey(String name, GlobalKey key) {
    keys[name] = key;
  }

  GlobalKey getKeyFor(String name) {
    if (keys.containsKey(name)) {
      return keys[name];
    } else {
      print('no key found for $name');
      return GlobalKey();
    }
  }

  void addStateFunction(String name, Function func) {
    stateFunctions[name] = func;
  }

  Function getStateFunctionFor(String name) {
    if (stateFunctions.containsKey(name)) {
      return stateFunctions[name];
    } else {
      print('no state key found for $name');
      return () {};
    }
  }
}
