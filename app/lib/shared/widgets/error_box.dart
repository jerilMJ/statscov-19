import 'dart:io';

import 'package:flutter/material.dart';
import 'package:statscov/utils/constants.dart';
import 'package:statscov/utils/dialog_manager.dart';
import 'package:statscov/utils/exceptions.dart';
import 'package:statscov/utils/screen_size_util.dart';

class ErrorBox extends StatefulWidget {
  const ErrorBox(
      {@required this.tryAgain, @required this.context, @required this.error});

  final Function tryAgain;
  final BuildContext context;
  final dynamic error;

  @override
  _ErrorBoxState createState() => _ErrorBoxState();
}

class _ErrorBoxState extends State<ErrorBox> {
  String errorMessage;
  String errorCode;

  @override
  void initState() {
    super.initState();

    switch (widget.error.runtimeType) {
      case SocketException:
        errorMessage =
            'Unable to fetch data. No network conection! Please connect to the internet and try again.';
        errorCode = "001";
        break;

      case HttpClientSideException:
        errorCode = "002";
        errorMessage = widget.error.toString();
        break;
      case HttpServerSideException:
        errorCode = "003";
        errorMessage = widget.error.toString();
        break;
      case HttpOtherException:
        errorCode = "004";
        errorMessage = widget.error.toString();
        break;

      default:
        errorCode = "100";
        errorMessage =
            'Unkown error occurred. Try restarting the app. If this persists, '
            'please contact the app developer with the details.';
    }
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
  }

  void _afterBuild(_) {
    Future.delayed(const Duration(milliseconds: 100),
        () => DialogManager.of(context).clearDialogs());
  }

  @override
  Widget build(BuildContext thisContext) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: ScreenSizeUtil.screenWidth(context, dividedBy: 1.5),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset('assets/images/error_sprite.png'),
                ),
              ),
              Text(
                '$errorMessage \n\n $errorCode',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30.0),
              RaisedButton(
                onPressed: widget.tryAgain,
                child: const Text('Try Again'),
                color: AppConstants.of(thisContext).kDarkElevations[2],
              ),
              RaisedButton(
                onPressed: () => Navigator.of(widget.context).pop(),
                child: const Text('Go Back'),
                color: AppConstants.of(thisContext).kDarkElevations[0],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
