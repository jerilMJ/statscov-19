import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statscov/models/api/country.dart';
import 'package:statscov/models/api/iso_name.dart';
import 'package:statscov/providers/countries_list_provider.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/screens/compare_screen/compare_screen_loader.dart';
import 'package:statscov/screens/compare_screen/providers/compare_utility_provider.dart';
import 'package:statscov/screens/compare_screen/providers/overlay_provider.dart';
import 'package:statscov/screens/compare_screen/utils/compare_screen_tutorial.dart';
import 'package:statscov/screens/compare_screen/widgets/empty.dart';
import 'package:statscov/screens/compare_screen/widgets/graph_card.dart';
import 'package:statscov/screens/compare_screen/widgets/graph_controllers.dart';
import 'package:statscov/shared/widgets/country_search_delegate.dart';
import 'package:statscov/shared/widgets/error_box.dart';
import 'package:statscov/shared/widgets/ui_card.dart';
import 'package:statscov/utils/constants.dart';
import 'package:statscov/utils/dialog_manager.dart';
import 'package:statscov/utils/screen_size_util.dart';
import 'package:statscov/utils/tab_bar_choice.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OverlayProvider(
        Provider.of<CompareUtilityProvider>(context, listen: false),
      ),
      child: const CompareScreenScaffold(),
    );
  }
}

class CompareScreenScaffold extends StatefulWidget {
  const CompareScreenScaffold();

  @override
  _CompareScreenScaffoldState createState() => _CompareScreenScaffoldState();
}

