/// Abstract class for screen tutorials.
///
/// Used for accessing the tutorial class of a screen
/// via the tutorial provider so that an instance of
/// that class doesn't have to be created solely for
/// that purpose.
abstract class ScreenTutorial {
  Future<void> showTutorial(int tutorialNumber) {
    return null;
  }

  void tutorialNotFinished() {}

  void tutorialIsFinished() {}
}
