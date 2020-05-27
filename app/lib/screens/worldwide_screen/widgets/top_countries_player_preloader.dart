import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statscov/screens/worldwide_screen/providers/ordered_reports_provider.dart';
import 'package:statscov/screens/worldwide_screen/widgets/top_countries_player.dart';
import 'package:statscov/shared/widgets/error_box.dart';
import 'package:statscov/shared/widgets/load_box.dart';

class TopCountriesPlayerPreloader extends StatelessWidget {
  const TopCountriesPlayerPreloader();

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderedReportsProvider>(
        builder: (_, orderedReportsProvider, __) {
      if (orderedReportsProvider.state == OrderedReportsProviderState.ready) {
        return const TopCountriesPlayer();
      } else if (orderedReportsProvider.state ==
          OrderedReportsProviderState.error) {
        return ErrorBox(
          tryAgain: () => orderedReportsProvider.tryFetching(),
          context: context,
          error: orderedReportsProvider.error,
        );
      } else {
        return const LoadBox('Fetching data...');
      }
    });
  }
}