class _CompareScreenScaffoldState extends State<CompareScreenScaffold>
    with TickerProviderStateMixin {
  TabController _tabController;
  List<Country> _selected;
  List<Country> _previouslySelected;
  TutorialProvider _tutorialProvider;
  CompareScreenTutorial _compareScreenTutorial;
  final List<TabBarChoice> choices = <TabBarChoice>[
    const TabBarChoice(title: 'Confirmed'),
    const TabBarChoice(title: 'Recovered'),
    const TabBarChoice(title: 'Deaths'),
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: choices.length, vsync: this);
    _compareScreenTutorial = CompareScreenTutorial(context, _tabController);
    _tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    _tutorialProvider.screenTutorial = _compareScreenTutorial;

    _selected = Provider.of<CompareUtilityProvider>(context, listen: false)
        .pinnedCountries;
    _previouslySelected = [];

    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
  }

  void _afterBuild(_) async {
    _tutorialProvider.screenTutorial.tutorialNotFinished();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shown = (await prefs.getBool('seenCompareTut0')) ?? false;
    if (!shown) {
      Future.delayed(
        Duration(milliseconds: _tutorialProvider.tutorialDelay),
        () => _tutorialProvider.screenTutorial.showTutorial(0),
      );
      await prefs.setBool('seenCompareTut0', true);
    } else {
      _tutorialProvider.screenTutorial.tutorialIsFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = WillPopScope(
      onWillPop: () async {
        if (_compareScreenTutorial.tutorialFinished) {
          Provider.of<OverlayProvider>(context, listen: false).hideOverlay();
        }
        return _compareScreenTutorial.tutorialFinished;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppConstants.of(context).kAppTitle,
            style: const TextStyle(fontSize: 20.0),
          ),
          leading: IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Provider.of<OverlayProvider>(context, listen: false)
                  .hideOverlay();
              Navigator.of(context).maybePop();
            },
          ),
          actions: <Widget>[
            Consumer2<CountriesListProvider, CompareUtilityProvider>(
              builder: (_, countriesListProvider, compareUtilityProvider, __) {
                return IconButton(
                  tooltip: 'Add country',
                  key: _tutorialProvider.getKeyFor("addOption"),
                  icon: Icon(
                    Icons.add,
                    color: AppConstants.of(context).kTextWhite[1],
                  ),
                  onPressed: () {
                    Provider.of<OverlayProvider>(context, listen: false)
                        .hideOverlay();
                    _previouslySelected = List.from(_selected);
                    openSearch(
                        context, countriesListProvider, compareUtilityProvider);
                  },
                );
              },
            ),
            Consumer2<CompareUtilityProvider, TutorialProvider>(
              builder: (_, compareUtilityProvider, tutorialProvider, __) =>
                  PopupMenuButton(
                onSelected: (val) {
                  switch (val) {
                    case 'clear':
                      _selected = [];
                      _previouslySelected = [];
                      compareUtilityProvider.clearAll();
                      break;
                    case 'unpin':
                      compareUtilityProvider.unpinAll();
                      break;
                    case 'help':
                      _tutorialProvider.screenTutorial
                          .showTutorial(1)
                          .catchError((_) =>
                              _tutorialProvider.screenTutorial.showTutorial(0));
                      break;
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: const Text('Clear All'),
                  ),
                  const PopupMenuItem(
                    value: 'unpin',
                    child: const Text('Unpin All'),
                  ),
                  const PopupMenuItem(
                    value: 'help',
                    child: const Text('Help'),
                  ),
                ],
                padding: EdgeInsets.zero,
                offset: Offset(0.0, kToolbarHeight),
                tooltip: 'Options',
              ),
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.purple.shade200,
            unselectedLabelColor: AppConstants.of(context).kDarkElevations[2],
            indicatorColor: AppConstants.of(context).kDarkElevations[2],
            controller: _tabController,
            isScrollable: false,
            tabs: zip([
              choices,
              [
                _tutorialProvider.getKeyFor("tabOne"),
                _tutorialProvider.getKeyFor("tabTwo"),
                _tutorialProvider.getKeyFor("tabThree")
              ]
            ]).map(
              (pair) {
                return Tab(
                  key: pair[1],
                  text: (pair[0] as TabBarChoice).title,
                );
              },
            ).toList(),
          ),
        ),
        body: CompareScreenBody(
          tabController: _tabController,
          selected: _selected,
        ),
      ),
    );

    final loader = const CompareScreenLoadBox('Checking cache...');

    return Consumer<CompareUtilityProvider>(
      builder: (_, compareUtilityProvider, __) {
        if (compareUtilityProvider.state == CompareUtilityProviderState.ready) {
          _selected = compareUtilityProvider.selected.cases
                  .map((k, v) =>
                      MapEntry(k, Country(IsoName().iso3ToCountry(k), k, null)))
                  .values
                  .toList() ??
              [];
          return child;
        } else {
          return loader;
        }
      },
    );
  }

  void openSearch(
      BuildContext context,
      CountriesListProvider countriesListProvider,
      CompareUtilityProvider compareUtilityProvider) {
    _previouslySelected = _selected;
    showSearch(
      context: context,
      delegate: CountrySearchDelegate(
        countriesListProvider.countriesList,
        multiSelect: true,
        selected: List.from(_selected),
      ),
    ).then(
      (countries) {
        if (countries != null) {
          _selected = List.from(countries);

          _previouslySelected.where((p) => !_selected.contains(p)).forEach(
              (unselected) =>
                  compareUtilityProvider.removeSelection(unselected.isoCode));

          _selected.forEach((country) =>
              compareUtilityProvider.addSelection(country.isoCode));
        }
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class CompareScreenBody extends StatefulWidget {
  const CompareScreenBody({
    Key key,
    @required TabController tabController,
    @required List<Country> selected,
  })  : _tabController = tabController,
        _selected = selected,
        super(key: key);

  final TabController _tabController;
  final List<Country> _selected;

  @override
  _CompareScreenBodyState createState() => _CompareScreenBodyState();
}

class _CompareScreenBodyState extends State<CompareScreenBody>
    with TickerProviderStateMixin {
  OverlayProvider _overlayProvider;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
  }

  void _afterBuild(_) {
    _overlayProvider = Provider.of<OverlayProvider>(context, listen: false);
    final tutorialProvider =
        Provider.of<TutorialProvider>(context, listen: false);

    _overlayProvider.initControllers(
      this,
      context,
      tutorialProvider.getKeyFor('popup'),
    );
    tutorialProvider.addStateFunction(
        'showPopup', _overlayProvider.showOverlay);
    tutorialProvider.addStateFunction(
        'hidePopup', _overlayProvider.hideOverlayWithDelay);
    Overlay.of(context).insert(_overlayProvider.overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompareUtilityProvider>(
      builder: (_, compareUtilityProvider, __) {
        if (compareUtilityProvider.state == CompareUtilityProviderState.ready) {
          WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(
              const Duration(milliseconds: 100),
              () => DialogManager.of(context).clearDialogs()));

          if (compareUtilityProvider.nothingToCompare) {
            return const Empty();
          } else {
            return CompareWindow(
              tabController: widget._tabController,
              selected: widget._selected,
            );
          }
        } else if (compareUtilityProvider.state ==
            CompareUtilityProviderState.error) {
          return ErrorBox(
            tryAgain: () => {},
            context: context,
            error: compareUtilityProvider.error,
          );
        } else {
          return Container();
        }
      },
    );
  }

  @override
  void dispose() {
    _overlayProvider.disposeControllers();
    super.dispose();
  }
}

class CompareWindow extends StatefulWidget {
  const CompareWindow({
    @required TabController tabController,
    @required List<Country> selected,
  })  : _tabController = tabController,
        _selected = selected;

  final TabController _tabController;
  final List<Country> _selected;

  @override
  _CompareWindowState createState() => _CompareWindowState();
}

class _CompareWindowState extends State<CompareWindow>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer2<CompareUtilityProvider, TutorialProvider>(
      builder: (_, compareUtilityProvider, tutorialProvider, __) => Container(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  SizedBox(
                    height: ScreenSizeUtil.screenHeight(context, dividedBy: 2),
                    child: UiCard(
                      child: TabBarView(
                        controller: widget._tabController,
                        children: <Widget>[
                          GraphCard(
                            compareUtilityProvider.selected,
                            GraphMode.confirmed,
                            tabIndex: 0,
                          ),
                          GraphCard(
                            compareUtilityProvider.selected,
                            GraphMode.recovered,
                            tabIndex: 1,
                            isPercentage: true,
                          ),
                          GraphCard(
                            compareUtilityProvider.selected,
                            GraphMode.deaths,
                            tabIndex: 2,
                            isPercentage: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            DateAxisControllers(
              compareUtilityProvider: compareUtilityProvider,
            ),
            PlotControllers(
              compareUtilityProvider: compareUtilityProvider,
              selected: widget._selected,
            ),
          ],
        ),
      ),
    );
  }
}
