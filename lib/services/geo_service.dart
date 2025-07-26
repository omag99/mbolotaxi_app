import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeoService {
  // Coordonnées de Libreville, Gabon
  static const LIBREVILLE_LAT = 0.3925;
  static const LIBREVILLE_LNG = 9.4536;
  static const LIBREVILLE_LATLNG = LatLng(LIBREVILLE_LAT, LIBREVILLE_LNG);
  // Rayon maximal en mètres pour considérer que l'utilisateur est à Libreville
  static const MAX_DISTANCE_METERS = 50000; // 50 km (ajuste selon tes besoins)

  /// Vérifie si les services de localisation sont activés.
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Demande les permissions de localisation à l'utilisateur.
  static Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Obtient la position actuelle de l'utilisateur.
  /// Si l'utilisateur n'est pas à Libreville, retourne une erreur ou une position par défaut.
  static Future<Position?> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Vérifier si l'utilisateur est à Libreville
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        LIBREVILLE_LAT,
        LIBREVILLE_LNG,
      );

      if (distance <= MAX_DISTANCE_METERS) {
        return position;
      } else {
        print("L'utilisateur n'est pas à Libreville. Distance: $distance mètres");
        // Option 1: Retourner null (indiquer une erreur)
        // return null;

        // Option 2: Retourner une position par défaut à Libreville
        return Position(
          latitude: LIBREVILLE_LAT,
          longitude: LIBREVILLE_LNG,
          timestamp: DateTime.now(),
          accuracy: 10, // Ajuste l'accuracy selon tes besoins
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0, altitudeAccuracy: 0, headingAccuracy: 0,
        );
      }
    } catch (e) {
      print("Erreur lors de l'obtention de la position: $e");
      return null;
    }
  }

  /// Calcule la distance en mètres entre deux points (LatLng).
  static double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  /// Convertit une adresse en coordonnées géographiques (LatLng).
  /// Limite la conversion aux adresses de Libreville.
  static Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        //Vérifie si l'adresse est proche de Libreville
        double distance = Geolocator.distanceBetween(
            locations.first.latitude,
            locations.first.longitude,
            LIBREVILLE_LAT,
            LIBREVILLE_LNG
        );

        if (distance <= MAX_DISTANCE_METERS){
          return LatLng(locations.first.latitude, locations.first.longitude);
        }
        else{
          print("L'adresse n'est pas à Libreville.");
          return null;
        }


      } else {
        print("Aucun résultat trouvé pour l'adresse: $address");
        return null;
      }
    } catch (e) {
      print("Erreur lors de la conversion de l'adresse en coordonnées: $e");
      return null;
    }
  }

  /// Convertit des coordonnées géographiques (LatLng) en une adresse.
  /// Limite la conversion aux coordonnées proches de Libreville.
  static Future<String?> getAddressFromLatLng(LatLng latLng) async {
    try {
      //Vérifie si les coordonnées sont proches de Libreville
      double distance = Geolocator.distanceBetween(
          latLng.latitude,
          latLng.longitude,
          LIBREVILLE_LAT,
          LIBREVILLE_LNG
      );

      if (distance <= MAX_DISTANCE_METERS){
        List<Placemark> placemarks = await placemarkFromCoordinates(
            latLng.latitude,
            latLng.longitude
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          return "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        } else {
          print("Aucun résultat trouvé pour les coordonnées: $latLng");
          return null;
        }
      } else {
        print("Les coordonnées ne sont pas à Libreville.");
        return null;
      }


    } catch (e) {
      print("Erreur lors de la conversion des coordonnées en adresse: $e");
      return null;
    }
  }
}