import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/screens/worldwide_screen/providers/ordered_reports_provider.dart';
import 'package:statscov/utils/constants.dart';

class BarControls extends StatelessWidget {
  const BarControls(this.tutorialProvider);

  final TutorialProvider tutorialProvider;

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderedReportsProvider>(
      builder: (_, orderedReportsProvider, __) {
        return Row(
          children: <Widget>[
            IconButton(
              tooltip: orderedReportsProvider.isTimerActive ? 'Pause' : 'Play',
              key: tutorialProvider.getKeyFor('playPause'),
              icon: orderedReportsProvider.isTimerActive
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow),
              onPressed: () => orderedReportsProvider.toggleTimer(),
            ),
            IconButton(
              tooltip: 'Fast Forward',
              key: tutorialProvider.getKeyFor('fastForward'),
              icon: const Icon(Icons.fast_forward),
              onPressed: () => orderedReportsProvider.fastForwardDate(),
            ),
            IconButton(
              key: tutorialProvider.getKeyFor("reset"),
              tooltip: 'Reset',
              icon: const Icon(Icons.restore),
              onPressed: () => orderedReportsProvider.resetDate(),
            ),
            Expanded(
              child: DateControls(
                key: tutorialProvider.getKeyFor("dateControls"),
              ),
            ),
          ],
        );
      },
    );
  }
}

class DateControls extends StatelessWidget {
  const DateControls({
    GlobalKey key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderedReportsProvider>(
      builder: (_, orderedReportsProvider, __) => Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Previous',
            icon: Icon(Icons.arrow_left),
            onPressed: () => orderedReportsProvider.prevDate(),
          ),
          Expanded(
            child: FlatButton(
              onPressed: () {
                showDatePicker(
                  context: context,
                  initialDate:
                      DateTime.parse(orderedReportsProvider.currentDate),
                  firstDate: DateTime.parse(orderedReportsProvider.firstDate),
                  lastDate: DateTime.parse(orderedReportsProvider.lastDate),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        primaryColor: AppConstants.of(context).kAccentColor,
                        accentColor: AppConstants.of(context).kAccentColor,
                        dialogBackgroundColor:
                            AppConstants.of(context).kDarkElevations[0],
                        colorScheme: ColorScheme.dark().copyWith(
                          primary: AppConstants.of(context).kAccentColor,
                          surface: AppConstants.of(context).kDarkElevations[1],
                        ),
                      ),
                      child: child,
                    );
                  },
                ).then((date) => orderedReportsProvider.setDate(date));
              },
              color: Colors.transparent,
              child: ValueListenableBuilder(
                valueListenable: orderedReportsProvider.currentDateNotifier,
                builder: (_, currentDate, __) => Text(
                  DateFormat('dd MMMM yyyy')
                      .format(DateTime.parse(currentDate)),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15.0),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Next',
            icon: Icon(Icons.arrow_right),
            onPressed: () => orderedReportsProvider.nextDate(),
          ),
        ],
      ),
    );
  }
}
