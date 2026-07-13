import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

import '../error/app_exception.dart';

abstract class LocationService {
  Future<Position> getCurrentPosition();
}

@LazySingleton(as: LocationService)
class LocationServiceImpl implements LocationService {
  @override
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw const LocationException(
        'Location services are disabled. Please enable them and try again.',
      );
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationException('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permission was permanently denied. Please enable it from settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}
