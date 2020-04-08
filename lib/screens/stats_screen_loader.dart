import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:statscov/models/country.dart';
import 'package:statscov/screens/loading_screen.dart';
import 'package:statscov/screens/stats_screen.dart';
import 'package:statscov/services/location.dart';
import 'package:statscov/services/covid_api.dart';

class StatsScreenLoader extends StatelessWidget {
  Future<List<dynamic>> doPreTasks() async {
    Placemark placemark = await LocationService().getPlacemark();

    List<Country> countriesList = await CovidApiService().getCountriesList();

    return [placemark, countriesList];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: doPreTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return StatsScreen(snapshot.data[0], snapshot.data[1]);
        } else {
          return LoadingScreen();
        }
      },
    );
  }
}
