import 'dart:async';
import 'package:charts_flutter/flutter.dart' as charts hide TextStyle;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:statscov/models/api/covid_minified/minified_report.dart';
import 'package:statscov/models/api/iso_name.dart';
import 'package:statscov/screens/compare_screen/providers/compare_utility_provider.dart';
import 'package:statscov/utils/constants.dart';
import 'package:statscov/utils/date_utils.dart';

enum GraphMode { confirmed, recovered, deaths }

class LinearPlot {
  const LinearPlot(this.date, this.count);

  final DateTime date;
  final num count;
}

class GraphCard extends StatefulWidget {
  const GraphCard(
    this._report,
    this._mode, {
    this.tabIndex,
    this.isPercentage = false,
  });

  final MinifiedReport _report;
  final GraphMode _mode;
  final bool isPercentage;
  final int tabIndex;

  @override
  _GraphCardState createState() => _GraphCardState();
}

class _GraphCardState extends State<GraphCard>
    with AutomaticKeepAliveClientMixin {
  final dashSpace = 4;
  List<charts.SeriesDatum> _selectedDatum;
  StreamController _selectedInfoStreamController;
  Stream _selectedInfoStream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedInfoStreamController = StreamController.broadcast();
    _selectedInfoStream = _selectedInfoStreamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<CompareUtilityProvider>(
      builder: (_, compareUtilityProvider, __) {
        Widget child;

        if (compareUtilityProvider.selected.cases.length != 0) {
          child = FutureBuilder(
            future: _createGraph(context, widget._mode, widget._report),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  children: <Widget>[
                    charts.TimeSeriesChart(
                      snapshot.data,
                      animate: false,
                      animationDuration: const Duration(milliseconds: 1500),
                      defaultRenderer: charts.LineRendererConfig(),
                      selectionModels: [
                        charts.SelectionModelConfig(
                          type: charts.SelectionModelType.info,
                          updatedListener: _onSelectionChanged,
                        )
                      ],
                      primaryMeasureAxis: charts.NumericAxisSpec(
                        tickFormatterSpec: charts.BasicNumericTickFormatterSpec
                            .fromNumberFormat(
                          widget.isPercentage
                              ? NumberFormat.percentPattern()
                              : NumberFormat.compact(),
                        ),
                        renderSpec: charts.GridlineRendererSpec(
                          // Tick and Label styling here.
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 10, // size in Pts.
                            color: charts.MaterialPalette.white,
                          ),

                          lineStyle: charts.LineStyleSpec(
                              color: charts.MaterialPalette.gray.shade700,
                              dashPattern: [dashSpace, dashSpace]),
                        ),
                      ),
                      domainAxis: charts.DateTimeAxisSpec(
                        renderSpec: charts.GridlineRendererSpec(
                          // Tick and Label styling here.
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 10, // size in Pts.
                            color: charts.MaterialPalette.white,
                          ),

                          lineStyle: charts.LineStyleSpec(
                              color: charts.MaterialPalette.gray.shade700,
                              dashPattern: [dashSpace, dashSpace]),
                        ),
                      ),
                    ),
                    StreamBuilder(
                      stream: _selectedInfoStream,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData && snapshot.data.isNotEmpty) {
                          return Stack(
                            children: <Widget>[
                              SelectedInfo(snapshot.data ?? [],
                                  isPercentage: widget.isPercentage),
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  splashColor: Colors.transparent,
                                  tooltip: 'Close',
                                  icon: Icon(
                                    Icons.close,
                                    color:
                                        AppConstants.of(context).kTextWhite[1],
                                  ),
                                  onPressed: () => _selectedInfoStreamController
                                      .add(<charts.SeriesDatum>[]),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                );
              } else {
                return Container();
              }
            },
          );
        } else {
          child = Container();
        }

        return Container(
          width: MediaQuery.of(context).size.width,
          child: child,
        );
      },
    );
  }

  _onSelectionChanged(charts.SelectionModel model) {
    _selectedDatum = model.selectedDatum;

    if (_selectedDatum.isNotEmpty) {
      _selectedInfoStreamController.add(_selectedDatum);
    }
  }

  Future<List<charts.Series<LinearPlot, DateTime>>> _createGraph(
      BuildContext context, GraphMode mode, MinifiedReport report) async {
    final compProvider =
        Provider.of<CompareUtilityProvider>(context, listen: false);

    compProvider.graphs = compProvider.graphs ?? {};
    compProvider.graphs[mode] = compProvider.graphs[mode] ?? {};
    compProvider.disabledGraphs = compProvider.disabledGraphs ?? {};
    compProvider.disabledGraphs[mode] = compProvider.disabledGraphs[mode] ?? {};

    if (compProvider.graphs[mode].isNotEmpty && !compProvider.dateHasChanged) {
      return compProvider.graphs[mode].values.toList();
    }

    Map<String, List<LinearPlot>> data = await compute(_createData, {
      'report': report,
      'disabled': compProvider.disabled,
      'mode':
          mode == GraphMode.confirmed ? 0 : mode == GraphMode.recovered ? 1 : 2,
      'start_date': compProvider.startDate,
      'end_date': compProvider.endDate,
    });

    compProvider.dateHasChanged = false;

    List<charts.Series<LinearPlot, DateTime>> graph = [];

    data.forEach((iso, plots) {
      final chart = charts.Series<LinearPlot, DateTime>(
        id: iso,
        seriesColor: compProvider.getColor(iso),
        domainFn: (LinearPlot plot, _) => plot.date,
        measureFn: (LinearPlot plot, _) => plot.count,
        data: plots,
        strokeWidthPxFn: (_, __) => 3.5,
      );

      graph.add(chart);

      compProvider.graphs[mode] = compProvider.graphs[mode] ?? {};
      compProvider.graphs[mode][iso] = chart;
    });

    return graph;
  }

  static Map<String, List<LinearPlot>> _createData(Map<String, dynamic> args) {
    final MinifiedReport report = args['report'];
    final List<String> disabled = args['disabled'];
    final int mode = args['mode'];
    final String startDateString = args['start_date'];
    final String endDateString = args['end_date'];

    Map<String, List<LinearPlot>> data = {};

    report.cases.forEach((iso, infos) {
      if (!disabled.contains(iso)) {
        final filtered = infos.where((countryCase) {
          var thisDate = DateTime.parse(countryCase.date);
          var startDate = DateTime.parse(startDateString);
          var endDate = DateTime.parse(endDateString);

          return thisDate.compareTo(startDate) >= 0 &&
              thisDate.compareTo(endDate) <= 0;
        }).toList();

        switch (mode) {
          case 0:
            data[iso] = filtered.map((info) {
              return LinearPlot(DateTime.parse(info.date), info.confirmed);
            }).toList();
            break;

          case 1:
            data[iso] = filtered.map((info) {
              return LinearPlot(
                DateTime.parse(info.date),
                info.confirmed == 0 ? 0 : info.recovered / info.confirmed,
              );
            }).toList();
            break;

          case 2:
            data[iso] = filtered.map((info) {
              return LinearPlot(
                DateTime.parse(info.date),
                info.confirmed == 0 ? 0 : info.deaths / info.confirmed,
              );
            }).toList();
            break;
        }
      }
    });
    return data;
  }

  @override
  void dispose() {
    _selectedInfoStreamController.close();
    super.dispose();
  }
}

