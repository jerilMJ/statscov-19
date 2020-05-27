import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:statscov/screens/compare_screen/providers/compare_utility_provider.dart';
import 'package:statscov/screens/compare_screen/widgets/delete_option.dart';
import 'package:statscov/screens/compare_screen/widgets/pin_option.dart';
import 'package:statscov/utils/screen_size_util.dart';

class OverlayProvider with ChangeNotifier {
  OverlayProvider(this._compareUtilityProvider) {
    _isAlive = true;
  }

  AnimationController _pinIconRotationController;
  AnimationController _deleteIconRotationController;
  AnimationController _pinIconScaleController;
  AnimationController _deleteIconScaleController;
  AnimationController _iconsSlideController;
  CancelableOperation _iconsRevert;
  CompareUtilityProvider _compareUtilityProvider;
  OverlayEntry _overlayEntry;
  bool _isAlive;

  OverlayEntry get overlayEntry => _overlayEntry;

  void _setState() {
    if (_isAlive) notifyListeners();
  }

  void initControllers(
      TickerProvider vsync, BuildContext context, GlobalKey popupKey) {
    _deleteIconRotationController = AnimationController(
        vsync: vsync, duration: const Duration(milliseconds: 500))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _deleteIconRotationController.reverse();
        }
      });
    _deleteIconScaleController = AnimationController(
        vsync: vsync, duration: const Duration(milliseconds: 500));
    _pinIconRotationController = AnimationController(
        vsync: vsync, duration: const Duration(milliseconds: 500))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _pinIconRotationController.reverse();
        }
      });
    _pinIconScaleController = AnimationController(
        vsync: vsync, duration: const Duration(milliseconds: 500));
    _iconsSlideController = AnimationController(
        vsync: vsync, duration: const Duration(milliseconds: 500));

    _overlayEntry = _buildOverlayEntry(context, popupKey);
  }

  OverlayEntry _buildOverlayEntry(BuildContext context, GlobalKey key) {
    return OverlayEntry(
      builder: (_) => Positioned(
        right: 20.0,
        height: ScreenSizeUtil.screenHeight(context),
        child: SlideTransition(
          position:
              Tween(begin: const Offset(5.0, 0.0), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _iconsSlideController,
              curve: const Interval(
                0.0,
                1.0,
                curve: Curves.easeIn,
              ),
            ),
          ),
          child: Column(
            key: key,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              RotationTransition(
                turns: Tween(begin: 0.0, end: 360.0).animate(
                  CurvedAnimation(
                    parent: _pinIconRotationController,
                    curve: const Interval(
                      0.0,
                      1.0,
                      curve: Curves.linear,
                    ),
                  ),
                ),
                child: ScaleTransition(
                  scale: Tween(begin: 1.0, end: 2.0).animate(
                    CurvedAnimation(
                      parent: _pinIconScaleController,
                      curve: const Interval(
                        0.0,
                        1.0,
                        curve: Curves.linear,
                      ),
                    ),
                  ),
                  child: _compareUtilityProvider.pinningAllowed
                      ? PinOption(
                          pinIconRotationController: _pinIconRotationController,
                          pinIconScaleController: _pinIconScaleController,
                          compareUtilityProvider: _compareUtilityProvider,
                          callback: () => _setState(),
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.purple.shade200,
                          child: Icon(MaterialCommunityIcons.pin_off),
                        ),
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              RotationTransition(
                turns: Tween(begin: 0.0, end: 360.0).animate(
                  CurvedAnimation(
                    parent: _deleteIconRotationController,
                    curve: const Interval(
                      0.0,
                      1.0,
                      curve: Curves.linear,
                    ),
                  ),
                ),
                child: ScaleTransition(
                  scale: Tween(begin: 1.0, end: 2.0).animate(
                    CurvedAnimation(
                      parent: _deleteIconScaleController,
                      curve: const Interval(
                        0.0,
                        1.0,
                        curve: Curves.linear,
                      ),
                    ),
                  ),
                  child: DeleteOption(
                    deleteIconRotationController: _deleteIconRotationController,
                    deleteIconScaleController: _deleteIconScaleController,
                    compareUtilityProvider: _compareUtilityProvider,
                    callback: () => _setState(),
                  ),
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showOverlay() {
    _iconsSlideController.forward();
  }

  void hideOverlay() {
    _iconsSlideController?.reverse();
  }

  void hideOverlayWithDelay() {
    _iconsRevert = CancelableOperation.fromFuture(
      Future.delayed(
        const Duration(milliseconds: 3000),
        () {
          if (!_iconsRevert.isCanceled) {
            _iconsSlideController.reverse();
          }
        },
      ),
    );
  }

  void cancelHide() {
    _iconsRevert?.cancel();
  }

  void disposeControllers() {
    _overlayEntry?.remove();
    _iconsRevert?.cancel();
    _pinIconRotationController?.dispose();
    _pinIconScaleController?.dispose();
    _deleteIconRotationController?.dispose();
    _deleteIconScaleController?.dispose();
    _iconsSlideController?.dispose();
  }

  @override
  void dispose() {
    _isAlive = false;
    super.dispose();
  }
}
