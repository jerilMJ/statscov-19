import 'package:charts_flutter/flutter.dart' as charts hide TextStyle;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';
import 'package:statscov/models/api/country.dart';
import 'package:statscov/models/api/iso_name.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/screens/compare_screen/providers/compare_utility_provider.dart';
import 'package:statscov/screens/compare_screen/widgets/graph_indicator.dart';
import 'package:statscov/shared/widgets/ui_card.dart';
import 'package:statscov/utils/screen_size_util.dart';

class PlotControllers extends StatelessWidget {
  const PlotControllers({
    @required CompareUtilityProvider compareUtilityProvider,
    @required List<Country> selected,
  })  : _selected = selected,
        _compareUtilityProvider = compareUtilityProvider;

  final List<Country> _selected;
  final CompareUtilityProvider _compareUtilityProvider;

  @override
  Widget build(BuildContext context) {
    var indexes = List<int>.generate(
        _compareUtilityProvider.colorTracker.length, (index) => index).toList();
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        childAspectRatio:
            ScreenSizeUtil.screenWidth(context, dividedBy: 2) / 50.0,
        maxCrossAxisExtent: 350.0,
      ),
      delegate: SliverChildListDelegate(
        zip(
          [indexes, _compareUtilityProvider.colorTracker.entries.toList()],
        ).map((pair) {
          var iso = (pair[1] as MapEntry<String, charts.Color>).key;
          var color = (pair[1] as MapEntry<String, charts.Color>).value;
          var index = pair[0];
          var name = IsoName().iso3ToCountry(iso);

          return UiCard(
            padding: EdgeInsets.zero,
            child: GraphIndicator(
              key: index == 0
                  ? Provider.of<TutorialProvider>(context, listen: false)
                      .getKeyFor("graphIndicator")
                  : null,
              color: color,
              isDisabled: _compareUtilityProvider.isDisabled(iso),
              isAlsoTutorialController: index == 0,
              text: name,
              iso: iso,
              deleteEvent: () {
                _compareUtilityProvider.removeSelection(iso);
                _selected.remove(
                    _selected.firstWhere((country) => country.isoCode == iso));
              },
              toggleEvent: () {
                _compareUtilityProvider.togglePlot(iso);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DateAxisControllers extends StatelessWidget {
  const DateAxisControllers({
    @required CompareUtilityProvider compareUtilityProvider,
    Key key,
  })  : _compareUtilityProvider = compareUtilityProvider,
        super(key: key);

  final CompareUtilityProvider _compareUtilityProvider;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Form(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    child: Text(_compareUtilityProvider
                        .prettifyDate(_compareUtilityProvider.startDate)),
                    onPressed: () async {
                      var pick = await showDatePicker(
                        context: context,
                        firstDate:
                            DateTime.parse(_compareUtilityProvider.minDate),
                        lastDate:
                            DateTime.parse(_compareUtilityProvider.endDate),
                        initialDate:
                            DateTime.parse(_compareUtilityProvider.startDate),
                      );

                      if (pick != null) {
                        var date = _compareUtilityProvider.formatDate(pick);
                        _compareUtilityProvider.setStartDate(date);
                      }
                    },
                  ),
                ),
                const Text('to'),
                Expanded(
                  child: FlatButton(
                    child: Text(_compareUtilityProvider
                        .prettifyDate(_compareUtilityProvider.endDate)),
                    onPressed: () async {
                      var pick = await showDatePicker(
                        context: context,
                        firstDate:
                            DateTime.parse(_compareUtilityProvider.startDate),
                        lastDate:
                            DateTime.parse(_compareUtilityProvider.maxDate),
                        initialDate:
                            DateTime.parse(_compareUtilityProvider.endDate),
                      );
                      if (pick != null) {
                        var date = _compareUtilityProvider.formatDate(pick);
                        _compareUtilityProvider.setEndDate(date);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
