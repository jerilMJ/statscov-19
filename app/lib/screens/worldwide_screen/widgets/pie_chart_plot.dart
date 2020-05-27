import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:statscov/models/api/covid_compiled/report.dart';
import 'package:statscov/utils/constants.dart';

class PieChartPlot extends StatefulWidget {
  const PieChartPlot(this.report);

  final Report report;

  @override
  State<StatefulWidget> createState() => PieChartPlotState();
}

class PieChartPlotState extends State<PieChartPlot> {
  int touchedIndex;
  List<num> _cases;
  List<double> _percentages;
  List<Color> _colors;
  String _toolTip;
  Timer pieTimer;

  @override
  void initState() {
    super.initState();
    _toolTip = '';
    _cases = [
      widget.report.confirmed,
      widget.report.recovered,
      widget.report.deaths,
    ];

    touchedIndex = 0;
    pieTimer = Timer.periodic(const Duration(milliseconds: 4000), (_) {
      setState(() {
        touchedIndex = (touchedIndex + 1) > 2 ? 0 : touchedIndex + 1;
      });
    });

    _percentages = [for (num c in _cases) c * 100 / _cases[0]];
    _percentages[0] = 100 - (_percentages[1] + _percentages[2]);

    _colors = [
      Colors.blue.shade200,
      Colors.green.shade200,
      Colors.red.shade200,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: AbsorbPointer(
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
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
                  sections: showingSections(),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            color: AppConstants.of(context).kDarkElevations[1],
            child: Center(child: Text(_toolTip)),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(
      _percentages.length,
      (i) {
        final isTouched = i == touchedIndex;
        final double fontSize = isTouched ? 25 : 16;
        final double radius = isTouched ? 70 : 50;

        var name;

        switch (touchedIndex) {
          case 0:
            name = 'Active';
            break;
          case 1:
            name = 'Recovered';
            break;
          case 2:
            name = 'Deaths';
            break;
        }

        if (touchedIndex != null) {
          _toolTip = touchedIndex >= 0
              ? '$name - ${_percentages[touchedIndex].toStringAsFixed(2)}%'
              : _toolTip;
        } else {
          _toolTip = 'Active - ${_percentages[0].toStringAsFixed(2)}%';
        }

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

  @override
  void dispose() {
    pieTimer.cancel();
    super.dispose();
  }
}
