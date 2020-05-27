import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/providers/worldwide_report_provider.dart';
import 'package:statscov/shared/widgets/flipper.dart';
import 'package:statscov/utils/constants.dart';

class NumberCards extends StatefulWidget {
  NumberCards({@required WorldwideReportProvider worldwideReportProvider})
      : _worldwideReportProvider = worldwideReportProvider;

  final WorldwideReportProvider _worldwideReportProvider;

  @override
  _NumberCardsState createState() => _NumberCardsState();
}

class _NumberCardsState extends State<NumberCards> {
  TutorialProvider _tutorialProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
    _tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
  }

  void _afterBuild(_) async {
    _tutorialProvider.screenTutorial.tutorialNotFinished();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shown = (await prefs.getBool('seenWorldwideTut0')) ?? false;
    if (!shown) {
      Future.delayed(
        Duration(milliseconds: _tutorialProvider.tutorialDelay),
        () => _tutorialProvider.screenTutorial.showTutorial(0),
      );
      await prefs.setBool('seenWorldwideTut0', true);
    } else {
      _tutorialProvider.screenTutorial.tutorialIsFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final itemHeight = constraints.maxHeight / 2;
        final itemWidth = constraints.maxWidth / 2;

        return GridView.count(
          crossAxisCount: 2,
          childAspectRatio: itemWidth / itemHeight,
          children: [
            Flipper(
              textStyle: AppConstants.of(context).kSmallCounterTextStyle,
              isAlsoTutorialCard: true,
              flipCardKey: _tutorialProvider.getKeyFor("flipCard"),
              frontText: 'Confirmed',
              frontContent: widget._worldwideReportProvider.report.confirmed,
              backText: 'Previously',
              backContent: widget._worldwideReportProvider.report.confirmed -
                  widget._worldwideReportProvider.report.confirmedDiff,
            ),
            Flipper(
              textStyle: AppConstants.of(context).kSmallCounterTextStyle,
              frontText: 'Recovered',
              frontContent: widget._worldwideReportProvider.report.recovered,
              backText: 'Previously',
              backContent: widget._worldwideReportProvider.report.recovered -
                  widget._worldwideReportProvider.report.recoveredDiff,
            ),
            Flipper(
              textStyle: AppConstants.of(context).kSmallCounterTextStyle,
              frontText: 'Deaths',
              frontContent: widget._worldwideReportProvider.report.deaths,
              backText: 'Previously',
              backContent: widget._worldwideReportProvider.report.deaths -
                  widget._worldwideReportProvider.report.deathsDiff,
            ),
            Flipper(
              textStyle: AppConstants.of(context).kSmallCounterTextStyle,
              frontText: 'Active',
              frontContent: widget._worldwideReportProvider.report.active,
              backText: 'Previously',
              backContent: widget._worldwideReportProvider.report.active -
                  widget._worldwideReportProvider.report.activeDiff,
            )
          ],
        );
      },
    );
  }
}
