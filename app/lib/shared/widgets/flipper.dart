import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/shared/widgets/animated_counter.dart';
import 'package:statscov/shared/widgets/flippable_card_design.dart';
import 'package:statscov/shared/widgets/painted_ui_card.dart';
import 'package:statscov/shared/widgets/ui_card.dart';
import 'package:statscov/utils/constants.dart';

class Flipper extends StatelessWidget {
  const Flipper({
    this.frontText,
    this.frontContent,
    this.backText,
    this.backContent,
    this.textStyle,
    this.titleStyle,
    this.color,
    this.flipCardKey,
    this.isAlsoTutorialCard = false,
  });

  final String frontText;
  final dynamic frontContent;
  final String backText;
  final dynamic backContent;
  final TextStyle textStyle;
  final TextStyle titleStyle;
  final Color color;
  final GlobalKey flipCardKey;
  final bool isAlsoTutorialCard;

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      key: flipCardKey,
      front: NumberCard(
        title: frontText,
        cardType: CardType.front,
        content: frontContent,
        textStyle: textStyle,
        titleStyle: titleStyle,
        color: color,
      ),
      back: NumberCard(
        title: 'Previously',
        cardType: CardType.back,
        content: backContent,
        textStyle: textStyle,
        titleStyle: titleStyle,
        animate: false,
        color: color,
      ),
      isAlsoTutorialCard: isAlsoTutorialCard,
    );
  }
}

enum CardType { front, back, normal }

class NumberCard extends StatelessWidget {
  const NumberCard({
    @required this.title,
    this.isFraction = false,
    this.animate = true,
    @required this.content,
    this.cardType = CardType.normal,
    this.titleStyle,
    this.textStyle,
    this.color,
  });

  final String title;
  final dynamic content;
  final TextStyle textStyle;
  final TextStyle titleStyle;
  final bool isFraction;
  final bool animate;
  final Color color;
  final CardType cardType;

  @override
  Widget build(BuildContext context) {
    final cardChild = FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                title,
                style: titleStyle ?? AppConstants.of(context).kTitleTextStyle,
              ),
              animate
                  ? AnimatedCounter(
                      count: content,
                      isFraction: isFraction,
                      textStyle: textStyle ??
                          AppConstants.of(context).kBigCounterTextStyle,
                    )
                  : Text(
                      NumberFormat.compact().format(content).toString(),
                      style: textStyle,
                    ),
            ],
          ),
        ],
      ),
    );

    var card;

    switch (cardType) {
      case CardType.front:
        card = PaintedUiCard(
          color: color ?? AppConstants.of(context).kDarkElevations[0],
          painter: FlippableCardFrontDesign(
            AppConstants.of(context).kDarkElevations[1],
            AppConstants.of(context).kSurfaceColor,
          ),
          child: cardChild,
        );
        break;

      case CardType.back:
        card = PaintedUiCard(
          color: color ?? AppConstants.of(context).kDarkElevations[0],
          painter: FlippableCardBackDesign(
            AppConstants.of(context).kDarkElevations[1],
            AppConstants.of(context).kSurfaceColor,
          ),
          child: cardChild,
        );
        break;

      default:
        card = UiCard(
          color: color ?? AppConstants.of(context).kDarkElevations[0],
          child: cardChild,
        );
    }

    return card;
  }
}

class FlipCard extends StatefulWidget {
  const FlipCard({
    @required this.front,
    @required this.back,
    this.tapToFlip = true,
    this.flipController,
    this.isAlsoTutorialCard = false,
    GlobalKey key,
  }) : super(key: key);

  final Widget front;
  final Widget back;
  final bool tapToFlip;
  final FlipController flipController;
  final bool isAlsoTutorialCard;

  @override
  _FlipCardState createState() => _FlipCardState(flipController);
}

class _FlipCardState extends State<FlipCard> {
  Widget front;
  Widget back;
  double rot = 0.0;
  double starting = 0.0;
  int _index;
  final FlipController _flipController;

  _FlipCardState(this._flipController);

  @override
  void initState() {
    super.initState();
    front = widget.front;
    back = widget.back;
    _index = 1;
    _flipController?.onFlip = (_) => flip();

    if (widget.isAlsoTutorialCard)
      Provider.of<TutorialProvider>(context, listen: false)
          .addStateFunction("flipCard", flip);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.tapToFlip ? flip : () {},
      child: LayoutBuilder(
        builder: (_, constraints) => IndexedStack(
          index: _index,
          alignment: Alignment.center,
          children: <Widget>[
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 250),
              tween: Tween(begin: 0.0, end: rot),
              curve: Curves.easeInOut,
              child: back,
              builder: (_, rot, child) {
                return Transform(
                  transform: Matrix4.rotationY(pi + rot),
                  origin: Offset(
                    constraints.constrainWidth() / 2,
                    constraints.constrainHeight() / 2,
                  ),
                  child: child,
                );
              },
            ),
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 250),
              tween: Tween(begin: 0.0, end: rot),
              curve: Curves.easeInOut,
              child: front,
              builder: (_, rot, child) {
                return Transform(
                  transform: Matrix4.rotationY(starting + rot),
                  origin: Offset(
                    constraints.constrainWidth() / 2,
                    constraints.constrainHeight() / 2,
                  ),
                  child: child,
                );
              },
              onEnd: () {
                if (rot != -pi) {
                  _index = _index == 0 ? 1 : 0;
                }
                rot = -pi;
                starting = pi;
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  void flip() {
    return setState(() {
      rot = -pi / 2;
    });
  }
}

class FlipController {
  ValueChanged<void> onFlip;

  flipCard() {
    onFlip(null);
  }
}
