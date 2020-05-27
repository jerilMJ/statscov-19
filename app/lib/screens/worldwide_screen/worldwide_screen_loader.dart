import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statscov/providers/latest_report_provider.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/providers/worldwide_report_provider.dart';
import 'package:statscov/screens/worldwide_screen/providers/ordered_reports_provider.dart';
import 'package:statscov/screens/worldwide_screen/worldwide_screen.dart';
import 'package:statscov/shared/widgets/error_box.dart';
import 'package:statscov/shared/widgets/load_box.dart';
import 'package:statscov/shared/widgets/load_dialog_caller.dart';
import 'package:statscov/utils/dialog_manager.dart';
import 'package:statscov/utils/temp_cache.dart';

class WorldwideScreenLoader extends StatefulWidget {
  const WorldwideScreenLoader();

  @override
  _WorldwideScreenLoaderState createState() => _WorldwideScreenLoaderState();
}

class _WorldwideScreenLoaderState extends State<WorldwideScreenLoader> {
  final loadBox = const WorldwideScreenLoadBox('Fetching data...');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
  }

  void _afterBuild(_) {
    DialogManager.of(context).showDialogPopup(
      context,
      loadBox,
      "worldwideScreenLoader",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LatestReportsProvider>(
      builder: (_, latestReportsProvider, __) {
        Widget child = LoadDialogCaller(dialogContent: loadBox);

        if (latestReportsProvider.state == LatestReportsProviderState.ready) {
          child = MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => WorldwideReportProvider(
                  latestReportsProvider.reports,
                  latestReportsProvider.appDocsDirPath,
                ),
              ),
              ChangeNotifierProvider(
                create: (_) => TutorialProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => OrderedReportsProvider(
                  latestReportsProvider.firstDate,
                  latestReportsProvider.lastDate,
                  TempCache.of(context),
                ),
              ),
            ],
            child: const WorldwideScreen(),
          );
        } else if (latestReportsProvider.state ==
            LatestReportsProviderState.error) {
          child = ErrorBox(
            tryAgain: () => latestReportsProvider.tryFetching(),
            context: context,
            error: latestReportsProvider.error,
          );
        }

        return WillPopScope(
          onWillPop: () async {
            return (latestReportsProvider.state !=
                LatestReportsProviderState.loading);
          },
          child: child,
        );
      },
    );
  }
}

class WorldwideScreenLoadBox extends StatelessWidget {
  const WorldwideScreenLoadBox(this._accompanyingText);
  final String _accompanyingText;

  @override
  Widget build(BuildContext context) {
    return LoadBox(
      _accompanyingText,
      bgImgPath: 'assets/images/worldwide_report.png',
    );
  }
}
