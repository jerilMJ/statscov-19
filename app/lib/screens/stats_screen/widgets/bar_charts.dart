import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statscov/models/api/covid_compiled/report.dart';
import 'package:statscov/providers/tutorial_provider.dart';
import 'package:statscov/screens/stats_screen/utils/bar_chart_utils.dart';
import 'package:statscov/shared/widgets/ui_card.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:statscov/utils/constants.dart';

class BarCharts extends StatefulWidget {
  BarCharts(this.report);
  final Report report;

  @override
  _BarChartsState createState() => _BarChartsState();
}

class _BarChartsState extends State<BarCharts>
    with AutomaticKeepAliveClientMixin {
  List<List<BarChartGroupData>> barGroups;
  List<String> captions;
  List<String> descriptions;
  List<BoxDecoration> boxDecorations;
  List<String> _imgPaths;
  int _selectedPage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    barGroups = BarChartUtils.getBarGroupDatas(widget.report);

    captions = ['Mixed', 'Confirmed', 'Recovered', 'Deaths'];

    descriptions = BarChartUtils.getDescriptions(widget.report);

    boxDecorations = [
      null,
      BoxDecoration(
        color: Colors.blue.shade200,
      ),
      BoxDecoration(
        color: Colors.green.shade200,
      ),
      BoxDecoration(
        color: Colors.red.shade200,
      ),
    ];

    _imgPaths = [
      null,
      'assets/images/confirmed_bg.png',
      'assets/images/recovered_bg.png',
      'assets/images/deaths_bg.png',
    ];

    _selectedPage = 0;
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
  }

  void _afterBuild(_) async {
    TutorialProvider tutorialProvider =
        Provider.of<TutorialProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool shown = (await prefs.getBool('seenStatsTut2')) ?? false;
    tutorialProvider.screenTutorial.tutorialNotFinished();

    if (!shown) {
      Future.delayed(
        Duration(milliseconds: tutorialProvider.shortTutorialDelay),
        () => tutorialProvider.screenTutorial.showTutorial(2),
      );
      await prefs.setBool('seenStatsTut2', true);
    } else {
      tutorialProvider.screenTutorial.tutorialIsFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CarouselSlider.builder(
      initialPage: 0,
      onPageChanged: (index) {
        setState(() {
          _selectedPage = index;
        });
      },
      autoPlay: true,
      enlargeCenterPage: true,
      autoPlayInterval: const Duration(milliseconds: 7000),
      pauseAutoPlayOnTouch: const Duration(milliseconds: 500),
      scrollDirection: Axis.vertical,
      viewportFraction: 0.85,
      height: MediaQuery.of(context).size.height / 2,
      itemCount: barGroups.length,
      itemBuilder: (context, index) {
        return UiCard(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 1000),
            opacity: index == _selectedPage ? 1.0 : 0.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Charts(
                  barGroups: barGroups,
                  imgPaths: _imgPaths,
                  descriptions: descriptions,
                  report: widget.report,
                  index: index,
                ),
                Caption(
                  captions: captions,
                  index: index,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class Caption extends StatelessWidget {
  const Caption({@required this.captions, this.index});

  final List<String> captions;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.width * 0.03,
      ),
      color: AppConstants.of(context).kDarkElevations[0],
      child: Center(
        child: Text(
          captions[index],
          style: TextStyle(color: AppConstants.of(context).kDarkElevations[1]),
        ),
      ),
    );
  }
}

class Charts extends StatelessWidget {
  const Charts({
    Key key,
    @required this.barGroups,
    @required List<String> imgPaths,
    @required this.descriptions,
    @required this.report,
    this.index,
  })  : _imgPaths = imgPaths,
        super(key: key);

  final List<List<BarChartGroupData>> barGroups;
  final List<String> _imgPaths;
  final List<String> descriptions;
  final Report report;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.05,
              ),
              child: BarChart(
                BarChartData(
                  groupsSpace: 100,
                  alignment: BarChartAlignment.center,
                  barTouchData: BarTouchData(
                    enabled: false,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.transparent,
                      tooltipPadding: const EdgeInsets.all(0),
                      tooltipBottomMargin: 0,
                      getTooltipItem: (
                        BarChartGroupData group,
                        int groupIndex,
                        BarChartRodData rod,
                        int rodIndex,
                      ) {
                        return BarTooltipItem(
                          rod.y.round().toString(),
                          TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                            fontSize: MediaQuery.of(context).size.width * 0.03,
                          ),
                        );
                      },
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: barGroups[index],
                  titlesData: FlTitlesData(
                    leftTitles: const SideTitles(showTitles: false),
                    bottomTitles: SideTitles(
                      showTitles: (index == 0) ? true : false,
                      textStyle: const TextStyle(color: Colors.white),
                      getTitles: (value) {
                        return [
                          'Confirmed',
                          'Recovered',
                          'Deaths'
                        ][value.toInt()];
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: index != 0,
            child: Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                height: double.infinity,
                decoration: index != 0
                    ? BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(_imgPaths[index]),
                          fit: BoxFit.cover,
                          alignment: Alignment.centerLeft,
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.5), BlendMode.darken),
                        ),
                      )
                    : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      descriptions[index],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Updated on: ${report.date}',
                        style: TextStyle(
                          color: AppConstants.of(context).kTextWhite[0],
                          fontSize: MediaQuery.of(context).size.width * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
