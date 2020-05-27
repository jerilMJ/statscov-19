import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/screens/stats_screen/providers/detailed_report_provider.dart';
import 'package:statscov/screens/stats_screen/utils/stats_screen_tutorial.dart';
import 'package:statscov/screens/stats_screen/widgets/counters.dart';
import 'package:statscov/screens/stats_screen/widgets/data_curves_preloader.dart';
import 'package:statscov/screens/stats_screen/widgets/empty.dart';
import 'package:statscov/screens/stats_screen/widgets/selected_country_indicator.dart';
import 'package:statscov/shared/widgets/country_search_delegate.dart';
import 'package:statscov/shared/widgets/error_box.dart';
import 'package:statscov/shared/widgets/load_box.dart';
import 'package:statscov/screens/stats_screen/widgets/bar_charts.dart';
import 'package:statscov/providers/countries_list_provider.dart';
import 'package:statscov/utils/constants.dart';
import 'package:statscov/utils/dialog_manager.dart';
import 'package:statscov/utils/tab_bar_choice.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen();

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  TutorialProvider _tutorialProvider;
  StatsScreenTutorial _statsScreenTutorial;
  TabController _tabController;

  final List<TabBarChoice> choices = <TabBarChoice>[
    const TabBarChoice(icon: Icons.looks_two),
    const TabBarChoice(icon: Icons.table_chart),
    const TabBarChoice(icon: Icons.show_chart),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);

    _tabController = TabController(length: choices.length, vsync: this);
    _statsScreenTutorial = StatsScreenTutorial(context, _tabController);
    _tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    _tutorialProvider.screenTutorial = _statsScreenTutorial;
  }

  void _afterBuild(_) async {
    _tutorialProvider.screenTutorial.tutorialNotFinished();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shown = (await prefs.getBool('seenStatsTut0')) ?? false;

    if (!shown) {
      await Future.delayed(
        Duration(milliseconds: _tutorialProvider.tutorialDelay),
        () => _tutorialProvider.screenTutorial.showTutorial(0),
      );
      await prefs.setBool('seenStatsTut0', true);
    } else {
      _tutorialProvider.screenTutorial.tutorialIsFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return _statsScreenTutorial.tutorialFinished;
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(
            AppConstants.of(context).kAppTitle,
            style: const TextStyle(fontSize: 20.0),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Home',
          ),
          actions: <Widget>[
            SearchOption(
              key: _tutorialProvider.getKeyFor("searchOption"),
            ),
            Consumer<DetailedReportProvider>(
              builder: (_, detailedReportProvider, __) => PopupMenuButton(
                onSelected: (val) {
                  switch (val) {
                    case 'pin':
                      detailedReportProvider.pinCountry();
                      break;
                    case 'help':
                      _tutorialProvider.screenTutorial
                          .showTutorial(_tabController.index + 1)
                          .catchError((_) =>
                              _tutorialProvider.screenTutorial.showTutorial(0));
                      break;
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'pin',
                    child: const Text('Pin'),
                  ),
                  const PopupMenuItem(
                    value: 'help',
                    child: const Text('Help'),
                  ),
                ],
                padding: EdgeInsets.zero,
                offset: Offset(0.0, kToolbarHeight),
                tooltip: 'Options',
              ),
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.purple.shade200,
            unselectedLabelColor: AppConstants.of(context).kDarkElevations[2],
            indicatorColor: AppConstants.of(context).kDarkElevations[2],
            controller: _tabController,
            isScrollable: false,
            tabs: zip([
              choices,
              [
                _tutorialProvider.getKeyFor("tabOne"),
                _tutorialProvider.getKeyFor("tabTwo"),
                _tutorialProvider.getKeyFor("tabThree")
              ]
            ]).map(
              (pair) {
                return Tab(
                  key: pair[1],
                  icon: Icon((pair[0] as TabBarChoice).icon),
                );
              },
            ).toList(),
          ),
        ),
        body: StatsWindow(tabController: _tabController),
        bottomSheet: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color: AppConstants.of(context).kSurfaceColor, blurRadius: 5.0),
          ]),
          child: BottomSheet(
            backgroundColor: AppConstants.of(context).kDarkElevations[0],
            enableDrag: false,
            builder: (_) => const SelectedCountryIndicator(),
            onClosing: () {},
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class StatsWindow extends StatelessWidget {
  StatsWindow({
    @required TabController tabController,
  }) : _tabController = tabController;

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(
        const Duration(milliseconds: 100),
        () => DialogManager.of(context).clearDialogs()));

    return LayoutBuilder(
      builder: (_, constraints) => Container(
        height: constraints.constrainHeight() - kToolbarHeight,
        child: Consumer2<DetailedReportProvider, TutorialProvider>(
          builder: (_, detailedReportProvider, tutorialProvider, __) {
            if (detailedReportProvider.state ==
                DetailedReportProviderState.ready) {
              return TabBarView(
                controller: _tabController,
                children: <Widget>[
                  NumberCards(
                    key: tutorialProvider.getKeyFor("numberCards"),
                  ),
                  BarChartCards(
                    key: tutorialProvider.getKeyFor("barChartCards"),
                  ),
                  const DataCurvesPreloader(),
                ],
              );
            } else if (detailedReportProvider.state ==
                DetailedReportProviderState.loading) {
              return LoadingStats(detailedReportProvider);
            } else if (detailedReportProvider.state ==
                DetailedReportProviderState.error) {
              return Center(
                child: ErrorBox(
                  tryAgain: () => detailedReportProvider.setDetailedReport(
                    detailedReportProvider.isoOnError,
                  ),
                  context: context,
                  error: detailedReportProvider.error,
                ),
              );
            } else {
              return Empty();
            }
          },
        ),
      ),
    );
  }
}

