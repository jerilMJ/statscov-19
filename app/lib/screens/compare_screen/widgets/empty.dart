import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statscov/providers/countries_list_provider.dart';
import 'package:statscov/screens/compare_screen/providers/compare_utility_provider.dart';
import 'package:statscov/shared/widgets/country_search_delegate.dart';
import 'package:statscov/utils/constants.dart';

typedef SelectedValueCallback = Function(String);

class Empty extends StatelessWidget {
  const Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Consumer2<CountriesListProvider, CompareUtilityProvider>(
          builder: (_, countriesListProvider, compareUtilityProvider, __) =>
              Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Start by selecting countries from the search list',
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
                  iconSize: MediaQuery.of(context).size.width / 3,
                  onPressed: () {
                    openSearch(
                        context, countriesListProvider, compareUtilityProvider);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void openSearch(
      BuildContext context,
      CountriesListProvider countriesListProvider,
      CompareUtilityProvider compareUtilityProvider) {
    showSearch(
      context: context,
      delegate: CountrySearchDelegate(
        countriesListProvider.countriesList,
        multiSelect: true,
        selected: [],
      ),
    ).then(
      (countries) {
        if (countries != null) {
          countries.forEach((country) =>
              compareUtilityProvider.addSelection(country.isoCode));
        }
      },
    );
  }
}
