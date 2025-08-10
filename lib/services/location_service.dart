import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    const settings = LocationSettings(accuracy: LocationAccuracy.medium);
    return Geolocator.getCurrentPosition(locationSettings: settings);
  }
}
