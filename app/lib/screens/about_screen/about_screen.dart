import 'package:flutter/material.dart';
import 'package:statscov/shared/widgets/ui_card.dart';
import 'package:statscov/utils/constants.dart';
import 'package:statscov/utils/screen_size_util.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              UiCard(
                color: AppConstants.of(context).kDarkElevations[0],
                padding: const EdgeInsets.all(20.0),
                child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Hero(
                              tag: 'app-info',
                              child: Icon(
                                Icons.info_outline,
                                size: ScreenSizeUtil.screenWidth(context,
                                    dividedBy: 5),
                                color: AppConstants.of(context).kAccentColor,
                              ),
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text:
                                      'The data shown in this app is collected by the ',
                                  style: TextStyle(
                                    color:
                                        AppConstants.of(context).kTextWhite[1],
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Center for '
                                          'Systems Science and Engineering (CSSE) at Johns Hopkins University ',
                                      style: TextStyle(
                                        color: AppConstants.of(context)
                                            .kTextWhite[0],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(
                                      text:
                                          'which falls under public non-profit use for health, research and '
                                          'academic purposes.',
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        RichText(
                          text: TextSpan(
                            text:
                                'As the data is contrived from publicly available sources which '
                                'may be conflicting at times, ',
                            style: TextStyle(
                              color: AppConstants.of(context).kTextWhite[1],
                            ),
                            children: [
                              TextSpan(
                                text: 'both JHU and the developer of this app '
                                    'disclaims any and all representations and warranties with respect '
                                    'to the data, including accuracy, fitness for use, reliability, '
                                    'completeness, and non-infringement of third party rights.',
                                style: TextStyle(
                                  color: AppConstants.of(context).kTextWhite[0],
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            FlatButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'OK',
                                style: TextStyle(
                                  color: AppConstants.of(context).kTextWhite[1],
                                ),
                              ),
                              color:
                                  AppConstants.of(context).kDarkElevations[1],
                            ),
                            FlatButton(
                              onPressed: () async => launchUrl(),
                              child: Text(
                                'Source',
                                style: TextStyle(
                                  color: AppConstants.of(context).kTextWhite[1],
                                ),
                              ),
                              color:
                                  AppConstants.of(context).kDarkElevations[1],
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void launchUrl() async {
    try {
      const url = 'https://github.com/jerilmj/statscov-19/sources.md';

      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print(e);
    }
  }
}
