import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statscov/models/api/covid_minified/minified_report.dart';
import 'package:charts_flutter/flutter.dart' as charts hide Axis;
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/screens/stats_screen/providers/detailed_report_provider.dart';
import 'package:statscov/shared/widgets/ui_card.dart';
import 'package:statscov/utils/constants.dart';

class DataCurves extends StatefulWidget {
  DataCurves(this.report, {GlobalKey key}) : super(key: key);
  final MinifiedReport report;

  @override
  _DataCurvesState createState() => _DataCurvesState();
}

class _DataCurvesState extends State<DataCurves>
    with AutomaticKeepAliveClientMixin {
  String _selectedCountry;
  int dashSpace = 4;
  bool showInfo;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    showInfo = false;

    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
  }

  void _afterBuild(_) async {
    TutorialProvider tutorialProvider =
        Provider.of<TutorialProvider>(context, listen: false);
    tutorialProvider.screenTutorial.tutorialNotFinished();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shown = (await prefs.getBool('seenStatsTut3')) ?? false;

    if (!shown) {
      Future.delayed(
        Duration(milliseconds: tutorialProvider.shortTutorialDelay),
        () => tutorialProvider.screenTutorial.showTutorial(3),
      );
      await prefs.setBool('seenStatsTut3', true);
    } else {
      tutorialProvider.screenTutorial.tutorialIsFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<DetailedReportProvider>(
      builder: (_, detailedReportProvider, __) {
        _selectedCountry =
            detailedReportProvider.detailedReport.report.countryName;
        return Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: UiCard(
                          child: DataPlot(
                            widget: widget,
                            selectedCountry: _selectedCountry,
                            dashSpace: dashSpace,
                            dataSet: _createTotalCasesCurves(
                              widget.report,
                              _selectedCountry,
                              detailedReportProvider.rollingAveragePeriod
                                  .toInt(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: UiCard(
                          child: ValueListenableBuilder(
                            valueListenable: detailedReportProvider.rapNotifier,
                            builder: (_, rap, __) => Stack(
                              children: <Widget>[
                                DataPlot(
                                  widget: widget,
                                  selectedCountry: _selectedCountry,
                                  dashSpace: dashSpace,
                                  dataSet: _createDailyCasesCurve(
                                    widget.report,
                                    _selectedCountry,
                                    rap.toInt(),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: Text(
                                      'Rolling Average: ${rap.toInt().toString()}',
                                      style: TextStyle(
                                        color: AppConstants.of(context)
                                            .kTextWhite[1],
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: showInfo ? 1.0 : 0.0,
                    child: Container(
                      color: AppConstants.of(context).kDarkElevations[0],
                      child: Column(
                        children: zip([
                          ['Confirmed', 'Recovered', 'Deaths'],
                          [
                            Colors.blue.shade300,
                            Colors.green.shade300,
                            Colors.red.shade300,
                          ],
                        ])
                            .map(
                              (pair) => Expanded(
                                child: PlotInfo(
                                  title: pair[0],
                                  color: pair[1],
                                ),
                              ),
                            )
                            .toList()
                              ..add(
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0, vertical: 0.0),
                                    child: Text(
                                      'Showing the total amount of each cases each day',
                                      style: TextStyle(
                                          color: AppConstants.of(context)
                                              .kTextWhite[1]),
                                    ),
                                  ),
                                ),
                              )
                              ..add(Expanded(
                                child: PlotInfo(
                                  color: charts.ColorUtil.toDartColor(
                                    charts.MaterialPalette.teal.shadeDefault,
                                  ),
                                  title: 'Daily Cases',
                                ),
                              ))
                              ..add(
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0, vertical: 0.0),
                                    child: Text(
                                      'Showing the no. of new cases each day starting from the very first case',
                                      style: TextStyle(
                                          color: AppConstants.of(context)
                                              .kTextWhite[1]),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: detailedReportProvider.rapNotifier,
                    builder: (_, rap, __) => Slider(
                      activeColor: AppConstants.of(context).kDarkElevations[2],
                      inactiveColor:
                          AppConstants.of(context).kDarkElevations[1],
                      value: rap,
                      onChanged: (val) {
                        detailedReportProvider.setRollingAveragePeriod(val);
                      },
                      min: 1.0,
                      max: 10.0,
                      label: 'Rolling average period',
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Info',
                  icon: Icon(
                    Icons.info,
                    color: AppConstants.of(context).kTextWhite[2],
                  ),
                  onPressed: () {
                    setState(() {
                      showInfo = !showInfo;
                    });
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  List<charts.Series<LinearPlot, DateTime>> _createTotalCasesCurves(
    MinifiedReport report,
    String selectedCountry,
    int rollingAveragePeriod,
  ) {
    final cases = report.getCases(selectedCountry);
    final datas = [];

    [0, 1, 2].forEach((no) {
      datas.add(cases
          .asMap()
          .map((index, info) {
            final start = index - rollingAveragePeriod >= 0
                ? index - rollingAveragePeriod
                : index;
            // final end = index == start ? index + 1 : index;
            final end = index + rollingAveragePeriod < cases.length
                ? index + rollingAveragePeriod
                : cases.length;

            final counts = [info.confirmed, info.recovered, info.deaths];

            final sample = cases.sublist(start, end);
            final rollingAverage =
                sample.map((info) => counts[no]).reduce((a, b) => a + b) /
                    sample.length;
            return MapEntry(
                index, LinearPlot(DateTime.parse(info.date), rollingAverage));
          })
          .values
          .toList());
    });

    final dataConfirmed = datas[0];

    final dataRecovered = datas[1];

    final dataDeaths = datas[2];

    return [
      _createSeries(dataConfirmed, 'Confirmed',
          charts.ColorUtil.fromDartColor(Colors.blue.shade300)),
      _createSeries(dataRecovered, 'Recovered',
          charts.ColorUtil.fromDartColor(Colors.green.shade300)),
      _createSeries(dataDeaths, 'Deaths',
          charts.ColorUtil.fromDartColor(Colors.red.shade300)),
    ];
  }

  List<charts.Series<LinearPlot, DateTime>> _createDailyCasesCurve(
    MinifiedReport report,
    String selectedCountry,
    int rollingAveragePeriod,
  ) {
    var prev = 0;
    final filteredCases = report.getCases(selectedCountry);
    filteredCases.removeRange(
        0, filteredCases.indexWhere((country) => country.confirmed > 0));

    final dataDaily = filteredCases.map((info) {
      final count = info.confirmed - prev;
      prev = info.confirmed;
      return MapEntry(info.date, count);
    }).toList();

    final plots = dataDaily
        .asMap()
        .map((index, info) {
          final start = index - rollingAveragePeriod >= 0
              ? index - rollingAveragePeriod
              : index;
          // final end = index == start ? index + 1 : index;
          final end = index + rollingAveragePeriod < dataDaily.length
              ? index + rollingAveragePeriod
              : dataDaily.length;

          final sample = dataDaily.sublist(start, end);
          final rollingAverage =
              sample.map((info) => info.value).reduce((a, b) => a + b) /
                  sample.length;
          return MapEntry(
              index, LinearPlot(DateTime.parse(info.key), rollingAverage));
        })
        .values
        .toList();

    return [
      _createSeries(
          plots, 'Daily', charts.ColorUtil.fromDartColor(Colors.teal.shade300)),
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
    @required this.widget,
    @required this.selectedCountry,
    @required this.dashSpace,
    @required this.dataSet,
  }) : super(key: key);

  final DataCurves widget;
  final String selectedCountry;
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
                  AppConstants.of(context).kTextWhite[2],
                ),
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
                  AppConstants.of(context).kTextWhite[2],
                ),
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
