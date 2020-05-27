import 'package:flutter/material.dart';
import 'package:statscov/shared/widgets/load_box.dart';
import 'package:statscov/utils/dialog_manager.dart';

class LoadDialogCaller extends StatefulWidget {
  const LoadDialogCaller({this.dialogContent});
  final Widget dialogContent;

  @override
  _LoadDialogCallerState createState() => _LoadDialogCallerState();
}

class _LoadDialogCallerState extends State<LoadDialogCaller> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterBuild);
  }

  void _afterBuild(_) {
    DialogManager.of(context).showDialogPopup(
        context, widget.dialogContent ?? const LoadBox('Retrying'), 'retry');
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
