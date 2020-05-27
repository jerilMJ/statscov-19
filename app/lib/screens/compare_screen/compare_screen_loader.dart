import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statscov/providers/minified_report_provider.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/screens/compare_screen/compare_screen.dart';
import 'package:statscov/screens/compare_screen/providers/compare_utility_provider.dart';
import 'package:statscov/shared/widgets/error_box.dart';
import 'package:statscov/shared/widgets/load_box.dart';
import 'package:statscov/providers/countries_list_provider.dart';
import 'package:statscov/shared/widgets/load_dialog_caller.dart';
import 'package:statscov/utils/dialog_manager.dart';

class CompareScreenLoader extends StatefulWidget {
  const CompareScreenLoader();

  @override
  _CompareScreenLoaderState createState() => _CompareScreenLoaderState();
}

class _CompareScreenLoaderState extends State<CompareScreenLoader> {
  final loadBox = const CompareScreenLoadBox('Fetching Data...');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
  }

  void _afterBuild(_) {
    DialogManager.of(context).showDialogPopup(
      context,
      loadBox,
      "compareScreenLoader",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CountriesListProvider, MinifiedReportProvider>(
      builder: (_, countriesListProvider, minifiedReportProvider, __) {
        Widget child = LoadDialogCaller(dialogContent: loadBox);

        if (countriesListProvider.state == CountriesListProviderState.ready) {
          if (minifiedReportProvider.state ==
              MinifiedReportProviderState.ready) {
            child = MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) =>
                      CompareUtilityProvider(minifiedReportProvider.report),
                ),
                ChangeNotifierProvider(
                  create: (_) => TutorialProvider(),
                ),
              ],
              child: const CompareScreen(),
            );
          } else if (minifiedReportProvider.state ==
              MinifiedReportProviderState.error) {
            child = ErrorBox(
              tryAgain: () => minifiedReportProvider.tryFetching(),
              context: context,
              error: minifiedReportProvider.error,
            );
          }
        } else if (countriesListProvider.state ==
            CountriesListProviderState.error) {
          child = ErrorBox(
            tryAgain: () {
              countriesListProvider.tryFetching();
              minifiedReportProvider.tryFetching();
            },
            context: context,
            error: countriesListProvider.error,
          );
        }

        return WillPopScope(
          onWillPop: () async {
            return (countriesListProvider.state !=
                    CountriesListProviderState.loading &&
                minifiedReportProvider.state !=
                    MinifiedReportProviderState.loading);
          },
          child: child,
        );
      },
    );
  }
}

class CompareScreenLoadBox extends StatelessWidget {
  const CompareScreenLoadBox(this._accompanyingText);
  final String _accompanyingText;

  @override
  Widget build(BuildContext context) {
    return LoadBox(
      _accompanyingText,
      bgImgPath: 'assets/images/compare_reports.png',
    );
  }
}
