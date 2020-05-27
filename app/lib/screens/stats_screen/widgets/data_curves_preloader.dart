import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statscov/providers/minified_report_provider.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/screens/stats_screen/widgets/data_curves.dart';
import 'package:statscov/shared/widgets/error_box.dart';
import 'package:statscov/shared/widgets/load_box.dart';

class DataCurvesPreloader extends StatelessWidget {
  const DataCurvesPreloader();

  @override
  Widget build(BuildContext context) {
    return Consumer2<MinifiedReportProvider, TutorialProvider>(
        builder: (_, minifiedReportProvider, tutorialProvider, __) {
      if (minifiedReportProvider.state == MinifiedReportProviderState.loading) {
        return const Center(
            child: const LoadBox('Fetching all country-wise reports...'));
      } else if (minifiedReportProvider.state ==
          MinifiedReportProviderState.error) {
        return ErrorBox(
          tryAgain: () => minifiedReportProvider.tryFetching(),
          context: context,
          error: minifiedReportProvider.error,
        );
      } else {
        return DataCurves(
          minifiedReportProvider.report,
          key: tutorialProvider.getKeyFor("dataCurves"),
        );
      }
    });
  }
}
