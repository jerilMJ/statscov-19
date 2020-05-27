import 'package:flutter/material.dart';
import 'package:statscov/providers/worldwide_report_provider.dart';
import 'package:statscov/utils/constants.dart';

class OrderedPercentages extends StatelessWidget {
  const OrderedPercentages({
    @required this.borderRadius,
    @required WorldwideReportProvider worldwideReportProvider,
  }) : _worldwideReportProvider = worldwideReportProvider;

  final BorderRadius borderRadius;
  final WorldwideReportProvider _worldwideReportProvider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 40.0,
        left: 5.0,
        right: 5.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppConstants.of(context).kDarkElevations[0],
          borderRadius: borderRadius,
        ),
        child: CustomPaint(
          painter: PhoneTopPainter(),
          child: Scrollbar(
            child: ListView.builder(
                itemCount: _worldwideReportProvider.countryWiseReports.length,
                itemBuilder: (_, index) {
                  var name = _worldwideReportProvider
                      .countryWiseReports[index].countryName;
                  var percentage = (_worldwideReportProvider
                              .countryWiseReports[index].confirmed *
                          100 /
                          _worldwideReportProvider.report.confirmed)
                      .toStringAsPrecision(3);
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text('${index + 1}.'),
                            ),
                            Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text('$percentage%'),
                                )),
                            Expanded(flex: 3, child: Text('$name')),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Container(
                          color: AppConstants.of(context).kDarkElevations[1],
                          height: 2.5,
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}

class PhoneTopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.purpleAccent.shade200;
    canvas.drawCircle(const Offset(30.0, -20.0), 10.0, paint);

    paint.color = Colors.purple.shade200;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: const Offset(100.0, -20.0), width: 100.0, height: 10.0),
          const Radius.circular(10.0),
        ),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