class LoadingStats extends StatelessWidget {
  const LoadingStats(this._detailedReportProvider);

  final DetailedReportProvider _detailedReportProvider;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const LoadBox('Checking cache & Fetching reports...'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              color: AppConstants.of(context).kTextWhite[2],
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              onPressed: () {
                _detailedReportProvider.stopFetchingReport();
              },
            ),
          )
        ],
      ),
    );
  }
}

class SearchOption extends StatelessWidget {
  SearchOption({GlobalKey key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<DetailedReportProvider, CountriesListProvider>(
      builder: (_, detailedReportProvider, countriesListProvider, __) {
        switch (detailedReportProvider.state) {
          case DetailedReportProviderState.ready:
          case DetailedReportProviderState.error:
          case DetailedReportProviderState.empty:
            return SearchButton(detailedReportProvider, countriesListProvider);
            break;
          default:
            return CancelSearchButton(detailedReportProvider);
        }
      },
    );
  }
}

class SearchButton extends StatelessWidget {
  const SearchButton(this._detailedReportProvider, this._countriesListProvider);

  final DetailedReportProvider _detailedReportProvider;
  final CountriesListProvider _countriesListProvider;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Search',
      icon: Icon(
        Icons.search,
        color: AppConstants.of(context).kTextWhite[0],
      ),
      onPressed: () {
        showSearch(
          context: context,
          delegate: CountrySearchDelegate(_countriesListProvider.countriesList),
        ).then(
          (country) {
            if (country != null) {
              _detailedReportProvider.setDetailedReport(country.isoCode);
            }
          },
        );
      },
    );
  }
}

class CancelSearchButton extends StatelessWidget {
  const CancelSearchButton(this._detailedReportProvider);

  final DetailedReportProvider _detailedReportProvider;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      tooltip: 'Cancel search',
      onPressed: () {
        _detailedReportProvider.stopFetchingReport();
      },
      icon: Theme(
        data: ThemeData(
          accentColor: AppConstants.of(context).kTextWhite[2],
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            const CircularProgressIndicator(),
            Icon(Icons.clear),
          ],
        ),
      ),
    );
  }
}

class BarChartCards extends StatelessWidget {
  const BarChartCards({GlobalKey key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarCharts(
        Provider.of<DetailedReportProvider>(context).detailedReport.report);
  }
}

class NumberCards extends StatelessWidget {
  const NumberCards({GlobalKey key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Counters(
        Provider.of<DetailedReportProvider>(context).detailedReport);
  }
}
