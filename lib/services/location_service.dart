import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Placemark> getPlacemark() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    Position position = await geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.low)
        .catchError((error) => null)
        .timeout(Duration(milliseconds: 3000), onTimeout: () => null);

    if (position == null) {
      position = await geolocator
          .getLastKnownPosition(desiredAccuracy: LocationAccuracy.low)
          .catchError((error) => null)
          .timeout(Duration(milliseconds: 3000), onTimeout: () => null);
    }

    List<Placemark> p = await geolocator
        .placemarkFromPosition(position)
        .catchError((error) => null);

    return p != null ? p.first : null;
  }
}
