import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statscov/providers/latest_report_provider.dart';
import 'package:statscov/providers/minified_report_provider.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/screens/stats_screen/widgets/data_curves.dart';
import 'package:statscov/screens/worldwide_screen/providers/worldwide_reports_provider.dart';
import 'package:statscov/screens/worldwide_screen/widgets/data_curve.dart';
import 'package:statscov/shared/widgets/error_box.dart';
import 'package:statscov/shared/widgets/load_box.dart';

class DataCurvePreloader extends StatelessWidget {
  const DataCurvePreloader();

  @override
  Widget build(BuildContext context) {
    return Consumer3<LatestReportsProvider, TutorialProvider,
            WorldwideReportsProvider>(
        builder: (_, latestReportProvider, tutorialProvider,
            worldwideReportsProvider, __) {
      if (worldwideReportsProvider.state ==
          WorldwideReportsProviderState.loading) {
        return const Center(child: const LoadBox('Fetching data...'));
      } else if (worldwideReportsProvider.state ==
          WorldwideReportsProviderState.error) {
        return ErrorBox(
          tryAgain: () => worldwideReportsProvider.tryFetching(),
          context: context,
          error: worldwideReportsProvider.error,
        );
      } else {
        return DataCurve(
          key: tutorialProvider.getKeyFor("dataCurveCard"),
        );
      }
    });
  }
}
