import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

enum UserRole {
  client,
  chauffeur,
}

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final GeoPoint localisation;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.localisation,
  });

  // Conversion d'un utilisateur Firestore à un objet User
  factory User.fromFirestore(Map<String, dynamic> firestoreData, String id) {
    String roleString = firestoreData['role'] ?? 'client'; // Récupérer comme String
    UserRole role;

    switch (roleString) {
      case 'chauffeur':
        role = UserRole.chauffeur;
        break;
      default: // 'client' ou autre valeur non reconnue
        role = UserRole.client;
        break;
    }

    return User(
      id: id,
      name: firestoreData['name'] ?? '',
      email: firestoreData['email'] ?? '',
      phone: firestoreData['phone'] ?? '',
      role: role,
      localisation: firestoreData['localisation'] ?? GeoPoint(0.0, 0.0), // Défaut à (0, 0)
    );
  }

  // Méthode pour convertir l'enum en string pour l'écriture dans Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toString().split('.').last, // Convertit l'enum en string
      'localisation': localisation,
    };
  }

  // Fonction pour récupérer la position actuelle de l'utilisateur
  static Future<GeoPoint> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return GeoPoint(position.latitude, position.longitude);
    } catch (e) {
      print('Erreur lors de la récupération de la position : $e');
      return GeoPoint(0.0, 0.0); // Retourne une localisation par défaut en cas d'erreur
    }
  }
}
