import 'package:country_code/country_code.dart';
import 'package:flutter/material.dart';
import 'package:statscov/models/country.dart';

class CountrySearchDelegate extends SearchDelegate {
  List<Country> countriesList;

  CountrySearchDelegate(this.countriesList);

  @override
  String get searchFieldLabel => 'Select a country';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Colors.grey.shade900,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      primaryColorBrightness: Brightness.light,
      primaryTextTheme: theme.textTheme,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Column();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query != '') {
      List<Country> filtered = countriesList
          .where((country) =>
              country.countryName.toLowerCase().startsWith(query.toLowerCase()))
          .toList();

      return ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (_, index) => ListTile(
          leading: Text(CountryCode.parse(filtered[index].isoCode).symbol),
          title: Text(filtered[index].countryName),
          onTap: () {
            close(context, filtered[index]);
          },
        ),
      );
    } else {
      return ListView.builder(
        itemCount: countriesList.length,
        itemBuilder: (_, index) => ListTile(
          leading: Text(CountryCode.parse(countriesList[index].isoCode).symbol),
          title: Text(countriesList[index].countryName),
          onTap: () {
            close(context, countriesList[index]);
          },
        ),
      );
    }
  }
}
