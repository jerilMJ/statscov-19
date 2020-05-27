import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:statscov/models/api/covid_compiled/report.dart';

class BarChartUtils {
  const BarChartUtils();

  static List<String> getDescriptions(Report report) {
    String confirmedDesc;
    String recoveredDesc;
    String deathsDesc;

    if (report.confirmedDiff == 0) {
      confirmedDesc = 'New positive cases have not arisen';
    } else {
      confirmedDesc = 'Positive cases see a rise of ${report.confirmedDiff}';
    }

    if (report.recoveredDiff == 0) {
      recoveredDesc = 'No recoveries have been reported';
    } else {
      recoveredDesc = '${report.recoveredDiff} more join the recovered';
    }

    if (report.deathsDiff == 0) {
      deathsDesc = 'Death toll stays stagnant for the day';
    } else {
      deathsDesc = '${report.deathsDiff} more deaths have been reported';
    }

    return ['', confirmedDesc, recoveredDesc, deathsDesc];
  }

  static List<List<BarChartGroupData>> getBarGroupDatas(Report report) {
    return [
      [
        BarChartGroupData(
          showingTooltipIndicators: [0, 1, 2],
          x: 0,
          barRods: [
            BarChartRodData(
              width: 15,
              color: Colors.blue.shade300,
              borderRadius: BorderRadius.circular(5.0),
              y: report.confirmed.toDouble(),
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
              y: report.recovered.toDouble(),
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
              y: report.deaths.toDouble(),
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
              y: report.confirmedDiff.toDouble(),
            ),
            BarChartRodData(
              width: 15,
              color: Colors.blue.shade400,
              borderRadius: BorderRadius.circular(5.0),
              y: report.confirmed.toDouble(),
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
              y: report.recoveredDiff.toDouble(),
            ),
            BarChartRodData(
              width: 15,
              color: Colors.green.shade400,
              borderRadius: BorderRadius.circular(5.0),
              y: report.recovered.toDouble(),
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
              y: report.deathsDiff.toDouble(),
            ),
            BarChartRodData(
              width: 15,
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(5.0),
              y: report.deaths.toDouble(),
            ),
          ],
        ),
      ],
    ];
  }
}
