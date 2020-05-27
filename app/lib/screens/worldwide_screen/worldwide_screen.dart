import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:statscov/providers/latest_report_provider.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/providers/worldwide_report_provider.dart';
import 'package:statscov/screens/worldwide_screen/providers/worldwide_reports_provider.dart';
import 'package:statscov/screens/worldwide_screen/utils/worldwide_screen_tutorial.dart';
import 'package:statscov/screens/worldwide_screen/widgets/data_curve_preloader.dart';
import 'package:statscov/screens/worldwide_screen/widgets/number_cards.dart';
import 'package:statscov/screens/worldwide_screen/widgets/pie_chart_plot.dart';
import 'package:statscov/screens/worldwide_screen/widgets/stacked_bar.dart';
import 'package:statscov/screens/worldwide_screen/widgets/top_countries_player_preloader.dart';
import 'package:statscov/shared/widgets/error_box.dart';
import 'package:statscov/shared/widgets/ui_card.dart';
import 'package:statscov/utils/constants.dart';
import 'package:statscov/utils/dialog_manager.dart';
import 'package:statscov/utils/tab_bar_choice.dart';

class WorldwideScreen extends StatefulWidget {
  const WorldwideScreen();

  @override
  _WorldwideScreenState createState() => _WorldwideScreenState();
}

class _WorldwideScreenState extends State<WorldwideScreen>
    with SingleTickerProviderStateMixin {
  TutorialProvider _tutorialProvider;
  WorldwideScreenTutorial _worldwideScreenTutorial;
  TabController _tabController;

  final List<TabBarChoice> choices = <TabBarChoice>[
    const TabBarChoice(icon: Icons.looks_two),
    const TabBarChoice(icon: Icons.show_chart),
    const TabBarChoice(icon: Icons.table_chart),
    const TabBarChoice(icon: Icons.insert_chart),
  ];

  @override
  void initState() {
    super.initState();
    _tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    _tabController = TabController(vsync: this, length: choices.length);
    _worldwideScreenTutorial = WorldwideScreenTutorial(context, _tabController);
    _tutorialProvider.screenTutorial = _worldwideScreenTutorial;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorldwideReportProvider>(
      builder: (_, worldwideReportProvider, __) {
        Widget child = Container();

        if (worldwideReportProvider.state ==
            WorldwideReportProviderState.ready) {
          WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(
              const Duration(milliseconds: 100),
              () => DialogManager.of(context).clearDialogs()));

          child = WillPopScope(
            onWillPop: () async {
              return _worldwideScreenTutorial.tutorialFinished;
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(AppConstants.of(context).kAppTitle),
                actions: <Widget>[
                  IconButton(
                    tooltip: 'Help',
                    icon: const Icon(Icons.help),
                    onPressed: () => _tutorialProvider.screenTutorial
                        .showTutorial(_tabController.index),
                  )
                ],
                leading: IconButton(
                  tooltip: 'Home',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                bottom: TabBar(
                  labelColor: Colors.purple.shade200,
                  unselectedLabelColor:
                      AppConstants.of(context).kDarkElevations[2],
                  indicatorColor: AppConstants.of(context).kDarkElevations[2],
                  controller: _tabController,
                  isScrollable: false,
                  tabs: choices
                      .map((choice) => Tab(icon: Icon(choice.icon)))
                      .toList(),
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  UiCard(
                    padding: EdgeInsets.zero,
                    elevation: 0.0,
                    color: Colors.transparent,
                    child: Column(
                      children: <Widget>[
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'WORLDWIDE',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: AppConstants.of(context).kTextWhite[1],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${DateFormat('dd MMMM yyyy').format(DateTime.parse(worldwideReportProvider.report.date))}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: AppConstants.of(context).kTextWhite[2],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: NumberCards(
                            worldwideReportProvider: worldwideReportProvider,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: UiCard(
                            padding: EdgeInsets.zero,
                            color: AppConstants.of(context).kDarkElevations[0],
                            child: PieChartPlot(worldwideReportProvider.report),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ChangeNotifierProvider(
                    create: (_) => WorldwideReportsProvider(
                        Provider.of<LatestReportsProvider>(context,
                                listen: false)
                            .appDocsDirPath),
                    child: const DataCurvePreloader(),
                  ),
                  UiCard(
                    child: StackedBar(
                      worldwideReportProvider: worldwideReportProvider,
                    ),
                  ),
                  const TopCountriesPlayerPreloader(),
                ],
              ),
            ),
          );
        } else if (worldwideReportProvider.state ==
            WorldwideReportProviderState.error) {
          child = ErrorBox(
            tryAgain: () => worldwideReportProvider.tryFetching(),
            context: context,
            error: worldwideReportProvider.error,
          );
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
}
