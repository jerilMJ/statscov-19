import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statscov/providers/countries_list_provider.dart';
import 'package:statscov/providers/location_provider.dart';
import 'package:statscov/utils/constants.dart';

import 'screens/stats_screen_loader.dart';

void main() => runApp(AppConstants(child: MyApp()));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocationProvider>(create: (_) => LocationProvider()),
        Provider<CountriesListProvider>(create: (_) => CountriesListProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppConstants.of(context).kDarkPrimary,
          backgroundColor: AppConstants.of(context).kDarkPrimary,
          accentColor: AppConstants.of(context).kPrimaryThree,
          appBarTheme: AppBarTheme.of(context).copyWith(
            color: AppConstants.of(context).kDarkSecondary,
          ),
          textTheme: Theme.of(context).textTheme.apply(
                fontFamily: 'Roboto',
                bodyColor: AppConstants.of(context).kTextColor,
                displayColor: AppConstants.of(context).kTextColor,
              ),
        ),
        home: StatsScreenLoader(),
      ),
    );
  }
}
