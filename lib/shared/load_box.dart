import 'package:flutter/material.dart';
import 'package:statscov/utils/custom_icons.dart';

class LoadBox extends StatefulWidget {
  @override
  _LoadBoxState createState() => _LoadBoxState();
}

class _LoadBoxState extends State<LoadBox> with TickerProviderStateMixin {
  AnimationController _colorAnimationController;
  AnimationController _rotationAnimationController;
  AnimationController _sizeAnimationController;
  Animation _colorAnimation;
  Animation _sizeAnimation;
  TweenSequence<Color> _rainbow;
  Tween<double> _rotationTween;
  Tween<double> _sizeTween;

  @override
  void initState() {
    _colorAnimationController = AnimationController(
      duration: Duration(milliseconds: 5000),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimationController = AnimationController(
        duration: Duration(milliseconds: 10000), vsync: this)
      ..repeat();

    _sizeAnimationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _rainbow = TweenSequence([
      TweenSequenceItem(
          tween: ColorTween(begin: Colors.red, end: Colors.orange),
          weight: 20.0),
      TweenSequenceItem(
          tween: ColorTween(begin: Colors.orange, end: Colors.yellow),
          weight: 20.0),
      TweenSequenceItem(
          tween: ColorTween(begin: Colors.yellow, end: Colors.green),
          weight: 20.0),
      TweenSequenceItem(
          tween: ColorTween(begin: Colors.green, end: Colors.blue),
          weight: 20.0),
      TweenSequenceItem(
          tween: ColorTween(begin: Colors.blue, end: Colors.indigo),
          weight: 20.0),
      TweenSequenceItem(
          tween: ColorTween(begin: Colors.indigo, end: Colors.indigoAccent),
          weight: 20.0),
    ]);

    _rotationTween = Tween(begin: 0.0, end: 1.0);

    _sizeTween = Tween(begin: 1.0, end: 0.7);

    _colorAnimation = _rainbow.animate(_colorAnimationController);

    _sizeAnimation = _sizeTween.animate(
      CurvedAnimation(
          parent: _sizeAnimationController, curve: Curves.easeOutExpo),
    );

    _colorAnimation.addListener(() => setState(() {}));
    _sizeAnimation.addListener(() => setState(() {}));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Container(
        height: orientation == Orientation.portrait
            ? (MediaQuery.of(context).size.width / 2)
            : (MediaQuery.of(context).size.height / 2),
        child: RotationTransition(
          turns: _rotationTween.animate(_rotationAnimationController),
          child: Icon(
            CustomIcons.virus,
            size: orientation == Orientation.portrait
                ? (MediaQuery.of(context).size.width / 2.5) *
                    _sizeAnimation.value
                : (MediaQuery.of(context).size.height / 2.5) *
                    _sizeAnimation.value,
            color: _colorAnimation.value,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _colorAnimationController.dispose();

    _rotationAnimationController.dispose();

    _sizeAnimationController.dispose();
    super.dispose();
  }
}
