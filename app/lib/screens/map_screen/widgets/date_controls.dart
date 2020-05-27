import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:statscov/screens/map_screen/providers/map_utility_provider.dart';
import 'package:statscov/utils/constants.dart';

class DateControls extends StatelessWidget {
  const DateControls({
    GlobalKey key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MapUtilityProvider>(
      builder: (_, mapUtilityProvider, __) => Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Previous',
            icon: Icon(Icons.arrow_left),
            onPressed: () => mapUtilityProvider.prevDate(),
          ),
          Expanded(
            child: FlatButton(
              onPressed: () {
                showDatePicker(
                  context: context,
                  initialDate: mapUtilityProvider.date,
                  firstDate: mapUtilityProvider.firstDate,
                  lastDate: mapUtilityProvider.lastDate,
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
                ).then((date) => mapUtilityProvider.setDate(date));
              },
              color: Colors.transparent,
              child: Text(
                DateFormat('dd MMMM yyyy').format(mapUtilityProvider.date),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15.0),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Next',
            icon: Icon(Icons.arrow_right),
            onPressed: () => mapUtilityProvider.nextDate(),
          ),
        ],
      ),
    );
  }
}
