import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong/latlong.dart' as latlong;
import 'package:provider/provider.dart';
import 'package:statscov/models/api/coordinates.dart';
import 'package:statscov/models/api/covid_compiled/report.dart';
import 'package:statscov/models/api/covid_compiled/reports.dart';
import 'package:statscov/providers/latest_report_provider.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/providers/worldwide_report_provider.dart';
import 'package:statscov/screens/map_screen/providers/map_utility_provider.dart';
import 'package:statscov/screens/map_screen/providers/non_zero_coords_provider.dart';
import 'package:statscov/screens/map_screen/utils/map_screen_tutorial.dart';
import 'package:statscov/screens/map_screen/widgets/map_controllers.dart';
import 'package:statscov/screens/map_screen/widgets/world_map.dart';
import 'package:statscov/shared/widgets/error_box.dart';
import 'package:statscov/shared/widgets/load_box.dart';
import 'package:statscov/utils/constants.dart';
import 'package:statscov/utils/date_utils.dart';
import 'package:statscov/utils/dialog_manager.dart';

class MapScreen extends StatefulWidget {
  const MapScreen();

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();

  static final PopupController _popupLayerController = PopupController();

  DateUtils dateUtils = DateUtils();

  TutorialProvider _tutorialProvider;
  MapScreenTutorial _mapScreenTutorial;

  @override
  void initState() {
    super.initState();
    _tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    _mapScreenTutorial = MapScreenTutorial(context);
    _tutorialProvider.screenTutorial = _mapScreenTutorial;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<MapUtilityProvider, WorldwideReportProvider,
        LatestReportsProvider>(
      builder: (_, mapUtilityProvider, worldwideReportProvider,
          latestReportsProvider, __) {
        Widget child = Container();

        if (worldwideReportProvider.state ==
            WorldwideReportProviderState.ready) {
          WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(
              const Duration(milliseconds: 100),
              () => DialogManager.of(context).clearDialogs()));

          child = WillPopScope(
            onWillPop: () async {
              return _mapScreenTutorial.tutorialFinished;
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(AppConstants.of(context).kAppTitle),
                leading: IconButton(
                  tooltip: 'Home',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                actions: <Widget>[
                  IconButton(
                    tooltip: 'Help',
                    icon: const Icon(Icons.help),
                    onPressed: () {
                      _tutorialProvider.screenTutorial
                          .showTutorial(0)
                          .catchError((_) {});
                    },
                  ),
                ],
              ),
              body: Consumer<NonZeroCoordsProvider>(
                builder: (_, nonZeroCoordsProvider, __) {
                  if (nonZeroCoordsProvider.state ==
                      NonZeroCoordsProviderState.ready) {
                    final markersList = fetchMarkersForDate(
                      mapUtilityProvider.date,
                      mapUtilityProvider.allListedCountriesInfectedOn,
                      worldwideReportProvider.report,
                      nonZeroCoordsProvider.nonZeroCoords,
                      latestReportsProvider.reports,
                    );

                    return Column(
                      children: <Widget>[
                        Expanded(
                          child: WorldMap(
                            key: _tutorialProvider.getKeyFor("worldMap"),
                            markers: markersList,
                            mapController: mapController,
                            popupLayerController: _popupLayerController,
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable:
                              mapUtilityProvider.percentageNotifier,
                          builder: (_, perc, __) => TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 1000),
                            tween: Tween(
                                begin: mapUtilityProvider.prevPercentage ?? 0.0,
                                end: perc ?? 1.0),
                            builder: (_, perc, __) {
                              return LinearProgressIndicator(
                                value: perc,
                                backgroundColor:
                                    AppConstants.of(context).kDarkElevations[1],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppConstants.of(context)
                                      .kAccentColor
                                      .withOpacity(0.5),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color:
                                    AppConstants.of(context).kDarkElevations[0],
                                blurRadius: 5.0),
                          ]),
                          child: const MapControllers(),
                        ),
                      ],
                    );
                  } else if (nonZeroCoordsProvider.state ==
                      NonZeroCoordsProviderState.error) {
                    return ErrorBox(
                      tryAgain: () {},
                      context: context,
                      error: nonZeroCoordsProvider.error,
                    );
                  } else {
                    return Column(
                      children: <Widget>[
                        const Expanded(
                          child: const LoadBox(
                            'Filtering and cleaning data.. Just a moment..',
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable:
                              nonZeroCoordsProvider.percentageNotifier,
                          builder: (_, perc, __) => TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 1000),
                            tween: Tween(
                                begin: mapUtilityProvider.prevPercentage ?? 0.0,
                                end: perc ?? 1.0),
                            builder: (_, perc, __) {
                              return Container(
                                height: 20.0,
                                child: LinearProgressIndicator(
                                  value: perc,
                                  backgroundColor: AppConstants.of(context)
                                      .kDarkElevations[1],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppConstants.of(context).kTextWhite[1],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          );
        } else if (worldwideReportProvider.state ==
            WorldwideReportProviderState.error) {
          child = ErrorBox(
              tryAgain: () => worldwideReportProvider.tryFetching(),
              context: context,
              error: worldwideReportProvider.error);
        }

        return WillPopScope(
          onWillPop: () async {
            return (worldwideReportProvider.state !=
                WorldwideReportProviderState.loading);
          },
          child: child,
        );
      },
    );
  }

  List<Marker> fetchMarkersForDate(
    DateTime currentDate,
    DateTime fallBack,
    Report worldwideReport,
    Map<String, Map<String, Coordinates>> nonZeroCoords,
    Reports latestReports,
  ) {
    DateTime date;
    if (nonZeroCoords[dateUtils.toDateOnlyString(currentDate)] != null) {
      date = currentDate;
    } else {
      date = fallBack;
    }

    return nonZeroCoords[dateUtils.toDateOnlyString(date)]
        .map((iso, coords) {
          return MapEntry(
              iso,
              getMarker(15.0, latestReports.getReportForIso(iso), coords,
                  worldwideReport));
        })
        .values
        .toList();
  }

  static Marker getMarker(
      double size, Report report, Coordinates coords, Report worldwideReport) {
    final percentage = report.confirmed * 100 / worldwideReport.confirmed;
    final opacity = 0.5;
    var color;

    if (percentage > 20.0) {
      color = Colors.red.shade200.withOpacity(opacity);
    } else if (percentage > 10.0) {
      color = Colors.deepOrange.shade200.withOpacity(opacity);
    } else if (percentage > 5.0) {
      color = Colors.orange.shade200.withOpacity(opacity);
    } else if (percentage > 2.5) {
      color = Colors.yellow.shade200.withOpacity(opacity);
    } else {
      color = Colors.grey.shade200.withOpacity(opacity);
    }

    return Marker(
      width: size,
      height: size,
      point: latlong.LatLng(coords.lat * 1.0, coords.long * 1.0),
      builder: (ctx) => Listener(
        onPointerDown: (_) {
          _popupLayerController.togglePopup(Marker(
              point: latlong.LatLng(coords.lat * 1.0, coords.long * 1.0)));
        },
        onPointerUp: (_) {
          _popupLayerController.togglePopup(Marker(
              point: latlong.LatLng(coords.lat * 1.0, coords.long * 1.0)));
        },
        child: Icon(
          Icons.place,
          color: color,
        ),
      ),
    );
  }
}