class SelectedInfo extends StatefulWidget {
  const SelectedInfo(this._selectedDatum, {@required this.isPercentage});

  final List<charts.SeriesDatum> _selectedDatum;
  final bool isPercentage;

  @override
  _SelectedInfoState createState() => _SelectedInfoState();
}

class _SelectedInfoState extends State<SelectedInfo> {
  double height;
  List<charts.SeriesDatum> selectedDatum;

  @override
  void initState() {
    super.initState();
    sortDatum();
  }

  void sortDatum() {
    selectedDatum = List.from(widget._selectedDatum);

    selectedDatum.sort(
        (s1, s2) => s2.datum.count.round().compareTo(s1.datum.count.round()));
  }

  @override
  void didUpdateWidget(SelectedInfo oldWidget) {
    if (oldWidget._selectedDatum != widget._selectedDatum) {
      setState(() {
        sortDatum();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (selectedDatum.isNotEmpty) {
      return LayoutBuilder(
        builder: (_, constraints) {
          final myWidth = constraints.constrainWidth();
          final myHeight = constraints.constrainHeight();

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: AppConstants.of(context).kSurfaceColor.withOpacity(0.7),
            ),
            height: height ?? myHeight / 2.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      DateUtils().prettifyDate(selectedDatum.first.datum.date)),
                ),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: myWidth * 0.85,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: selectedDatum.length,
                          itemBuilder: (_, index) {
                            return ListTile(
                              leading: Icon(
                                Icons.radio_button_checked,
                                color: charts.ColorUtil.toDartColor(
                                  selectedDatum[index].series.colorFn(null),
                                ),
                              ),
                              title: Text(
                                IsoName().iso3ToCountry(
                                    selectedDatum[index].series.displayName),
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(
                                widget.isPercentage
                                    ? NumberFormat.percentPattern().format(
                                        selectedDatum[index].datum.count)
                                    : NumberFormat.compact().format(
                                        selectedDatum[index]
                                            .datum
                                            .count
                                            .round()),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          splashColor: Colors.transparent,
                          tooltip: 'Expand / Collapse',
                          icon: Icon(
                            () {
                              if (height != null && height == myHeight) {
                                return Icons.expand_less;
                              } else {
                                return Icons.expand_more;
                              }
                            }(),
                            color: AppConstants.of(context).kTextWhite[1],
                          ),
                          onPressed: () {
                            if (height != null && height == myHeight) {
                              height = myHeight / 2.5;
                            } else {
                              height = myHeight;
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
