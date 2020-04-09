import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimatedCounter extends StatefulWidget {
  AnimatedCounter({
    @required this.count,
    @required this.isFraction,
    this.duration = const Duration(milliseconds: 3000),
    this.textStyle,
  });
  final dynamic count;
  final Duration duration;
  final TextStyle textStyle;
  final bool isFraction;

  @override
  _AnimatedCounterState createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController _counterController;
  Animation<dynamic> _counterAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _counterController =
        AnimationController(duration: widget.duration, vsync: this);
    _counterAnimation =
        Tween(begin: 0.0, end: widget.count * 1.0).animate(_counterController);
    _counterAnimation.addListener(() => setState(() {}));
    _counterController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.isFraction
          ? MediaQuery.of(context).size.height * 0.03
          : MediaQuery.of(context).size.height * .07,
      child: FittedBox(
        child: Text(
          widget.isFraction
              ? (_counterAnimation.value as double).toStringAsFixed(5) + '%'
              : NumberFormat.compact()
                  .format(_counterAnimation.value)
                  .toString(),
          style: widget.textStyle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _counterController.dispose();
    super.dispose();
  }
}
