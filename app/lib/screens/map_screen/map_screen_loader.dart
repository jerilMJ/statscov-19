import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statscov/providers/latest_report_provider.dart';
import 'package:statscov/providers/minified_report_provider.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/providers/worldwide_report_provider.dart';
import 'package:statscov/screens/map_screen/map_screen.dart';
import 'package:statscov/screens/map_screen/providers/map_utility_provider.dart';
import 'package:statscov/screens/map_screen/providers/non_zero_coords_provider.dart';
import 'package:statscov/shared/widgets/error_box.dart';
import 'package:statscov/shared/widgets/load_box.dart';
import 'package:statscov/shared/widgets/load_dialog_caller.dart';
import 'package:statscov/utils/dialog_manager.dart';

class MapScreenLoader extends StatefulWidget {
  const MapScreenLoader();

  @override
  _MapScreenLoaderState createState() => _MapScreenLoaderState();
}

class _MapScreenLoaderState extends State<MapScreenLoader> {
  final loadBox = const MapScreenLoadBox('Fetching data...');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
  }

  void _afterBuild(_) {
    DialogManager.of(context).showDialogPopup(
      context,
      loadBox,
      "mapScreenLoader",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MinifiedReportProvider, LatestReportsProvider>(
      builder: (_, minifiedReportProvider, latestReportsProvider, __) {
        Widget child = LoadDialogCaller(dialogContent: loadBox);

        if (minifiedReportProvider.state == MinifiedReportProviderState.ready) {
          if (latestReportsProvider.state == LatestReportsProviderState.ready) {
            child = MultiProvider(providers: [
              ChangeNotifierProvider(
                create: (_) => WorldwideReportProvider.onlyWorldwide(
                  latestReportsProvider.reports,
                  latestReportsProvider.appDocsDirPath,
                ),
              ),
              ChangeNotifierProvider(
                create: (_) => MapUtilityProvider(
                  DateTime.parse(latestReportsProvider.reports
                      .getReportForIso('USA')
                      .date),
                ),
              ),
              ChangeNotifierProvider(
                create: (_) => TutorialProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => NonZeroCoordsProvider(
                    latestReportsProvider.reports,
                    minifiedReportProvider.report,
                    latestReportsProvider.firstDate,
                    latestReportsProvider.lastDate,
                    latestReportsProvider.totalCountries),
              ),
            ], child: const MapScreen());
          } else if (latestReportsProvider.state ==
              LatestReportsProviderState.error) {
            child = ErrorBox(
              tryAgain: () => latestReportsProvider.tryFetching(),
              context: context,
              error: latestReportsProvider.error,
            );
          }
        } else if (minifiedReportProvider.state ==
            MinifiedReportProviderState.error) {
          child = ErrorBox(
            tryAgain: () => minifiedReportProvider.tryFetching(),
            context: context,
            error: minifiedReportProvider.error,
          );
        }

        return WillPopScope(
          onWillPop: () async {
            return (minifiedReportProvider.state !=
                    MinifiedReportProviderState.loading &&
                latestReportsProvider.state !=
                    LatestReportsProviderState.loading);
          },
          child: child,
        );
      },
    );
  }
}

class MapScreenLoadBox extends StatelessWidget {
  const MapScreenLoadBox(this._accompanyingText);
  final String _accompanyingText;

  @override
  Widget build(BuildContext context) {
    return LoadBox(
      _accompanyingText,
      bgImgPath: 'assets/images/pandemic_map.png',
    );
  }
}
