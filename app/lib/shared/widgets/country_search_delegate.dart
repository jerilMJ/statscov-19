import 'package:country_code/country_code.dart';
import 'package:flutter/material.dart';
import 'package:statscov/models/api/country.dart';
import 'package:statscov/utils/constants.dart';

enum Options { showSelected, sort }

class CountrySearchDelegate extends SearchDelegate {
  CountrySearchDelegate(this.countriesList,
      {this.multiSelect = false, this.selected});

  List<Country> countriesList;
  List<Country> selected;
  bool multiSelect;
  bool showSelected = true;
  int maxSelect = 8;

  @override
  String get searchFieldLabel => 'Select a country';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: AppConstants.of(context).kDarkElevations[1],
      primaryIconTheme: theme.primaryIconTheme
          .copyWith(color: AppConstants.of(context).kTextWhite[1]),
      primaryColorBrightness: Brightness.light,
      primaryTextTheme: theme.textTheme,
    );
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: PopupMenuButton(
          offset: Offset(0.0, kToolbarHeight),
          tooltip: 'Options',
          icon: Icon(
            Icons.more_vert,
            color: AppConstants.of(context).kTextWhite[1],
          ),
          itemBuilder: (_) => [
            multiSelect
                ? PopupMenuItem(
                    value: Options.showSelected,
                    child:
                        Text(showSelected ? 'Hide selected' : 'Show selected'),
                  )
                : null,
            const PopupMenuItem(
              value: Options.sort,
              child: Text('Reverse order'),
            ),
          ],
          onSelected: (val) {
            switch (val) {
              case Options.showSelected:
                showSelected = !showSelected;
                break;

              case Options.sort:
                countriesList = countriesList.reversed.toList();
            }
          },
        ),
      ),
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StatefulBuilder(builder: (_, StateSetter setState) {
      Widget listview;
      Widget selectedView = Container();

      if (multiSelect) {
        selectedView = ListView.builder(
          itemCount: selected.length,
          itemBuilder: (_, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            child: Container(
              child: ListTileTheme(
                style: ListTileStyle.drawer,
                child: ListTile(
                  leading:
                      Text(CountryCode.parse(selected[index].isoCode).symbol),
                  title: Text(selected[index].countryName),
                  onTap: () => setState(() {
                    if (multiSelect) {
                      selected.remove(selected[index]);
                    } else {
                      close(context, selected[index]);
                    }
                  }),
                ),
              ),
            ),
          ),
        );
      }

      if (query != '') {
        List<Country> filtered = countriesList
            .where((country) => country.countryName
                .toLowerCase()
                .startsWith(query.toLowerCase()))
            .toList();
        listview = ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (_, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.0),
              child: Container(
                color: multiSelect
                    ? selected
                            .map((s) => s.countryName)
                            .toList()
                            .contains(filtered[index].countryName)
                        ? AppConstants.of(context).kDarkElevations[1]
                        : AppConstants.of(context).kDarkElevations[0]
                    : AppConstants.of(context).kDarkElevations[0],
                child: ListTile(
                  leading:
                      Text(CountryCode.parse(filtered[index].isoCode).symbol),
                  title: Text(filtered[index].countryName),
                  onTap: () => setState(() {
                    if (multiSelect) {
                      if (selected
                                  .where((s) =>
                                      s.countryName ==
                                      filtered[index].countryName)
                                  .length ==
                              0 &&
                          selected.length < maxSelect)
                        selected.add(filtered[index]);
                      else
                        selected.removeWhere((s) =>
                            s.countryName == filtered[index].countryName);
                    } else {
                      close(context, filtered[index]);
                    }
                  }),
                ),
              ),
            );
          },
        );
      } else {
        listview = ListView.builder(
          itemCount: countriesList.length,
          itemBuilder: (_, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            child: Container(
              color: multiSelect
                  ? selected
                          .map((s) => s.countryName)
                          .toList()
                          .contains(countriesList[index].countryName)
                      ? AppConstants.of(context).kDarkElevations[1]
                      : AppConstants.of(context).kDarkElevations[0]
                  : AppConstants.of(context).kDarkElevations[0],
              child: ListTile(
                leading: Text(
                    CountryCode.parse(countriesList[index].isoCode).symbol),
                title: Text(countriesList[index].countryName),
                onTap: () => setState(() {
                  if (multiSelect) {
                    if (selected
                                .where((s) =>
                                    s.countryName ==
                                    countriesList[index].countryName)
                                .length ==
                            0 &&
                        selected.length < maxSelect)
                      selected.add(countriesList[index]);
                    else
                      selected.removeWhere((s) =>
                          s.countryName == countriesList[index].countryName);
                  } else {
                    close(context, countriesList[index]);
                  }
                }),
              ),
            ),
          ),
        );
      }
      return Stack(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                child: Scrollbar(child: listview),
              )),
              multiSelect
                  ? showSelected
                      ? Expanded(
                          child: Container(
                          child: Scrollbar(child: selectedView),
                        ))
                      : Container()
                  : Container(),
            ],
          ),
          multiSelect
              ? Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: FloatingActionButton(
                      child: Icon(Icons.check),
                      onPressed: () {
                        query = '';
                        close(context, selected);
                      },
                    ),
                  ),
                )
              : Container(),
        ],
      );
    });
  }
}
