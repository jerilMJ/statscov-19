import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected;

  bool get isConnected => _isConnected;

  StreamSubscription<ConnectivityResult> getConnectivitySubscription(
      Function onData) {
    return _connectivity.onConnectivityChanged.listen(onData);
  }

  Future<bool> getConnectivityStatus() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e);
    }

    return _updateConnectionStatus(result);
  }

  bool _updateConnectionStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.none:
        _isConnected = false;
        return false;
        break;
      default:
        _isConnected = true;
        return true;
        break;
    }
  }
}
