import 'package:flutter/material.dart';
import 'package:statscov/utils/custom_icons.dart';
import 'package:statscov/utils/screen_size_util.dart';

class LoadBox extends StatelessWidget {
  const LoadBox(this._accompanyingText, {this.bgImgPath, this.opacity = 1.0});

  final String _accompanyingText;
  final String bgImgPath;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: Container(
            width: ScreenSizeUtil.screenWidth(context),
            decoration: bgImgPath != null
                ? BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage(bgImgPath),
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.8), BlendMode.dstOut),
                    ),
                  )
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                LoadingWheel(opacity: opacity),
                Text(_accompanyingText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoadingWheel extends StatefulWidget {
  const LoadingWheel({this.opacity = 1.0});
  final double opacity;

  @override
  _LoadingWheelState createState() => _LoadingWheelState();
}

class _LoadingWheelState extends State<LoadingWheel>
    with TickerProviderStateMixin {
  AnimationController _colorAnimationController;
  AnimationController _rotationAnimationController;
  AnimationController _sizeAnimationController;
  Animation _colorAnimation;
  Animation _sizeAnimation;
  Animation _rotationAnimation;
  TweenSequence<Color> _rainbow;
  Tween<double> _rotationTween;
  Tween<double> _sizeTween;

  @override
  void initState() {
    super.initState();
    _colorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimationController = AnimationController(
        duration: const Duration(milliseconds: 4000), vsync: this)
      ..repeat();

    _sizeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _rainbow = TweenSequence([
      TweenSequenceItem(
          tween: ColorTween(
              begin: Colors.red.shade200.withOpacity(widget.opacity),
              end: Colors.orange.shade200.withOpacity(widget.opacity)),
          weight: 20.0),
      TweenSequenceItem(
          tween: ColorTween(
              begin: Colors.orange.shade200.withOpacity(widget.opacity),
              end: Colors.yellow.shade200.withOpacity(widget.opacity)),
          weight: 20.0),
      TweenSequenceItem(
          tween: ColorTween(
              begin: Colors.yellow.shade200.withOpacity(widget.opacity),
              end: Colors.green.shade200.withOpacity(widget.opacity)),
          weight: 20.0),
      TweenSequenceItem(
          tween: ColorTween(
              begin: Colors.green.shade200.withOpacity(widget.opacity),
              end: Colors.blue.shade200.withOpacity(widget.opacity)),
          weight: 20.0),
      TweenSequenceItem(
          tween: ColorTween(
              begin: Colors.blue.shade200.withOpacity(widget.opacity),
              end: Colors.indigo.withOpacity(widget.opacity)),
          weight: 20.0),
      TweenSequenceItem(
          tween: ColorTween(
              begin: Colors.indigo.shade200.withOpacity(widget.opacity),
              end: Colors.red.shade200.withOpacity(widget.opacity)),
          weight: 20.0),
    ]);

    _rotationTween = Tween(begin: 0.0, end: 1.0);

    _sizeTween = Tween(begin: 1.0, end: 0.7);

    _colorAnimation = _rainbow.animate(_colorAnimationController);

    _rotationAnimation = _rotationTween.animate(_rotationAnimationController);

    _sizeAnimation = _sizeTween.animate(
      CurvedAnimation(
          parent: _sizeAnimationController, curve: Curves.easeOutExpo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (MediaQuery.of(context).size.height / 2.4),
      child: RotationTransition(
        turns: _rotationAnimation,
        child: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (_, __) => ScaleTransition(
            scale: _sizeAnimation,
            child: Icon(
              CustomIcons.virus,
              size: (MediaQuery.of(context).size.width / 2.5) *
                  _sizeAnimation.value,
              color: _colorAnimation.value,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _colorAnimationController.dispose();

    _rotationAnimationController.dispose();

    _sizeAnimationController.dispose();
    super.dispose();
  }
}
