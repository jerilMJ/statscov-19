import 'package:country_code/country_code.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statscov/shared/load_box.dart';
import 'package:statscov/providers/countries_list_provider.dart';
import 'package:statscov/providers/detailed_report_provider.dart';
import 'package:statscov/providers/location_provider.dart';
import 'package:statscov/screens/stats_screen/stats_screen.dart';

class StatsScreenLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<LocationProvider, CountriesListProvider>(
      builder: (_, locationProduct, countriesListProduct, __) {
        switch (countriesListProduct.state) {
          case CountriesListProviderState.ready:
            switch (locationProduct.state) {
              case LocationProviderState.ready:
                String iso = CountryCode.tryParse(
                        locationProduct.location.isoCountryCode)
                    .alpha3;

                return ChangeNotifierProvider(
                  create: (_) => DetailedReportProvider(iso),
                  child: StatsScreen(),
                );
                break;

              case LocationProviderState.loading:
                return LoadBox();
                break;

              case LocationProviderState.error:
                return StatsScreen();
                break;
            }
            break;

          case CountriesListProviderState.loading:
            return LoadBox();
            break;

          case CountriesListProviderState.error:
            return Text(countriesListProduct.error.toString());
            break;
        }
      },
    );
  }
}
