import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statscov/screens/stats_screen/providers/detailed_report_provider.dart';
import 'package:statscov/utils/constants.dart';

class SelectedCountryIndicator extends StatelessWidget {
  const SelectedCountryIndicator();

  @override
  Widget build(BuildContext context) {
    return Consumer<DetailedReportProvider>(
      builder: (_, detailedReportProvider, __) {
        switch (detailedReportProvider.state) {
          case DetailedReportProviderState.ready:
          case DetailedReportProviderState.loading:
            return Container(
              color: Colors.transparent,
              height: kToolbarHeight,
              child: Center(
                child: Text(
                  detailedReportProvider.currentlySearchingFor ?? '...',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppConstants.of(context).kTextWhite[1],
                  ),
                ),
              ),
            );
            break;

          default:
            return Container(
              width: 0.0,
              height: 0.0,
            );
        }
      },
    );
  }
}
