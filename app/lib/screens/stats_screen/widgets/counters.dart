import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statscov/models/api/covid_compiled/report.dart';
import 'package:statscov/models/api/detailed_report.dart';
import 'package:statscov/models/api/rest_country.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/shared/widgets/flipper.dart';
import 'package:statscov/shared/widgets/ui_card.dart';
import 'package:statscov/utils/constants.dart';

class Counters extends StatefulWidget {
  Counters(DetailedReport detailedReport)
      : report = detailedReport.report,
        country = detailedReport.country,
        population = detailedReport.country.population;

  final Report report;
  final RestCountry country;
  final int population;

  @override
  _CountersState createState() => _CountersState();
}

class _CountersState extends State<Counters>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
  }

  void _afterBuild(_) async {
    TutorialProvider tutorialProvider =
        Provider.of<TutorialProvider>(context, listen: false);
    tutorialProvider.screenTutorial.tutorialNotFinished();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shown = (await prefs.getBool('seenStatsTut1')) ?? false;

    if (!shown) {
      Future.delayed(
        Duration(milliseconds: tutorialProvider.shortTutorialDelay),
        () => tutorialProvider.screenTutorial.showTutorial(1),
      );
      await prefs.setBool('seenStatsTut1', true);
    } else {
      tutorialProvider.screenTutorial.tutorialIsFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (_, constraints) {
        final itemHeight = constraints.maxHeight / 4;
        final itemWidth = constraints.maxWidth / 2;

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: itemWidth / itemHeight,
            children: <Widget>[
              UiCard(
                child: SizedBox(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.report.countryName,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 30.0),
                    ),
                  ),
                ),
              ),
              NumberCard(
                title: 'Total Population',
                content: widget.population,
                textStyle: AppConstants.of(context).kBigCounterTextStyle,
              ),
              Flipper(
                flipCardKey: Provider.of<TutorialProvider>(context)
                    .getKeyFor("flipCard"),
                isAlsoTutorialCard: true,
                frontText: 'Confirmed',
                frontContent: widget.report.confirmed,
                backText: 'Previously',
                backContent:
                    widget.report.confirmed - widget.report.confirmedDiff,
                textStyle: AppConstants.of(context).kSmallCounterTextStyle,
              ),
              Flipper(
                frontText: 'Recovered',
                frontContent: widget.report.recovered,
                backText: 'Previously',
                backContent:
                    widget.report.recovered - widget.report.recoveredDiff,
                textStyle: AppConstants.of(context).kSmallCounterTextStyle,
              ),
              Flipper(
                frontText: 'Deaths',
                frontContent: widget.report.deaths,
                backText: 'Previously',
                backContent: widget.report.deaths - widget.report.deathsDiff,
                textStyle: AppConstants.of(context).kSmallCounterTextStyle,
              ),
              Flipper(
                frontText: 'Active',
                frontContent: widget.report.confirmed -
                    widget.report.recovered -
                    widget.report.deaths,
                backText: 'Previously',
                backContent: (widget.report.confirmed -
                        widget.report.confirmedDiff) -
                    (widget.report.recovered - widget.report.recoveredDiff) -
                    (widget.report.deaths - widget.report.deathsDiff),
                textStyle: AppConstants.of(context).kSmallCounterTextStyle,
              ),
              NumberCard(
                title: 'Fatality Rate',
                content: widget.report.fatalityRate * 100,
                isFraction: true,
                textStyle: AppConstants.of(context).kSmallCounterTextStyle,
              ),
              UiCard(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                      child: FittedBox(
                        child: Text(
                          'Last Updated',
                          style: AppConstants.of(context).kTitleTextStyle,
                        ),
                      ),
                    ),
                    Text(
                      widget.report.date,
                      style: AppConstants.of(context).kDateTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
