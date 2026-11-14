import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double? latitude, longitude, accuracy;
  final String status; // available or unavailable
  final String? reason;

  LocationResult.available(this.latitude, this.longitude, this.accuracy)
    : status = 'available',
      reason = null;

  LocationResult.unavailable(this.reason)
    : latitude = null,
      longitude = null,
      accuracy = null,
      status = 'unavailable';
}

class LocationService {
  Future<LocationResult> getCurrent({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return LocationResult.unavailable('Location services are off');
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return LocationResult.unavailable('Location permission denied');
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: timeout,
        ),
      );
      return LocationResult.available(
        pos.latitude,
        pos.longitude,
        pos.accuracy,
      );
    } catch (e) {
      return LocationResult.unavailable('No location fix: $e');
    }
  }
}
