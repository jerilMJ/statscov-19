import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/screens/map_screen/providers/map_utility_provider.dart';
import 'package:statscov/screens/map_screen/widgets/date_controls.dart';

class MapControllers extends StatelessWidget {
  const MapControllers();

  @override
  Widget build(BuildContext context) {
    return Consumer2<TutorialProvider, MapUtilityProvider>(
      builder: (_, tutorialProvider, mapUtilityProvider, __) => Row(
        children: <Widget>[
          IconButton(
            tooltip: mapUtilityProvider.isIncrementerActive ? 'Pause' : 'Play',
            key: tutorialProvider.getKeyFor("playPause"),
            icon: mapUtilityProvider.isIncrementerActive
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
            onPressed: () => mapUtilityProvider.toggleDateIncrementer(),
          ),
          IconButton(
            tooltip: 'Last Entry',
            key: tutorialProvider.getKeyFor("lastEntry"),
            icon: const Icon(Icons.fast_forward),
            onPressed: () => mapUtilityProvider.goToLastEntry(),
          ),
          IconButton(
            key: tutorialProvider.getKeyFor("reset"),
            tooltip: 'Reset',
            icon: const Icon(Icons.restore),
            onPressed: () => mapUtilityProvider.resetDate(),
          ),
          Expanded(
            child: DateControls(
              key: tutorialProvider.getKeyFor("dateControls"),
            ),
          ),
        ],
      ),
    );
  }
}
