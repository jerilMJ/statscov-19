import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statscov/providers/countries_list_provider.dart';
import 'package:statscov/screens/stats_screen/providers/detailed_report_provider.dart';
import 'package:statscov/shared/widgets/country_search_delegate.dart';
import 'package:statscov/utils/constants.dart';

typedef SelectedValueCallback = Function(String);

class Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (_, orientation) {
      bool portrait = orientation == Orientation.portrait;
      return Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Consumer2<DetailedReportProvider, CountriesListProvider>(
            builder: (_, detailedReportProvider, countriesListProvider, __) =>
                Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Start by selecting a country from the search list',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: AppConstants.of(context).kTextWhite[1],
                    ),
                  ),
                  const SizedBox(
                    height: 40.0,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: AppConstants.of(context).kTextWhite[1],
                    ),
                    iconSize: portrait
                        ? MediaQuery.of(context).size.width / 3
                        : MediaQuery.of(context).size.height / 3,
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: CountrySearchDelegate(
                            countriesListProvider.countriesList),
                      ).then(
                        (country) {
                          if (country != null) {
                            detailedReportProvider
                                .setDetailedReport(country.isoCode);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
