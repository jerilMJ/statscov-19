import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statscov/models/api/iso_name.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/screens/worldwide_screen/providers/ordered_reports_provider.dart';
import 'package:statscov/screens/worldwide_screen/widgets/bar_controls.dart';
import 'package:statscov/shared/widgets/animated_counter.dart';
import 'package:statscov/shared/widgets/ui_card.dart';
import 'package:statscov/utils/constants.dart';

class GrowingBar {
  GrowingBar(this.count, this.iso, this.name, this.ratio, this.color);

  final int count;
  final String iso;
  final String name;
  final num ratio;
  final Color color;
}

class TopCountriesPlayer extends StatefulWidget {
  const TopCountriesPlayer({
    Key key,
  }) : super(key: key);

  @override
  _TopCountriesPlayerState createState() => _TopCountriesPlayerState();
}

class _TopCountriesPlayerState extends State<TopCountriesPlayer> {
  List items;
  int expansion;
  int maxExpansion = 20;
  List<Color> colors;
  TutorialProvider _tutorialProvider;
  OrderedReportsProvider _orderedReportsProvider;

  final colorList = [
    Colors.red.shade200,
    Colors.green.shade200,
    Colors.blue.shade200,
    Colors.purple.shade200,
    Colors.amber.shade200,
    Colors.orange.shade200,
    Colors.indigo.shade200,
    Colors.brown.shade200,
    Colors.grey.shade200,
    Colors.cyan.shade200,
    Colors.teal.shade200,
    Colors.blueGrey.shade200,
    Colors.lightBlue.shade200,
    Colors.yellow.shade200,
    Colors.lime.shade200,
    Colors.pink.shade200,
  ];

  @override
  void initState() {
    super.initState();
    expansion = 5;
    colors = <Color>[
      for (var _ in List<int>.generate(maxExpansion, (i) => i))
        colorList[Random().nextInt(colorList.length)]
    ];
    _tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    _orderedReportsProvider =
        Provider.of<OrderedReportsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
  }

  void _afterBuild(_) async {
    _tutorialProvider.screenTutorial.tutorialNotFinished();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shown = (await prefs.getBool('seenWorldwideTut3')) ?? false;
    if (!shown) {
      Future.delayed(
          Duration(milliseconds: _tutorialProvider.shortTutorialDelay), () {
        _tutorialProvider.screenTutorial.showTutorial(3);
      });
      await prefs.setBool('seenWorldwideTut3', true);
    } else {
      _tutorialProvider.screenTutorial.tutorialIsFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ValueListenableBuilder(
            valueListenable:
                Provider.of<OrderedReportsProvider>(context, listen: false)
                    .currentDateNotifier,
            builder: (_, __, ___) {
              final top = _orderedReportsProvider
                  .orderedReports[_orderedReportsProvider.currentDate]
                  .first
                  .confirmed;

              items = _orderedReportsProvider
                  .orderedReports[_orderedReportsProvider.currentDate]
                  .sublist(0, expansion)
                  .asMap()
                  .map(
                    (index, report) => MapEntry(
                      index,
                      GrowingBar(
                        report.confirmed,
                        report.iso,
                        IsoName().iso3ToCountry(report.iso),
                        report.confirmed / top,
                        colors[index],
                      ),
                    ),
                  )
                  .values
                  .toList();

              final sum = _orderedReportsProvider
                  .orderedReports[_orderedReportsProvider.currentDate]
                  .sublist(expansion)
                  .map((o) => o.confirmed)
                  .toList()
                  .reduce((a, b) => a + b);

              items.add(GrowingBar(
                  sum, "xxx", "Others", sum / top, Colors.blue.shade200));

              return UiCard(
                child: Column(
                  key: _tutorialProvider.getKeyFor("topCountriesPlayerCard"),
                  children: <Widget>[
                    Expanded(
                      child: LayoutBuilder(
                        builder: (_, constraints) {
                          var width = constraints.constrainWidth();
                          var height = constraints.constrainHeight();
                          return ImplicitlyAnimatedReorderableList<GrowingBar>(
                            items: items,
                            areItemsTheSame: (oldItem, newItem) {
                              return oldItem.iso == newItem.iso;
                            },
                            onReorderFinished: (item, from, to, newItems) {
                              setState(() {
                                items
                                  ..clear()
                                  ..addAll(newItems);
                              });
                            },
                            itemBuilder: (context, itemAnimation, item, index) {
                              return Reorderable(
                                key: ValueKey(item.iso),
                                builder: (context, dragAnimation, inDrag) {
                                  final t = dragAnimation.value;
                                  final elevation = lerpDouble(0, 8, t);
                                  final color = Color.lerp(Colors.white,
                                      Colors.white.withOpacity(0.8), t);

                                  return SizeFadeTransition(
                                    sizeFraction: 0.7,
                                    curve: Curves.easeInOut,
                                    animation: itemAnimation,
                                    child: Material(
                                      color: color,
                                      elevation: elevation,
                                      type: MaterialType.transparency,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Stack(
                                            alignment: Alignment.centerLeft,
                                            children: <Widget>[
                                              AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 500),
                                                color:
                                                    item.color.withAlpha(150),
                                                width: (4 * width / 5) *
                                                    item.ratio,
                                                height: height / 12,
                                              ),
                                              ListTile(
                                                title: Text(
                                                  '${item.name}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color:
                                                        AppConstants.of(context)
                                                            .kTextWhite[0],
                                                  ),
                                                ),
                                                trailing: AnimatedCounter(
                                                  count: item.count,
                                                  prev: item.count,
                                                  isFraction: false,
                                                  duration: const Duration(
                                                    milliseconds: 1000,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        IconButton(
                          tooltip: 'Expand',
                          icon: Icon(Icons.arrow_drop_down),
                          onPressed: () => setState(() {
                            if (expansion < maxExpansion) expansion += 5;
                            if (expansion > maxExpansion)
                              expansion = maxExpansion;
                          }),
                          color: AppConstants.of(context).kTextWhite[1],
                        ),
                        IconButton(
                          tooltip: 'Retract',
                          icon: Icon(Icons.arrow_drop_up),
                          onPressed: () => setState(() {
                            if (expansion > 5) expansion -= 5;
                          }),
                          color: AppConstants.of(context).kTextWhite[1],
                        ),
                        Expanded(
                          child: Text(
                            'Showing top ($expansion/$maxExpansion) of 182 countries',
                            style: TextStyle(
                              color: AppConstants.of(context).kTextWhite[1],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        ValueListenableBuilder(
          valueListenable: _orderedReportsProvider.percentageNotifier,
          builder: (_, __, ___) => TweenAnimationBuilder(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(
                begin: _orderedReportsProvider.prevPercentage,
                end: _orderedReportsProvider.percentage),
            builder: (_, perc, __) => LinearProgressIndicator(
              value: perc,
              backgroundColor: AppConstants.of(context).kSurfaceColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppConstants.of(context).kDarkElevations[2],
              ),
            ),
          ),
        ),
        BarControls(_tutorialProvider),
      ],
    );
  }
}
