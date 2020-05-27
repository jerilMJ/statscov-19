import 'package:flare_flutter/flare_cache.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:statscov/models/api/coordinates.dart';
import 'package:statscov/models/api/covid_compiled/report.dart';
import 'package:statscov/models/api/detailed_report.dart';
import 'package:statscov/models/api/rest_country.dart';
import 'package:statscov/providers/countries_list_provider.dart';
import 'package:statscov/providers/latest_report_provider.dart';
import 'package:statscov/providers/minified_report_provider.dart';
import 'package:statscov/screens/compare_screen/compare_screen_loader.dart';
import 'package:statscov/screens/home_screen/home_screen.dart';
import 'package:statscov/screens/map_screen/map_screen_loader.dart';
import 'package:statscov/screens/stats_screen/stats_screen_loader.dart';
import 'package:statscov/screens/worldwide_screen/worldwide_screen_loader.dart';
import 'package:statscov/utils/constants.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:statscov/utils/custom_animate_route.dart';
import 'package:statscov/utils/dialog_manager.dart';
import 'package:statscov/utils/temp_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlareCache.doesPrune = false;

  final appDocumentsDir =
      await path_provider.getApplicationDocumentsDirectory();
  await initSetup(appDocumentsDir.path);

  await warmupFlare();

  runApp(
    AppConstants(
      child: TempCache(
        child: DialogManager(
          child: StatsCov(appDocumentsDir.path),
        ),
      ),
    ),
  );
}

Future initSetup(String path) async {
  Hive
    ..init(path)
    ..registerAdapter(DetailedReportAdapter())
    ..registerAdapter(ReportAdapter())
    ..registerAdapter(RestCountryAdapter())
    ..registerAdapter(CoordinatesAdapter());
}

const _filesToWarmup = [
  'assets/animations/virus_spread(0).flr',
  'assets/animations/virus_spread(1).flr',
  'assets/animations/virus_spread(2).flr',
  'assets/animations/virus_spread(3).flr',
];

Future<void> warmupFlare() async {
  for (final filename in _filesToWarmup) {
    await cachedActor(AssetFlare(bundle: rootBundle, name: filename));
  }
}

class StatsCov extends StatefulWidget {
  const StatsCov(this.appDocsDirPath);

  final String appDocsDirPath;

  @override
  _StatsCovState createState() => _StatsCovState();
}

class _StatsCovState extends State<StatsCov> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CountriesListProvider>(
            create: (_) => CountriesListProvider(widget.appDocsDirPath)),
        ChangeNotifierProvider<LatestReportsProvider>(
          create: (_) => LatestReportsProvider(widget.appDocsDirPath),
        ),
        ChangeNotifierProvider(
          create: (_) => MinifiedReportProvider(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.of(context).kAppTitle,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppConstants.of(context).kSurfaceColor,
          backgroundColor: AppConstants.of(context).kSurfaceColor,
          accentColor: AppConstants.of(context).kAccentColor,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: AppConstants.of(context).kAccentColor,
          ),
          appBarTheme: AppBarTheme.of(context).copyWith(
            color: AppConstants.of(context).kDarkElevations[0],
          ),
          textTheme: GoogleFonts.robotoTextTheme(
            Theme.of(context).textTheme.apply(
                  bodyColor: AppConstants.of(context).kTextWhite[0],
                ),
          ),
        ),
        home: const HomeScreen(
          isDummy: false,
        ),
        navigatorObservers: [HeroController()],
        // routes: {
        //   '/': (_) => const HomeScreen(),
        //   '/stats': (_) => const StatsScreenLoader(),
        //   '/compare': (_) => const CompareScreenLoader(),
        //   '/worldwide': (_) => const WorldwideScreenLoader(),
        //   '/map': (_) => const MapScreenLoader(),
        // },
        onGenerateRoute: (settings) {
          final routes = {
            '/': const HomeScreen(),
            '/stats': const StatsScreenLoader(),
            '/compare': const CompareScreenLoader(),
            '/worldwide': const WorldwideScreenLoader(),
            '/map': const MapScreenLoader(),
          };

          return CustomAnimateRoute(
            enterPage: routes[settings.name],
            exitPage: (routes[
                (settings.arguments as Map<String, String>)['exitPage']]),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }
}
