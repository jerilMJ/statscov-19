import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:statscov/screens/compare_screen/providers/compare_utility_provider.dart';

class PinOption extends StatelessWidget {
  const PinOption({
    @required AnimationController pinIconScaleController,
    @required AnimationController pinIconRotationController,
    Function callback,
    CompareUtilityProvider compareUtilityProvider,
  })  : _pinIconScaleController = pinIconScaleController,
        _pinIconRotationController = pinIconRotationController,
        _callback = callback,
        _compareUtilityProvider = compareUtilityProvider;

  final AnimationController _pinIconScaleController;
  final AnimationController _pinIconRotationController;
  final Function _callback;
  final CompareUtilityProvider _compareUtilityProvider;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.purple.shade200,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Icon(MaterialCommunityIcons.pin_outline),
          PinTarget(
            onWillAccept: (_) {
              _pinIconScaleController.forward();
              return true;
            },
            onLeave: (_) {
              _pinIconScaleController.reverse();
            },
            onAccept: (iso) {
              if (_compareUtilityProvider.isPinned(iso)) {
                _compareUtilityProvider.unpin(iso);
              } else {
                _compareUtilityProvider.pin(iso);
              }
              _pinIconScaleController.reverse();
              _pinIconRotationController.forward();
              _callback();
            },
          ),
        ],
      ),
    );
  }
}

class PinTarget extends StatelessWidget {
  const PinTarget({this.onWillAccept, this.onLeave, this.onAccept});

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
