import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statscov/components/load_box.dart';
import 'package:statscov/providers/countries_list_provider.dart';
import 'package:statscov/providers/location_provider.dart';
import 'package:statscov/screens/stats_screen.dart';

class StatsScreenLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<LocationProvider, CountriesListProvider>(
      builder: (_, locationProduct, countriesListProduct, __) {
        if (countriesListProduct.state == CountriesListProviderState.ready) {
          if (locationProduct.state == LocationProviderState.ready) {
            return StatsScreen(
                locationProduct.location, countriesListProduct.countriesList);
          } else if (locationProduct.state == LocationProviderState.loading) {
            return LoadBox();
          } else {
            return StatsScreen(null, countriesListProduct.countriesList);
          }
        } else if (countriesListProduct.state ==
            CountriesListProviderState.loading) {
          return LoadBox();
        } else {
          return Text(countriesListProduct.exception.toString());
        }
      },
    );
  }
}
