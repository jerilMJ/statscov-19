import 'package:flutter/material.dart';
import 'package:statscov/components/animated_counter.dart';
import 'package:statscov/components/ui_card.dart';
import 'package:statscov/models/report.dart';
import 'package:statscov/utils/constants.dart';

class Counters extends StatelessWidget {
  Counters(this.report, this.population);
  final Report report;
  final int population;
  final TextStyle _counterTextStyle = TextStyle(
    fontSize: 40.0,
    color: Colors.purple.shade200,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      child: UiCard(
        padding: EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                        child: FittedBox(
                          child: Text(
                            'Total Population',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      ),
                      AnimatedCounter(
                        count: population,
                        isFraction: false,
                        textStyle: _counterTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 15.0),
              decoration: BoxDecoration(
                border: Border(
                  left:
                      BorderSide(color: AppConstants.of(context).kDarkTertiary),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                        child: FittedBox(
                          child: Text(
                            'Confirmed',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      ),
                      AnimatedCounter(
                        count: (report.confirmed * 100 / population),
                        isFraction: true,
                        textStyle: _counterTextStyle,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                        child: FittedBox(
                          child: Text(
                            'Recovered',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      ),
                      AnimatedCounter(
                        count: (report.recovered * 100 / population),
                        isFraction: true,
                        textStyle: _counterTextStyle,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                        child: FittedBox(
                          child: Text(
                            'Deaths',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      ),
                      AnimatedCounter(
                        count: (report.deaths * 100 / population),
                        isFraction: true,
                        textStyle: _counterTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
