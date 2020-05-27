import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statscov/models/api/country.dart';
import 'package:statscov/models/api/covid_minified/minified_report.dart';
import 'package:statscov/models/api/iso_name.dart';
import 'package:statscov/screens/compare_screen/widgets/graph_card.dart';
import 'package:statscov/utils/data_structures.dart' as ds;

enum CompareUtilityProviderState { error, ready }

class CompareUtilityProvider with ChangeNotifier {
  CompareUtilityProvider(MinifiedReport report) {
    _isAlive = true;
    _initColorStore();

    _report = report;
    _minDate = report.getCases("US").first.date;
    _maxDate = report.getCases("US").last.date;
    _startDate = _minDate;
    _endDate = _maxDate;
    graphs = {};
    disabledGraphs = {};

    initSelected();
  }

  void initSelected() async {
    _prefs = await SharedPreferences.getInstance();
    _pinned = _prefs.getStringList('pinnedCountries') ?? [];
    if (_pinned.isNotEmpty) {
      _pinned.forEach((pinnedIso) => addSelection(pinnedIso));
    } else {
      _setState(CompareUtilityProviderState.ready);
    }
  }

  MinifiedReport _report;
  MinifiedReport _selected = MinifiedReport({});
  List<String> _disabled = [];
  CompareUtilityProviderState _state;
  dynamic _error;
  ds.Stack<charts.Color> _colorStore;
  Map<String, charts.Color> _colorTracker = {};
  int _allowedLength = 8;
  String _minDate;
  String _maxDate;
  String _startDate;
  String _endDate;
  List<String> _pinned = [];
  SharedPreferences _prefs;
  bool _isAlive;
  bool dateHasChanged = false;

  MinifiedReport get selected => _selected;
  CompareUtilityProviderState get state => _state;
  dynamic get error => _error;
  Map<String, charts.Color> get colorTracker => _colorTracker;
  int get allowedLength => _allowedLength;
  String get minDate => _minDate;
  String get maxDate => _maxDate;
  String get startDate => _startDate;
  String get endDate => _endDate;
  bool get nothingToCompare => _selected.cases.length == 0;
  bool get pinningAllowed => _pinned.length < _allowedLength;
  List<Country> get pinnedCountries => _pinned
      .map((iso) => Country(IsoName().iso3ToCountry(iso), iso, null))
      .toList();
  List<String> get disabled => _disabled;

  /// model:
  /// {
  ///   GraphMode.confirmed: {
  ///     iso: charts.Series<>,
  ///     ...
  ///   }
  /// }
  ///  Map<GraphMode, Map<String, charts.Series<LinearPlot, DateTime>>> graphs = {};
  Map<GraphMode, Map<String, charts.Series<LinearPlot, DateTime>>> graphs = {};
  Map<GraphMode, Map<String, charts.Series<LinearPlot, DateTime>>>
      disabledGraphs = {};

  void pin(String iso) {
    if (!_pinned.contains(iso) && pinningAllowed) {
      _pinned.add(iso);
    }
  }

  void unpin(String iso) {
    if (_pinned.contains(iso)) {
      _pinned.remove(iso);
    }
  }

  bool isPinned(String iso) {
    return _pinned.contains(iso);
  }

  void _initColorStore() {
    final colors = [
      charts.ColorUtil.fromDartColor(Colors.pink.shade200),
      charts.ColorUtil.fromDartColor(Colors.grey.shade200),
      charts.ColorUtil.fromDartColor(Colors.deepPurple.shade200),
      charts.ColorUtil.fromDartColor(Colors.blue.shade200),
      charts.ColorUtil.fromDartColor(Colors.green.shade200),
      charts.ColorUtil.fromDartColor(Colors.yellow.shade200),
      charts.ColorUtil.fromDartColor(Colors.deepOrange.shade200),
      charts.ColorUtil.fromDartColor(Colors.brown.shade200),
    ];

    colors.shuffle();

    _colorStore = ds.Stack(colors);
  }

  void _setState(CompareUtilityProviderState state) {
    _state = state;
    if (_state == CompareUtilityProviderState.error) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_isAlive) notifyListeners();
      });
    } else {
      if (_isAlive) notifyListeners();
    }
  }

  void addSelection(String iso) async {
    if (_selected.cases.length == _allowedLength ||
        _colorTracker.containsKey(iso)) {
      return;
    }

    try {
      _selected.cases[iso] = _report.getCases(IsoName().iso3ToCountry(iso));
      _stashColor(iso);
      graphs = {};
      disabledGraphs = {};

      _setState(CompareUtilityProviderState.ready);
    } catch (e) {
      _error = e;
      _setState(CompareUtilityProviderState.error);
    }
  }

  void removeSelection(String iso) {
    _selected.cases.remove(iso);
    _disabled.remove(iso);

    graphs.forEach((mode, graph) {
      graph.remove(iso);
      disabledGraphs[mode].remove(iso);
    });

    _storeColor(iso);
    _setState(CompareUtilityProviderState.ready);
  }

  void _stashColor(String iso) {
    if (_colorTracker.containsKey(iso)) {
      return;
    }
    charts.Color color = _colorStore.pop();
    _colorTracker[iso] = color;
  }

  void _storeColor(String iso) {
    if (_colorTracker.containsKey(iso)) {
      _colorStore.push(_colorTracker[iso]);
      _colorTracker.remove(iso);
    }
  }

  charts.Color getColor(String iso) {
    return _colorTracker[iso];
  }

  void disablePlot(String iso) {
    _disabled.add(iso);
    graphs.forEach((mode, graph) {
      disabledGraphs[mode] = disabledGraphs[mode] ?? {};
      disabledGraphs[mode][iso] = graph[iso];
      graphs[mode].remove(iso);
    });

    _setState(CompareUtilityProviderState.ready);
  }

  void enablePlot(String iso) {
    _disabled.remove(iso);
    disabledGraphs.forEach((mode, graph) {
      graphs[mode][iso] = graph[iso];
      disabledGraphs[mode].remove(iso);
    });

    _setState(CompareUtilityProviderState.ready);
  }

  void togglePlot(String iso) {
    if (_disabled.contains(iso)) {
      enablePlot(iso);
    } else {
      disablePlot(iso);
    }
  }

  bool isDisabled(String iso) {
    return _disabled.contains(iso);
  }

  void setStartDate(String date) {
    if (_startDate != date) {
      _startDate = date;
      dateHasChanged = true;
      _setState(CompareUtilityProviderState.ready);
    }
  }

  void setEndDate(String date) {
    if (_endDate != date) {
      _endDate = date;
      dateHasChanged = true;
      _setState(CompareUtilityProviderState.ready);
    }
  }

  String formatDate(dynamic date) {
    if (date is String) date = DateTime.parse(date);
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    return dateFormat.format(date);
  }

  String prettifyDate(dynamic date) {
    if (date is String) date = DateTime.parse(date);
    final DateFormat dateFormat = DateFormat('dd MMMM yyyy');

    return dateFormat.format(date);
  }

  void clearAll() {
    _selected.cases.forEach((iso, _) => _storeColor(iso));
    _selected.cases = {};
    graphs = {};
    disabledGraphs = {};
    _setState(CompareUtilityProviderState.ready);
  }

  void unpinAll() {
    _pinned = [];
    _setState(CompareUtilityProviderState.ready);
  }

  @override
  void dispose() {
    _isAlive = false;
    _prefs.setStringList('pinnedCountries', _pinned);
    super.dispose();
  }
}
