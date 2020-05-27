import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/providers/worldwide_report_provider.dart';
import 'package:statscov/screens/worldwide_screen/widgets/ordered_percentages.dart';
import 'package:statscov/utils/constants.dart';
import 'package:statscov/utils/screen_size_util.dart';

class StackedBar extends StatefulWidget {
  const StackedBar({
    @required WorldwideReportProvider worldwideReportProvider,
  }) : _worldwideReportProvider = worldwideReportProvider;

  final WorldwideReportProvider _worldwideReportProvider;

  @override
  _StackedBarState createState() => _StackedBarState();
}

class _StackedBarState extends State<StackedBar>
    with AutomaticKeepAliveClientMixin {
  double heightMultiplier = 0.0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
  }

  void _afterBuild(_) async {
    TutorialProvider tutorialProvider =
        Provider.of<TutorialProvider>(context, listen: false);
    tutorialProvider.screenTutorial.tutorialNotFinished();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shown = (await prefs.getBool('seenWorldwideTut2')) ?? false;

    if (!shown) {
      Future.delayed(
        Duration(milliseconds: tutorialProvider.shortTutorialDelay),
        () => tutorialProvider.screenTutorial.showTutorial(2),
      );
      await prefs.setBool('seenWorldwideTut2', true);
    } else {
      tutorialProvider.screenTutorial.tutorialIsFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Card(
              elevation: 0.0,
              color: AppConstants.of(context).kDarkElevations[0],
              key: Provider.of<TutorialProvider>(context, listen: false)
                  .getKeyFor('stackedBarCard'),
              margin: const EdgeInsets.all(10.0),
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 500),
                tween: Tween(
                  begin: Offset(ScreenSizeUtil.screenWidth(context), 0.0),
                  end: const Offset(0.0, 0.0),
                ),
                child: Row(
                  children: <Widget>[
                    LayoutBuilder(
                      builder: (_, constraints) {
                        final height = constraints.constrainHeight();

                        return SingleChildScrollView(
                          child: Container(
                            height: height + (height * heightMultiplier),
                            child: CustomPaint(
                              painter: ChartNumbers(
                                  widget._worldwideReportProvider.topCountries
                                      .map((country) => country.countryName)
                                      .toList()
                                        ..add('Others'),
                                  widget._worldwideReportProvider
                                      .barStackProportions,
                                  context),
                              child: Container(
                                child: BarChart(
                                  BarChartData(
                                    titlesData: const FlTitlesData(show: false),
                                    borderData: FlBorderData(show: false),
                                    barGroups: <BarChartGroupData>[
                                      BarChartGroupData(
                                        x: 0,
                                        barRods: [
                                          BarChartRodData(
                                            color: Colors.grey.shade400,
                                            width: 50.0,
                                            y: 100.0,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            rodStackItem: widget
                                                ._worldwideReportProvider
                                                .barChartStack,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Slider(
                          activeColor:
                              AppConstants.of(context).kDarkElevations[2],
                          inactiveColor:
                              AppConstants.of(context).kDarkElevations[1],
                          value: heightMultiplier,
                          onChanged: (value) {
                            setState(() {
                              heightMultiplier = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                builder: (_, offset, child) =>
                    Transform.translate(offset: offset, child: child),
              ),
            ),
          ),
        ),
        Container(
          height: 40.0,
          child: RaisedButton(
            child: const Text('Show All'),
            color: AppConstants.of(context).kDarkElevations[2],
            onPressed: () {
              BorderRadius borderRadius = const BorderRadius.only(
                topLeft: const Radius.circular(10.0),
                topRight: const Radius.circular(10.0),
              );
              showCupertinoModalPopup(
                filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                context: context,
                builder: (context) => Material(
                  color: Colors.transparent,
                  child: Container(
                    width: ScreenSizeUtil.screenWidth(context, dividedBy: 1.2),
                    height:
                        ScreenSizeUtil.screenHeight(context, dividedBy: 1.5),
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade200,
                          Colors.purple.shade400,
                          Colors.purpleAccent.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: OrderedPercentages(
                      worldwideReportProvider: widget._worldwideReportProvider,
                      borderRadius: borderRadius,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ChartNumbers extends CustomPainter {
  ChartNumbers(this.names, this.proportions, this.context);
  final List<double> proportions;
  final List<String> names;
  final BuildContext context;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.grey.shade300;
    for (int i = 0; i < proportions.length; i += 2) {
      double height = getHeight(proportions[i], proportions[i + 1], size);
      canvas.drawLine(Offset(25.0, height), Offset(size.width, height), paint);

      TextPainter textPainter = TextPainter(
        text: TextSpan(
            text:
                '${((proportions[i + 1] - proportions[i]) * 100).toStringAsPrecision(3)}% \t ${names[i ~/ 2]}',
            style: TextStyle(
              color: AppConstants.of(context).kTextWhite[0],
            )),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(75.0, height));
    }
  }

  double getHeight(double proportionA, double proportionB, Size size) {
    return size.height * (proportionA + proportionB) / 2;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
