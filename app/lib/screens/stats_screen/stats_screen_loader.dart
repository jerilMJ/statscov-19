import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:statscov/models/api/detailed_report.dart';
import 'package:statscov/providers/latest_report_provider.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/screens/stats_screen/providers/detailed_report_provider.dart';
import 'package:statscov/shared/widgets/error_box.dart';
import 'package:statscov/shared/widgets/load_box.dart';
import 'package:statscov/providers/countries_list_provider.dart';
import 'package:statscov/screens/stats_screen/stats_screen.dart';
import 'package:statscov/shared/widgets/load_dialog_caller.dart';
import 'package:statscov/utils/dialog_manager.dart';

class StatsScreenLoader extends StatefulWidget {
  const StatsScreenLoader();

  @override
  _StatsScreenLoaderState createState() => _StatsScreenLoaderState();
}

class _StatsScreenLoaderState extends State<StatsScreenLoader> {
  final loadBox = const StatsScreenLoadBox('Fetching data...');
  final GlobalKey<State> loaderKey = GlobalKey<State>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
  }

  void _afterBuild(_) {
    DialogManager.of(context).showDialogPopup(
      context,
      loadBox,
      "statsScreenLoader",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CountriesListProvider, LatestReportsProvider>(
      builder: (_, countriesListProvider, latestReportsProvider, __) {
        Widget child = LoadDialogCaller(dialogContent: loadBox);

        if (countriesListProvider.state == CountriesListProviderState.ready) {
          if (latestReportsProvider.state == LatestReportsProviderState.ready) {
            child = MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) =>
                      DetailedReportProvider(latestReportsProvider.reports),
                ),
                ChangeNotifierProvider(
                  create: (_) => TutorialProvider(),
                ),
              ],
              child: FutureBuilder(
                future: openCache(latestReportsProvider),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return ErrorBox(
                        context: context,
                        error: snapshot.error,
                        tryAgain: () {},
                      );
                    } else {
                      return const StatsScreen();
                    }
                  } else {
                    return loadBox;
                  }
                },
              ),
            );
          } else if (latestReportsProvider.state ==
              LatestReportsProviderState.error) {
            child = ErrorBox(
              tryAgain: () => latestReportsProvider.tryFetching(),
              context: context,
              error: latestReportsProvider.error,
            );
          }
        } else if (countriesListProvider.state ==
            CountriesListProviderState.error) {
          child = ErrorBox(
            tryAgain: () {
              countriesListProvider.tryFetching();
              latestReportsProvider.tryFetching();
            },
            context: context,
            error: countriesListProvider.error,
          );
        }

        return WillPopScope(
          onWillPop: () async {
            return (countriesListProvider.state !=
                    CountriesListProviderState.loading &&
                latestReportsProvider.state !=
                    LatestReportsProviderState.loading);
          },
          child: child,
        );
      },
    );
  }

  Future openCache(LatestReportsProvider latestReportsProvider) async {
    final detailedReportsBox = await Hive.openBox('detailedReports');
    if (detailedReportsBox.isNotEmpty) {
      if ((detailedReportsBox.getAt(0) as DetailedReport).report.date !=
          latestReportsProvider.lastUpdate) {
        detailedReportsBox.clear();
      }
    }
  }

  @override
  void dispose() {
    try {
      Hive.box('detailedReports').close();
    } catch (e) {}
    super.dispose();
  }
}

class StatsScreenLoadBox extends StatelessWidget {
  const StatsScreenLoadBox(this._accompanyingText);
  final String _accompanyingText;

  @override
  Widget build(BuildContext context) {
    return LoadBox(
      _accompanyingText,
      bgImgPath: 'assets/images/individual_reports.png',
    );
  }
}
