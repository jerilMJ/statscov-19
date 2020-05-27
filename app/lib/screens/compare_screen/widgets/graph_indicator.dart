import 'package:charts_flutter/flutter.dart' as charts hide TextStyle;
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/screens/compare_screen/providers/compare_utility_provider.dart';
import 'package:statscov/screens/compare_screen/providers/overlay_provider.dart';
import 'package:statscov/utils/constants.dart';
import 'package:statscov/utils/screen_size_util.dart';

class GraphIndicator extends StatefulWidget {
  const GraphIndicator({
    this.color,
    this.isDisabled,
    this.text,
    this.iso,
    this.deleteEvent,
    this.toggleEvent,
    this.isAlsoTutorialController = false,
    GlobalKey key,
  }) : super(key: key);

  final charts.Color color;
  final String text;
  final String iso;
  final Function deleteEvent;
  final Function toggleEvent;
  final bool isDisabled;
  final bool isAlsoTutorialController;

  @override
  _GraphIndicatorState createState() => _GraphIndicatorState();
}

class _GraphIndicatorState extends State<GraphIndicator> {
  double dragBallRadius = 30.0;

  @override
  void initState() {
    super.initState();
    if (widget.isAlsoTutorialController) {
      _addTutorialStateFunctions();
      WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
    }
  }

  void _addTutorialStateFunctions() {
    Provider.of<TutorialProvider>(context, listen: false)
        .addStateFunction("disablePlot", widget.toggleEvent);
    Provider.of<TutorialProvider>(context, listen: false)
        .addStateFunction("deletePlot", widget.deleteEvent);
  }

  void _afterBuild(_) async {
    TutorialProvider tutorialProvider =
        Provider.of<TutorialProvider>(context, listen: false);
    tutorialProvider.screenTutorial.tutorialNotFinished();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shown = (await prefs.getBool('seenCompareTut1')) ?? false;

    if (!shown) {
      Future.delayed(
        Duration(milliseconds: tutorialProvider.shortTutorialDelay),
        () => tutorialProvider.screenTutorial.showTutorial(1),
      );
      await prefs.setBool('seenCompareTut1', true);
    } else {
      tutorialProvider.screenTutorial.tutorialIsFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAlsoTutorialController) {
      _addTutorialStateFunctions();
    }
    return Consumer2<CompareUtilityProvider, OverlayProvider>(
      builder: (_, compareUtilityProvider, overlayProvider, __) {
        bool isPinned = compareUtilityProvider.isPinned(widget.iso);
        return Draggable<String>(
          data: widget.iso,
          onDragStarted: () {
            overlayProvider.cancelHide();
            overlayProvider.showOverlay();
          },
          onDraggableCanceled: (_, __) {
            overlayProvider.showOverlay();
          },
          onDragEnd: (_) {
            overlayProvider.hideOverlayWithDelay();
          },
          childWhenDragging: Container(
            width: double.infinity,
            height: double.infinity,
            color: AppConstants.of(context).kSurfaceColor,
          ),
          feedback: _buildFeedback(context, isPinned),
          dragAnchor: DragAnchor.pointer,
          child: Container(
            child: getIndicator(isPinned, compareUtilityProvider),
          ),
        );
      },
    );
  }

  Widget _buildFeedback(BuildContext context, bool isPinned) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 1.0, end: 0.0),
      builder: (_, value, __) => Stack(
        alignment: AlignmentDirectional.centerStart,
        children: <Widget>[
          Transform.translate(
            offset: Offset(
              -ScreenSizeUtil.screenWidth(context, dividedBy: 4),
              -25.0,
            ),
            child: Transform.scale(
              scale: value,
              child: Container(
                width: ScreenSizeUtil.screenWidth(context, dividedBy: 2),
                height: 50.0,
                child: getIndicator(isPinned, null),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(-dragBallRadius, -dragBallRadius),
            child: Transform.scale(
              scale: 1.0 - value,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: value < 1.0 ? 1.0 : 0.0,
                child: CircleAvatar(
                  radius: dragBallRadius,
                  backgroundColor: charts.ColorUtil.toDartColor(widget.color),
                  child: Container(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getIndicator(
      bool isPinned, CompareUtilityProvider compareUtilityProvider) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => compareUtilityProvider.isDisabled(widget.iso)
            ? compareUtilityProvider.enablePlot(widget.iso)
            : compareUtilityProvider.disablePlot(widget.iso),
        child: Row(
          children: <Widget>[
            isPinned
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Icon(
                      MaterialCommunityIcons.pin,
                      color: widget.isDisabled
                          ? charts.ColorUtil.toDartColor(widget.color)
                              .withAlpha(50)
                          : charts.ColorUtil.toDartColor(widget.color),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 15.0,
                      width: 30.0,
                      decoration: BoxDecoration(
                        color: widget.isDisabled
                            ? charts.ColorUtil.toDartColor(widget.color)
                                .withAlpha(50)
                            : charts.ColorUtil.toDartColor(widget.color),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
            Expanded(
              child: SizedBox(
                height: ScreenSizeUtil.screenHeight(context) * 0.025,
                child: FittedBox(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                        color: AppConstants.of(context).kTextWhite[1],
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
