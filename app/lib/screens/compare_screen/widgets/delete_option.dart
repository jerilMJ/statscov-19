import 'package:flutter/material.dart';
import 'package:statscov/screens/compare_screen/providers/compare_utility_provider.dart';

class DeleteOption extends StatelessWidget {
  const DeleteOption({
    @required AnimationController deleteIconScaleController,
    @required AnimationController deleteIconRotationController,
    Function callback,
    CompareUtilityProvider compareUtilityProvider,
  })  : _deleteIconScaleController = deleteIconScaleController,
        _deleteIconRotationController = deleteIconRotationController,
        _callback = callback,
        _compareUtilityProvider = compareUtilityProvider;

  final AnimationController _deleteIconScaleController;
  final AnimationController _deleteIconRotationController;
  final Function _callback;
  final CompareUtilityProvider _compareUtilityProvider;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.purple.shade200,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Icon(Icons.delete_outline),
          DeleteTarget(
            onWillAccept: (_) {
              _deleteIconScaleController.forward();
              return true;
            },
            onLeave: (_) {
              _deleteIconScaleController.reverse();
            },
            onAccept: (iso) {
              _compareUtilityProvider.removeSelection(iso);
              _deleteIconScaleController.reverse();
              _deleteIconRotationController.forward();
              _callback();
            },
          ),
        ],
      ),
    );
  }
}

class DeleteTarget extends StatelessWidget {
  const DeleteTarget({this.onWillAccept, this.onLeave, this.onAccept});

  final Function onWillAccept;
  final Function onLeave;
  final Function onAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      builder: (_, __, ___) {
        return Container();
      },
      onWillAccept: onWillAccept,
      onLeave: onLeave,
      onAccept: onAccept,
    );
  }
}
