import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:statscov/components/animated_counter.dart';
import 'package:statscov/components/counters.dart';
import 'package:statscov/components/load_box.dart';
import 'package:statscov/models/country.dart';
import 'package:statscov/models/report.dart';
import 'package:statscov/services/countries_api.dart';
import 'package:statscov/services/covid_api.dart';
// import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:country_code/country_code.dart';
import 'package:statscov/components/bar_charts.dart';
import 'package:statscov/components/countries_field.dart';
import 'package:rxdart/rxdart.dart';
import 'package:statscov/utils/exceptions.dart';

class StatsScreen extends StatefulWidget {
  StatsScreen(this.placemark, this.countriesList);
  final Placemark placemark;
  final List<Country> countriesList;

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  String selectedValue;
  CovidApiService covidApiService;
  CountriesApiService countriesApiService;
  Report report;
  Stream<Report> reportStream;
  Stream<int> populationStream;
  StreamController<Report> reportStreamController;
  StreamController<int> populationStreamController;
  int countryPopulation;
  bool isFullyLoaded;
  Widget _appBarWidget;
  String titleName;
  StreamController<void> focusNotifierControl;
  Stream focusNotifierStream;
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    reportStreamController = BehaviorSubject();
    reportStream = reportStreamController.stream;

    populationStreamController = BehaviorSubject();
    populationStream = populationStreamController.stream;

    focusNotifierControl = StreamController<void>();
    focusNotifierStream = focusNotifierControl.stream;

    covidApiService = CovidApiService();
    countriesApiService = CountriesApiService();

    if (widget.placemark != null) {
      try {
        selectedValue =
            CountryCode.parse(widget.placemark.isoCountryCode).alpha3;
        fetchStats();
      } catch (e) {
        print(e);
      }
    }

    _appBarWidget = _titleWidget;
    titleName = '';
  }

  Widget get _countrySearch {
    return Form(
      child: CountriesField(
        widget.countriesList,
        onChanged: (value) {
          selectedValue = value;
          print(value);
          fetchStats();
        },
        startingText: report.countryName,
        onLoseFocus: () {
          setState(() {
            _appBarWidget = _titleWidget;
          });
        },
        focusNotifier: focusNotifierStream,
      ),
    );
  }

  Widget get _titleWidget {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          'StatsCov',
          style: TextStyle(fontSize: 20.0),
        ),
        Text(
          titleName,
          style: TextStyle(fontSize: 15.0),
          overflow: TextOverflow.clip,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarWidget,
        actions: <Widget>[
          FlatButton(
            child: Icon(Icons.search),
            onPressed: () {
              setState(() {
                _appBarWidget = _countrySearch;
              });
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
      body: GestureDetector(
        onTapDown: (details) {
          setState(() {
            _appBarWidget = _titleWidget;
            focusNotifierControl.add(true);
          });
        },
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            NumbersScreen(
                populationStream: populationStream,
                report: report,
                isFullyLoaded: isFullyLoaded),
            BarChartsScreen(reportStream: reportStream),
          ],
        ),
      ),
    );
  }

  void fetchStats() async {
    setState(() {
      titleName = '';
      _appBarWidget = _titleWidget;
    });
    isFullyLoaded = false;

    reportStreamController.add(null);
    populationStreamController.add(null);

    report = await covidApiService
        .getReportForIsoCode(selectedValue)
        .catchError((error) => null);

    countryPopulation = await countriesApiService
        .getCountryPopulationByIso(selectedValue)
        .catchError((error) => null);

    if (report == null || countryPopulation == null) {
      throw DataFetchException(
          'Looks like I was unable to fetch some data. Please try again');
    }

    reportStreamController.add(report);
    populationStreamController.add(countryPopulation);

    isFullyLoaded = true;
    setState(() {
      titleName = ' - ' + report.countryName;
      _appBarWidget = _titleWidget;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class BarChartsScreen extends StatefulWidget {
  const BarChartsScreen({
    Key key,
    @required this.reportStream,
  }) : super(key: key);

  final Stream<Report> reportStream;

  @override
  _BarChartsScreenState createState() => _BarChartsScreenState();
}

class _BarChartsScreenState extends State<BarChartsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.reportStream,
      initialData: null,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return LoadBox();
        } else {
          return BarCharts(snapshot.data);
        }
      },
    );
  }
}

class NumbersScreen extends StatefulWidget {
  const NumbersScreen({
    Key key,
    @required this.populationStream,
    @required this.report,
    @required this.isFullyLoaded,
  }) : super(key: key);

  final Stream<int> populationStream;
  final Report report;
  final bool isFullyLoaded;

  @override
  _NumbersScreenState createState() => _NumbersScreenState();
}

class _NumbersScreenState extends State<NumbersScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.populationStream,
      initialData: null,
      builder: (context, snapshot) {
        if (snapshot.data == null ||
            widget.report == null ||
            !widget.isFullyLoaded) {
          return LoadBox();
        } else {
          return Counters(widget.report, snapshot.data);
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
