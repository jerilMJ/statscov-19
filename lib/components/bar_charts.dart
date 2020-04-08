import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';
import 'package:statscov/components/ui_card.dart';
import 'package:statscov/models/report.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:statscov/utils/constants.dart';

class BarCharts extends StatefulWidget {
  BarCharts(this.report);
  final Report report;

  @override
  _BarChartsState createState() => _BarChartsState();
}

class _BarChartsState extends State<BarCharts> {
  List<List<BarChartGroupData>> barGroups;
  List<String> captions;
  List<String> descriptions;
  List<BoxDecoration> boxDecorations;
  List<String> _imgPaths;

  @override
  void initState() {
    super.initState();
    barGroups = [
      [
        BarChartGroupData(
          showingTooltipIndicators: [0, 1, 2],
          x: 0,
          barRods: [
            BarChartRodData(
              width: 15,
              color: Colors.blue.shade300,
              borderRadius: BorderRadius.circular(5.0),
              y: widget.report.confirmed.toDouble(),
            ),
          ],
        ),
        BarChartGroupData(
          showingTooltipIndicators: [0, 1, 2],
          x: 1,
          barRods: [
            BarChartRodData(
              width: 15,
              color: Colors.green.shade300,
              borderRadius: BorderRadius.circular(5.0),
              y: widget.report.recovered.toDouble(),
            ),
          ],
        ),
        BarChartGroupData(
          showingTooltipIndicators: [0, 1, 2],
          x: 2,
          barRods: [
            BarChartRodData(
              width: 15,
              color: Colors.red.shade300,
              borderRadius: BorderRadius.circular(5.0),
              y: widget.report.deaths.toDouble(),
            ),
          ],
        ),
      ],
      [
        BarChartGroupData(
          showingTooltipIndicators: [0, 1, 2],
          x: 0,
          barRods: [
            BarChartRodData(
              width: 15,
              color: Colors.blue.shade200,
              borderRadius: BorderRadius.circular(5.0),
              y: widget.report.confirmedDiff.toDouble(),
            ),
            BarChartRodData(
              width: 15,
              color: Colors.blue.shade400,
              borderRadius: BorderRadius.circular(5.0),
              y: widget.report.confirmed.toDouble(),
            ),
          ],
        ),
      ],
      [
        BarChartGroupData(
          showingTooltipIndicators: [0, 1, 2],
          x: 0,
          barRods: [
            BarChartRodData(
              width: 15,
              color: Colors.green.shade200,
              borderRadius: BorderRadius.circular(5.0),
              y: widget.report.recoveredDiff.toDouble(),
            ),
            BarChartRodData(
              width: 15,
              color: Colors.green.shade400,
              borderRadius: BorderRadius.circular(5.0),
              y: widget.report.recovered.toDouble(),
            ),
          ],
        ),
      ],
      [
        BarChartGroupData(
          showingTooltipIndicators: [0, 1, 2],
          x: 0,
          barRods: [
            BarChartRodData(
              width: 15,
              color: Colors.red.shade200,
              borderRadius: BorderRadius.circular(5.0),
              y: widget.report.deathsDiff.toDouble(),
            ),
            BarChartRodData(
              width: 15,
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(5.0),
              y: widget.report.deaths.toDouble(),
            ),
          ],
        ),
      ],
    ];

    captions = ['Mixed', 'Confirmed', 'Recovered', 'Deaths'];

    descriptions = [
      '',
      'Confirmed cases go up from ${widget.report.confirmed - widget.report.confirmedDiff} to ${widget.report.confirmed}',
      '${widget.report.recoveredDiff} more recover to a total of ${widget.report.recovered}',
      'Death toll increases by ${widget.report.deathsDiff} more totalling ${widget.report.deaths}\n'
          'Fatality Rate: ${widget.report.fatalityRate}'
    ];

    boxDecorations = [
      null,
      BoxDecoration(
        color: Colors.blue.shade200,
      ),
      BoxDecoration(
        color: Colors.green.shade200,
      ),
      BoxDecoration(
        color: Colors.red.shade200,
      ),
    ];

    _imgPaths = [
      null,
      'assets/images/confirmed_bg.png',
      'assets/images/recovered_bg.png',
      'assets/images/deaths_bg.png',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      scrollDirection: Axis.vertical,
      viewportFraction: 1.0,
      height: double.infinity,
      itemCount: barGroups.length,
      itemBuilder: (context, index) {
        return UiCard(
          child: OrientationBuilder(
            builder: (context, orientation) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: orientation == Orientation.portrait
                                ? MediaQuery.of(context).size.height * 0.05
                                : MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: BarChart(
                            BarChartData(
                              gridData: FlGridData(
                                show: true,
                                drawHorizontalLine: index == 0,
                                horizontalInterval:
                                    widget.report.confirmed / 10,
                              ),
                              groupsSpace: 100,
                              alignment: BarChartAlignment.center,
                              barTouchData: BarTouchData(
                                enabled: false,
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipBgColor: Colors.transparent,
                                  tooltipPadding: const EdgeInsets.all(0),
                                  tooltipBottomMargin: 0,
                                  getTooltipItem: (
                                    BarChartGroupData group,
                                    int groupIndex,
                                    BarChartRodData rod,
                                    int rodIndex,
                                  ) {
                                    return BarTooltipItem(
                                      rod.y.round().toString(),
                                      TextStyle(
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                            orientation == Orientation.portrait
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.03,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              borderData: FlBorderData(
                                show: false,
                              ),
                              barGroups: barGroups[index],
                              titlesData: FlTitlesData(
                                leftTitles: SideTitles(showTitles: false),
                                bottomTitles: SideTitles(
                                  showTitles: (index == 0) ? true : false,
                                  textStyle: TextStyle(color: Colors.white),
                                  getTitles: (value) {
                                    return [
                                      'Confirmed',
                                      'Recovered',
                                      'Deaths'
                                    ][value.toInt()];
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: index != 0,
                        child: Expanded(
                          flex: 2,
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 15.0,
                              top: 20.0,
                            ),
                            height: double.infinity,
                            decoration: index != 0
                                ? BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(_imgPaths[index]),
                                      fit: BoxFit.cover,
                                      alignment: Alignment.centerLeft,
                                      colorFilter: ColorFilter.mode(
                                          Colors.black.withOpacity(0.5),
                                          BlendMode.darken),
                                    ),
                                  )
                                : null,
                            child: Text(
                              descriptions[index],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: orientation == Orientation.portrait
                                    ? MediaQuery.of(context).size.width * 0.05
                                    : MediaQuery.of(context).size.height * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(
                    orientation == Orientation.portrait
                        ? MediaQuery.of(context).size.width * 0.03
                        : MediaQuery.of(context).size.height * 0.03,
                  ),
                  color: AppConstants.of(context).kDarkSecondary,
                  child: Center(
                    child: Text(
                      captions[index],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
