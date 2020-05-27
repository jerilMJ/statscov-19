import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    @required this.count,
    @required this.isFraction,
    this.duration = const Duration(milliseconds: 3000),
    this.prev,
    this.textStyle,
  });

  final num prev;
  final num count;
  final Duration duration;
  final TextStyle textStyle;
  final bool isFraction;

  @override
  _AnimatedCounterState createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TweenAnimationBuilder(
      tween: widget.isFraction
          ? Tween(begin: widget.prev ?? 0.0, end: widget.count)
          : IntTween(begin: widget.prev ?? 0, end: widget.count),
      duration: widget.duration,
      builder: (_, count, __) => FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          widget.isFraction
              ? (count).toStringAsFixed(5) + '%'
              : NumberFormat.compact().format(count).toString(),
          style: widget.textStyle,
        ),
      ),
    );
  }
}
