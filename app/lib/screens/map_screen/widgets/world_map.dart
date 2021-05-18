import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statscov/providers/latest_report_provider.dart';
import 'package:statscov/providers/minified_report_provider.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:latlong/latlong.dart' as latlong;
import 'package:statscov/screens/map_screen/providers/map_utility_provider.dart';
import 'package:statscov/shared/widgets/ui_card.dart';
import 'package:statscov/utils/constants.dart';

class WorldMap extends StatefulWidget {
  const WorldMap({
    GlobalKey key,
    @required this.markers,
    @required this.mapController,
    @required PopupController popupLayerController,
  })  : _popupLayerController = popupLayerController,
        super(key: key);

  final MapController mapController;
  final PopupController _popupLayerController;
  final List<Marker> markers;

  @override
  _WorldMapState createState() => _WorldMapState();
}

class _WorldMapState extends State<WorldMap> {
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
    bool shown = (await prefs.getBool('seenMapTut0')) ?? false;
    if (!shown) {
      Future.delayed(
        Duration(milliseconds: tutorialProvider.tutorialDelay),
        () => tutorialProvider.screenTutorial.showTutorial(0),
      );
      await prefs.setBool('seenMapTut0', true);
    } else {
      tutorialProvider.screenTutorial.tutorialIsFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<MinifiedReportProvider, LatestReportsProvider,
        MapUtilityProvider>(
      builder: (_, minifiedReportProvider, latestReportsProvider,
              mapUtilityProvider, __) =>
          FlutterMap(
        mapController: widget.mapController,
        options: MapOptions(
            center: latlong.LatLng(50.0, 50.0),
            plugins: [PopupMarkerPlugin()],
            zoom: 2.0,
            minZoom: 0.5,
            maxZoom: 7.0,
            onTap: (_) => widget._popupLayerController.hidePopup()),
        layers: [
          TileLayerOptions(
            backgroundColor: Colors.black,
            urlTemplate:
                "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png",
            subdomains: ['a', 'b', 'c'],
            keepBuffer: 0,
          ),
          PopupMarkerLayerOptions(
            popupSnap: PopupSnap.top,
            popupController: widget._popupLayerController,
            markers: widget.markers,
            popupBuilder: (_, marker) {
              var report, countryCase;
              try {
                report = latestReportsProvider.reports.reports.values
                    .firstWhere((report) =>
                        report.coordinates.lat == marker.point.latitude &&
                        report.coordinates.long == marker.point.longitude);

                countryCase = minifiedReportProvider.report
                    .getCases(report.countryName)
                    .firstWhere((countryCase) =>
                        DateTime.parse(countryCase.date) ==
                        mapUtilityProvider.date);
              } catch (e) {
                countryCase = null;
              }

              return Container(
                width: 250.0,
                height: 150.0,
                padding: const EdgeInsets.only(left: 9.0),
                child: CustomPaint(
                  painter: MarkerPopupPointerPainter(
                      AppConstants.of(context).kDarkElevations[1]),
                  child: UiCard(
                    color: AppConstants.of(context).kDarkElevations[1],
                    elevation: 10.0,
                    child: countryCase == null
                        ? const Text("Data not yet known\nCheck later")
                        : ListView(
                            children: <Widget>[
                              Text(
                                '${countryCase.date}\n'
                                '${report.countryName}\n',
                                style: TextStyle(
                                    color:
                                        AppConstants.of(context).kTextWhite[1]),
                              ),
                              Text(
                                'Confirmed: ${countryCase.confirmed}\n'
                                'Recovered: ${countryCase.recovered}\n'
                                'Deaths: ${countryCase.deaths}',
                                style: TextStyle(
                                    color:
                                        AppConstants.of(context).kTextWhite[1]),
                              ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MarkerPopupPointerPainter extends CustomPainter {
  const MarkerPopupPointerPainter(this.fillColor);

  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    var offset = 10.0;
    var pointerWidth = 10.0;

    var firstPoint =
        Offset(size.width / 2 - pointerWidth, size.height - offset);
    var secondPoint = Offset(size.width / 2, size.height + 10.0);
    var thirdPoint =
        Offset(size.width / 2 + pointerWidth, size.height - offset);
    Paint paint = Paint();
    paint.color = fillColor;
    paint.style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(firstPoint.dx, firstPoint.dy);
    path.lineTo(secondPoint.dx, secondPoint.dy);
    path.lineTo(thirdPoint.dx, thirdPoint.dy);
    path.lineTo(firstPoint.dx, firstPoint.dy);
    path.close();
    canvas.drawPath(path, paint);

    canvas.drawLine(firstPoint, secondPoint, paint);
    canvas.drawLine(secondPoint, thirdPoint, paint);
    canvas.drawLine(thirdPoint, firstPoint, paint);
  }

  @override
  bool shouldRepaint(MarkerPopupPointerPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(MarkerPopupPointerPainter oldDelegate) => false;
}
