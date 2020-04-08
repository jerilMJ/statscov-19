import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:statscov/services/location_service.dart';

enum LocationProviderState { loading, error, ready }

class LocationProvider with ChangeNotifier {
  final _locationService = LocationService();
  Placemark _location;
  LocationProviderState _state;

  void _setState(LocationProviderState state) {
    _state = state;
    notifyListeners();
  }

  LocationProvider() {
    tryLocating();
  }

  Placemark get location => _location;
  LocationProviderState get state => _state;

  void tryLocating() {
    _location = null;
    _setState(LocationProviderState.loading);
    _locationService.getPlacemark().then((loc) {
      _location = loc;
      _setState(LocationProviderState.ready);
    }).catchError((_) {
      _setState(LocationProviderState.error);
    });
  }
}
