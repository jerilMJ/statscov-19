import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statscov/models/country.dart';
import 'package:statscov/screens/stats_screen/widgets/counters.dart';
import 'package:statscov/shared/load_box.dart';
import 'package:statscov/screens/stats_screen/widgets/bar_charts.dart';
import 'package:statscov/providers/countries_list_provider.dart';
import 'package:statscov/providers/detailed_report_provider.dart';
import 'package:statscov/utils/constants.dart';
import 'package:statscov/screens/stats_screen/widgets/country_search_delegate.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  String selectedValue;

  int countryPopulation;
  String _countryName;
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _countryName = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'StatsCov',
          style: TextStyle(fontSize: 20.0),
        ),
        actions: <Widget>[
          Consumer<DetailedReportProvider>(
            builder: (_, detailedReportProvider, __) {
              switch (detailedReportProvider.state) {
                case DetailedReportProviderState.ready:
                case DetailedReportProviderState.loading:
                  if (detailedReportProvider.state ==
                      DetailedReportProviderState.ready)
                    _countryName = detailedReportProvider
                        .detailedReport.report.countryName;

                  return Center(
                    child: Text(
                      _countryName,
                      style: TextStyle(
                        color: AppConstants.of(context).kTextPrimary,
                      ),
                    ),
                  );
                  break;

                default:
                  return Container();
              }
            },
          ),
          Consumer2<DetailedReportProvider, CountriesListProvider>(
            builder: (_, detailedReportProvider, countriesListProvider, __) {
              switch (detailedReportProvider.state) {
                case DetailedReportProviderState.ready:
                case DetailedReportProviderState.error:
                case DetailedReportProviderState.empty:
                  return FlatButton(
                    child: Icon(
                      Icons.search,
                      color: AppConstants.of(context).kTextSecondary,
                    ),
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: CountrySearchDelegate(
                            countriesListProvider.countriesList),
                      ).then((country) {
                        if (country != null) {
                          _countryName = country.countryName;
                          detailedReportProvider
                              .setDetailedReport(country.isoCode);
                        }
                      });
                    },
                  );
                  break;
                default:
                  return FlatButton(
                    onPressed: () {
                      detailedReportProvider.stopFetchingReport();
                    },
                    child: Theme(
                      data: ThemeData(
                        accentColor: AppConstants.of(context).kDarkTertiary,
                        iconTheme: IconThemeData(
                          color: Colors.white,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          Icon(Icons.clear),
                        ],
                      ),
                    ),
                  );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: choices.map((Choice choice) {
            return Tab(
              icon: Icon(choice.icon),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          NumbersCard(),
          BarChartCards(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class BarChartCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DetailedReportProvider>(
      builder: (_, detailedReportProduct, __) {
        switch (detailedReportProduct.state) {
          case DetailedReportProviderState.ready:
            return BarCharts(detailedReportProduct.detailedReport.report);
            break;
          case DetailedReportProviderState.loading:
            return LoadBox();
            break;
          case DetailedReportProviderState.error:
            return Text('error');
            break;
          case DetailedReportProviderState.empty:
            return Text('empty');
            break;
        }
      },
    );
  }
}

class NumbersCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DetailedReportProvider>(
      builder: (_, detailedReportProduct, __) {
        switch (detailedReportProduct.state) {
          case DetailedReportProviderState.ready:
            return Counters(detailedReportProduct.detailedReport.report,
                detailedReportProduct.detailedReport.country.population);
            break;
          case DetailedReportProviderState.loading:
            return LoadBox();
            break;
          case DetailedReportProviderState.error:
            return Text('error');
            break;
          case DetailedReportProviderState.empty:
            return Text('empty');
            break;
        }
      },
    );
  }
}

class Choice {
  const Choice({this.icon});

  final IconData icon;
}

final List<Choice> choices = <Choice>[
  Choice(icon: Icons.looks_two),
  Choice(icon: Icons.table_chart),
];
