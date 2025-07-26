import 'package:google_maps_flutter/google_maps_flutter.dart';

class Driver {
  final String id;
  final String name;
  final String phone;
  final LatLng location;
  final String status; // "available", "on_ride", "offline"

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
    required this.status,
  });

  // Conversion d'un document Firestore à un objet Driver
  factory Driver.fromFirestore(Map<String, dynamic> firestoreData, String id) {
    return Driver(
      id: id,
      name: firestoreData['name'] ?? '',
      phone: firestoreData['phone'] ?? '',
      location: LatLng(
        firestoreData['location'].latitude,
        firestoreData['location'].longitude,
      ),
      status: firestoreData['status'] ?? 'available',
    );
  }
}
