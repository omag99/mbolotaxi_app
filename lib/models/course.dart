import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:equatable/equatable.dart';

/// Représente une course (une instance spécifique d'une course). Ceci pourrait être fusionné avec l'entité Ride.
class Course extends Equatable {
  /// L'identifiant unique de la course.
  final String id;

  /// L'ID du passager (client) pour cette course.
  final String passagerId;

  /// L'ID du chauffeur pour cette course.
  final String chauffeurId;

  /// Le lieu de départ (prise en charge) de la course.
  final LatLng depart;

  /// Le lieu de destination de la course.
  final LatLng destination;

  /// Le tarif (prix) de la course.
  final double tarif;

  /// Le statut de la course (par exemple, "planifiée", "en cours", "terminée", "annulée").
  final String statut;

  const Course({
    required this.id,
    required this.passagerId,
    required this.chauffeurId,
    required this.depart,
    required this.destination,
    required this.tarif,
    required this.statut,
  });

  /// Crée une copie de cette course avec les champs donnés remplacés par les nouvelles valeurs.
  Course copyWith({
    String? id,
    String? passagerId,
    String? chauffeurId,
    LatLng? depart,
    LatLng? destination,
    double? tarif,
    String? statut,
  }) {
    return Course(
      id: id ?? this.id,
      passagerId: passagerId ?? this.passagerId,
      chauffeurId: chauffeurId ?? this.chauffeurId,
      depart: depart ?? this.depart,
      destination: destination ?? this.destination,
      tarif: tarif ?? this.tarif,
      statut: statut ?? this.statut,
    );
  }

  @override
  List<Object?> get props => [id, passagerId, chauffeurId, depart, destination, tarif, statut];

  @override
  String toString() {
    return 'Course{id: $id, passagerId: $passagerId, chauffeurId: $chauffeurId, depart: $depart, destination: $destination, tarif: $tarif, statut: $statut}';
  }
}