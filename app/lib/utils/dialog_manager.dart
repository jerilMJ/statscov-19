import 'package:flutter/material.dart';
import 'package:statscov/utils/constants.dart';

class DialogManager extends InheritedWidget {
  DialogManager({Widget child, Key key}) : super(key: key, child: child);

  static DialogManager of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DialogManager>();

  final Map<String, GlobalKey> dialogKeyStore = {};

  showDialogPopup(BuildContext context, Widget child, String dialogName) {
    if (dialogKeyStore.length != 0) {
      return;
    }

    final key = GlobalKey<State>();
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Dialog",
      transitionDuration: const Duration(milliseconds: 500),
      barrierColor: AppConstants.of(context).kSurfaceColor,
      transitionBuilder: (
        _,
        animation,
        __,
        child,
      ) {
        var anim;
        if (animation.status == AnimationStatus.forward) {
          anim = Tween(
            begin: const Offset(0.0, 1.0),
            end: const Offset(0.0, 0.0),
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          );

          return SlideTransition(
            position: anim,
            child: child,
          );
        } else {
          anim = Tween(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeIn),
          );

          return FadeTransition(
            opacity: anim,
            child: child,
          );
        }
      },
      pageBuilder: (_, animation, secondaryAnimation) {
        return WillPopScope(
          key: key,
          onWillPop: () async => false,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: child,
            color: AppConstants.of(context).kSurfaceColor,
          ),
        );
      },
    );
    dialogKeyStore[dialogName] = key;
  }

  clearDialogs() {
    dialogKeyStore.values
        .forEach((key) => Navigator.of(key?.currentContext)?.pop());

    dialogKeyStore.clear();
  }

  @override
  bool updateShouldNotify(DialogManager oldWidget) => false;
}
