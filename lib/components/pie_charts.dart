import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:statscov/components/ui_card.dart';
import 'package:statscov/models/report.dart';

import 'indicator.dart';

class PieCharts extends StatefulWidget {
  PieCharts(this.report, this.population);
  final Report report;
  final int population;

  @override
  State<StatefulWidget> createState() => PieChartsState();
}

class PieChartsState extends State<PieCharts> {
  int touchedIndex;
  List<double> _cases;
  List<double> _percentages;
  List<Color> _colors;

  @override
  void initState() {
    super.initState();
    _cases = [
      log(widget.report.confirmed),
      log(widget.report.recovered),
      log(widget.report.deaths),
    ];

    _percentages = [for (double c in _cases) c * 100 / log(widget.population)];
    _percentages.add(100.0 - _percentages.reduce((a, b) => a + b) * 1.0);
    print(_percentages);

    _colors = [Colors.blue, Colors.green, Colors.red, Colors.grey];
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: UiCard(
        child: Row(
          children: <Widget>[
            const SizedBox(
              height: 18,
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                      pieTouchData:
                          PieTouchData(touchCallback: (pieTouchResponse) {
                        setState(() {
                          if (pieTouchResponse.touchInput is FlLongPressEnd ||
                              pieTouchResponse.touchInput is FlPanEnd) {
                            touchedIndex = -1;
                          } else {
                            touchedIndex = pieTouchResponse.touchedSectionIndex;
                          }
                        });
                      }),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: showingSections()),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Indicator(
                  color: Colors.blue,
                  text: 'Confirmed',
                  isSquare: true,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Colors.green,
                  text: 'Recovered',
                  isSquare: true,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Colors.red,
                  text: 'Deaths',
                  isSquare: true,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Colors.grey,
                  text: 'Total Population',
                  isSquare: true,
                ),
                SizedBox(
                  height: 18,
                ),
              ],
            ),
            const SizedBox(
              width: 28,
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(
      _percentages.length,
      (i) {
        final isTouched = i == touchedIndex;
        final double fontSize = isTouched ? 25 : 16;
        final double radius = isTouched ? 60 : 50;
        print('${_colors[i]} _${_percentages[i]}');
        return PieChartSectionData(
          color: _colors[i],
          value: _percentages[i],
          title: '',
          radius: radius,
          titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff)),
        );
      },
    );
  }
}
