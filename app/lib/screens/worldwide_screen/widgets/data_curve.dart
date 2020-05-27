import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statscov/models/api/covid_compiled/report.dart';
import 'package:statscov/models/api/covid_minified/minified_report.dart';
import 'package:charts_flutter/flutter.dart' as charts hide Axis;
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/screens/stats_screen/providers/detailed_report_provider.dart';
import 'package:statscov/screens/worldwide_screen/providers/worldwide_reports_provider.dart';
import 'package:statscov/shared/widgets/ui_card.dart';
import 'package:statscov/utils/constants.dart';

class DataCurve extends StatefulWidget {
  DataCurve({GlobalKey key}) : super(key: key);

  @override
  _DataCurveState createState() => _DataCurveState();
}

class _DataCurveState extends State<DataCurve>
    with AutomaticKeepAliveClientMixin {
  int dashSpace = 4;
  TutorialProvider _tutorialProvider;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
  }

  void _afterBuild(_) async {
    _tutorialProvider.screenTutorial.tutorialNotFinished();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shown = (await prefs.getBool('seenWorldwideTut1')) ?? false;

    if (!shown) {
      Future.delayed(
        Duration(milliseconds: _tutorialProvider.shortTutorialDelay),
        () => _tutorialProvider.screenTutorial.showTutorial(1),
      );
      await prefs.setBool('seenWorldwideTut1', true);
    } else {
      _tutorialProvider.screenTutorial.tutorialIsFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<WorldwideReportsProvider>(
      builder: (_, worldwideReportsProvider, __) {
        return Column(
          children: <Widget>[
            Expanded(
              child: UiCard(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'The Worldwide Curve',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppConstants.of(context).kTextWhite[0],
                            ),
                          ),
                        ),
                        Expanded(
                          child: ValueListenableBuilder(
                            valueListenable:
                                worldwideReportsProvider.rapNotifier,
                            builder: (_, rap, __) => Text(
                              'Rolling Average: ${rap.toInt().toString()}',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: AppConstants.of(context).kTextWhite[1],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Expanded(
                      child: Stack(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Expanded(
                                child: ValueListenableBuilder(
                                  valueListenable:
                                      worldwideReportsProvider.rapNotifier,
                                  builder: (_, rap, __) => DataPlot(
                                    dashSpace: dashSpace,
                                    dataSet: _createDailyCasesCurve(
                                      Provider.of<WorldwideReportsProvider>(
                                              context,
                                              listen: false)
                                          .worldwideReports,
                                      rap.toInt(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: worldwideReportsProvider.rapNotifier,
              builder: (_, rap, __) => Slider(
                activeColor: AppConstants.of(context).kDarkElevations[2],
                inactiveColor: AppConstants.of(context).kDarkElevations[1],
                value: rap,
                onChanged: (val) {
                  worldwideReportsProvider.setRollingAveragePeriod(val);
                },
                min: 1.0,
                max: 10.0,
                label: 'Rolling average period',
              ),
            ),
          ],
        );
      },
    );
  }

  List<charts.Series<LinearPlot, DateTime>> _createDailyCasesCurve(
    Map<String, Report> reports,
    int rollingAveragePeriod,
  ) {
    final dataDaily = reports.map((date, report) {
      final count = report.confirmed - report.confirmedDiff;
      return MapEntry(date, count);
    });

    final plots = zip([
      List<int>.generate(dataDaily.length, (index) => index),
      List<dynamic>.from(dataDaily.entries.toList()),
    ])
        .map((pair) {
          final index = pair[0];
          final report = pair[1];

          final start = index - rollingAveragePeriod >= 0
              ? index - rollingAveragePeriod
              : index;
          // final end = index == start ? index + 1 : index;
          final end = index + rollingAveragePeriod < dataDaily.length
              ? index + rollingAveragePeriod
              : dataDaily.length;

          final sample = dataDaily.values.toList().sublist(start, end);
          final rollingAverage = sample.reduce((a, b) => a + b) / sample.length;

          return MapEntry(
              index, LinearPlot(DateTime.parse(report.key), rollingAverage));
        })
        .map((e) => e.value)
        .toList();

    return [
      _createSeries(
          plots, 'Daily', charts.ColorUtil.fromDartColor(Colors.blue.shade200)),
    ];
  }

  charts.Series<LinearPlot, DateTime> _createSeries(
      List<LinearPlot> dataSet, String id, charts.Color color) {
    return charts.Series<LinearPlot, DateTime>(
      id: id,
      colorFn: (_, __) => color,
      areaColorFn: (_, __) => const charts.Color(r: 100, g: 100, b: 100, a: 50),
      domainFn: (LinearPlot data, _) => data.date,
      measureFn: (LinearPlot data, _) => data.count,
      data: dataSet,
      strokeWidthPxFn: (_, __) => 3.5,
    );
  }
}

class PlotInfo extends StatelessWidget {
  PlotInfo({this.color, this.title});

  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 20.0,
        height: 20.0,
        color: color,
      ),
      title: Text(title),
    );
  }
}

class DataPlot extends StatefulWidget {
  DataPlot({
    GlobalKey key,
    @required this.dashSpace,
    @required this.dataSet,
  }) : super(key: key);

  final int dashSpace;
  final List<charts.Series<LinearPlot, DateTime>> dataSet;

  @override
  _DataPlotState createState() => _DataPlotState();
}

class _DataPlotState extends State<DataPlot> {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: charts.TimeSeriesChart(
          widget.dataSet,
          animate: false,
          defaultRenderer: charts.LineRendererConfig(
            includeArea: true,
          ),
          primaryMeasureAxis: charts.NumericAxisSpec(
            tickFormatterSpec:
                charts.BasicNumericTickFormatterSpec.fromNumberFormat(
              NumberFormat.compact(),
            ),
            renderSpec: charts.GridlineRendererSpec(
              labelStyle: charts.TextStyleSpec(
                fontSize: 10, // size in Pts.
                color: charts.ColorUtil.fromDartColor(
                    AppConstants.of(context).kTextWhite[1]),
              ),
              lineStyle: charts.LineStyleSpec(
                  color: charts.MaterialPalette.gray.shade700,
                  dashPattern: [widget.dashSpace, widget.dashSpace]),
            ),
          ),
          domainAxis: charts.DateTimeAxisSpec(
            renderSpec: charts.GridlineRendererSpec(
              labelStyle: charts.TextStyleSpec(
                fontSize: 10,
                color: charts.ColorUtil.fromDartColor(
                    AppConstants.of(context).kTextWhite[1]),
              ),
              lineStyle: charts.LineStyleSpec(
                  color: charts.MaterialPalette.gray.shade700,
                  dashPattern: [widget.dashSpace, widget.dashSpace]),
            ),
          ),
        ),
      ),
    );
  }
}

class LinearPlot {
  const LinearPlot(this.date, this.count);

  final DateTime date;
  final num count;
}
