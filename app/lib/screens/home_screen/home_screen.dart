import 'dart:async';
import 'dart:math';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_cache_builder.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:statscov/screens/about_screen/about_screen.dart';
import 'package:statscov/services/connectivity_service.dart';
import 'package:statscov/shared/widgets/jump_alert.dart';
import 'package:statscov/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({this.isDummy = true});
  final bool isDummy;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ConnectivityService _connectivityService;
  final FlareControls controls = FlareControls();
  final maxOpacity = 0.4;
  final minOpacity = 0.0;
  double animOpacity;
  bool animComplete;

  @override
  void initState() {
    super.initState();
    animOpacity = maxOpacity;
    animComplete = true;
    if (widget.isDummy) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
    _connectivityService = ConnectivityService();
  }

  void _afterBuild(_) {
    checkConnectivity();

    Future.delayed(const Duration(milliseconds: 1500), () {
      controls.play('assemble');

      Future.delayed(
        const Duration(milliseconds: 1500),
        () => controls.play('roaming'),
      );
    });
  }

  void showAnim() {
    setState(() {
      animOpacity = maxOpacity;
    });
  }

  void fadeAnim() {
    setState(() {
      animOpacity = minOpacity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: widget.isDummy,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Listener(
                  onPointerDown: (_) {
                    if (animComplete && animOpacity == maxOpacity) {
                      animComplete = false;
                      controls.play('scatter');
                      Future.delayed(const Duration(milliseconds: 400), () {
                        fadeAnim();
                        Future.delayed(const Duration(milliseconds: 1000),
                            () => animComplete = true);
                      });
                    }
                  },
                  onPointerUp: (_) {
                    showAnim();
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      widget.isDummy
                          ? Container()
                          : AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: animOpacity,
                              child: FlareCacheBuilder(
                                [
                                  AssetFlare(
                                    bundle: rootBundle,
                                    name:
                                        'assets/animations/virus_spread(0).flr',
                                  ),
                                  AssetFlare(
                                    bundle: rootBundle,
                                    name:
                                        'assets/animations/virus_spread(1).flr',
                                  ),
                                  AssetFlare(
                                    bundle: rootBundle,
                                    name:
                                        'assets/animations/virus_spread(2).flr',
                                  ),
                                  AssetFlare(
                                    bundle: rootBundle,
                                    name:
                                        'assets/animations/virus_spread(3).flr',
                                  ),
                                ],
                                builder: (_, isWarm) {
                                  return !isWarm
                                      ? Container()
                                      : FlareActor.asset(
                                          AssetFlare(
                                            bundle: rootBundle,
                                            name:
                                                'assets/animations/virus_spread(${Random().nextInt(4)}).flr',
                                          ),
                                          isPaused: widget.isDummy,
                                          alignment: Alignment.center,
                                          fit: BoxFit.contain,
                                          color: [
                                            Colors.red.shade200,
                                            Colors.orange.shade200,
                                            Colors.yellow.shade200,
                                            Colors.blue.shade200,
                                            Colors.green.shade200,
                                            Colors.indigo.shade200,
                                          ][Random().nextInt(6)],
                                          controller: controls,
                                        );
                                },
                              ),
                            ),
                      TitleCard(widget.isDummy),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Menu(
                  widget.isDummy,
                  flareControls: controls,
                  fadeAnim: fadeAnim,
                  showAnim: showAnim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkConnectivity() async {
    _connectivityService.getConnectivityStatus().then((isConnected) {
      if (!isConnected) {
        showDialog(
          context: context,
          builder: (context) => const JumpAlert(
            text: 'It seems like you\'re not connected to the internet. '
                'You will be able to view only cached data if it exists. \n\n'
                'Connect to the internet to fetch the latest data.',
          ),
        );
      }
    });
  }
}

class TitleCard extends StatelessWidget {
  const TitleCard(this.isDummy);
  final bool isDummy;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            tooltip: 'About',
            icon: Hero(
              tag: 'app-info',
              child: Icon(
                Icons.info_outline,
                color: AppConstants.of(context).kTextWhite[1],
              ),
            ),
            onPressed: () => showBottomSheet(
              context: context,
              builder: (_) => AboutScreen(),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: TweenAnimationBuilder(
                tween: Tween(
                  begin: isDummy ? 1.0 : 0.0,
                  end: 1.0,
                ),
                duration: const Duration(milliseconds: 1000),
                child: Text(
                  AppConstants.of(context).kAppTitle,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                builder: (_, scale, child) =>
                    Transform.scale(scale: scale, child: child),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Menu extends StatelessWidget {
  Menu(this.isDummy, {this.flareControls, this.fadeAnim, this.showAnim});
  final bool isDummy;
  final FlareControls flareControls;
  final Function fadeAnim;
  final Function showAnim;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(
                child: LtRSlide(
                  animate: !isDummy,
                  child: MenuCard(
                    routeName: '/stats',
                    icon: Icons.looks_one,
                    title: 'Individual Reports',
                    imagePath: 'assets/images/individual_reports.png',
                    textBg: Colors.blue.shade200,
                    flareControls: flareControls,
                    fadeAnim: fadeAnim,
                    showAnim: showAnim,
                  ),
                ),
              ),
              Expanded(
                child: RtLSlide(
                  animate: !isDummy,
                  child: MenuCard(
                    routeName: '/compare',
                    icon: Icons.compare_arrows,
                    title: 'Compare Reports',
                    imagePath: 'assets/images/compare_reports.png',
                    textBg: Colors.green.shade200,
                    flareControls: flareControls,
                    fadeAnim: fadeAnim,
                    showAnim: showAnim,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(
                child: LtRSlide(
                  animate: !isDummy,
                  child: MenuCard(
                    routeName: '/worldwide',
                    icon: Icons.vpn_lock,
                    title: 'Worldwide Report',
                    imagePath: 'assets/images/worldwide_report.png',
                    textBg: Colors.red.shade200,
                    flareControls: flareControls,
                    fadeAnim: fadeAnim,
                    showAnim: showAnim,
                  ),
                ),
              ),
              Expanded(
                child: RtLSlide(
                  animate: !isDummy,
                  child: MenuCard(
                    routeName: '/map',
                    icon: Icons.map,
                    title: 'Pandemic Map',
                    imagePath: 'assets/images/pandemic_map.png',
                    textBg: Colors.purple.shade200,
                    flareControls: flareControls,
                    fadeAnim: fadeAnim,
                    showAnim: showAnim,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RtLSlide extends StatelessWidget {
  const RtLSlide({@required this.child, @required this.animate});

  final Widget child;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final begin = animate ? MediaQuery.of(context).size.width / 2 : 0.0;
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(
        begin: Offset(begin, 0.0),
        end: const Offset(0.0, 0.0),
      ),
      builder: (_, offset, child) => Transform.translate(
        offset: offset,
        child: child,
      ),
      child: child,
    );
  }
}

class LtRSlide extends StatelessWidget {
  const LtRSlide({@required this.child, @required this.animate});

  final Widget child;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final begin = animate ? -MediaQuery.of(context).size.width / 2 : 0.0;
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(
        begin: Offset(begin, 0.0),
        end: const Offset(0.0, 0.0),
      ),
      builder: (_, offset, child) => Transform.translate(
        offset: offset,
        child: child,
      ),
      child: child,
    );
  }
}

class MenuCard extends StatelessWidget {
  const MenuCard({
    @required this.routeName,
    @required this.icon,
    @required this.title,
    @required this.textBg,
    this.imagePath,
    this.color,
    this.flareControls,
    this.fadeAnim,
    this.showAnim,
  });

  final String routeName;
  final IconData icon;
  final String title;
  final Color color;
  final Color textBg;
  final String imagePath;
  final FlareControls flareControls;
  final Function fadeAnim;
  final Function showAnim;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: RaisedButton(
          elevation: 10.0,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          color: color ?? AppConstants.of(context).kDarkElevations[0],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          onLongPress: () {
            flareControls.play('scatter');
            Future.delayed(const Duration(milliseconds: 400), () => fadeAnim());
          },
          onPressed: () {
            fadeAnim();
            Navigator.of(context).pushNamed(routeName, arguments: {
              'exitPage': '/',
              'enterPage': routeName,
            }).then((_) {
              Future.delayed(
                  const Duration(milliseconds: 2500), () => showAnim());
            });
          },
          padding: EdgeInsets.zero,
          child: Stack(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    image: AssetImage(imagePath),
                    colorFilter: ColorFilter.mode(
                      AppConstants.of(context).kDarkElevations[0],
                      BlendMode.saturation,
                    ),
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: HSLColor.fromColor(textBg)
                            .withLightness(0.2)
                            .withSaturation(0.1)
                            .toColor(),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: const Radius.circular(5.0),
                          bottomRight: const Radius.circular(5.0),
                        ),
                      ),
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: textBg.withOpacity(0.87),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
