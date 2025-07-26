import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:equatable/equatable.dart';

/// Représente une course demandée par un client.
class Ride extends Equatable {
  /// L'identifiant unique de la course.
  final String rideId;

  /// L'ID du client qui a demandé la course.
  final String clientId;

  /// L'ID du chauffeur assigné à la course (peut être null).
  final String? driverId;

  /// La position où le client souhaite être pris en charge.
  final LatLng pickupLocation;

  /// La position de destination pour la course.
  final LatLng destination;

  /// Le statut de la course : "requested", "assigned", "in_progress", "completed", "cancelled".
  final String status;

  /// Le prix estimé de la course.
  final double? estimatedPrice;

  /// L'heure à laquelle la course a été demandée.
  final DateTime? requestTime;

  /// L'heure à laquelle le chauffeur a accepté la course.
  final DateTime? acceptedTime;

  /// L'heure à laquelle la course a commencé.
  final DateTime? startTime;

  /// L'heure à laquelle la course s'est terminée.
  final DateTime? endTime;

  const Ride({
    required this.rideId,
    required this.clientId,
    this.driverId,
    required this.pickupLocation,
    required this.destination,
    required this.status,
    this.estimatedPrice,
    this.requestTime,
    this.acceptedTime,
    this.startTime,
    this.endTime,
  }) : assert(status == 'requested' ||
      status == 'assigned' ||
      status == 'in_progress' ||
      status == 'completed' ||
      status == 'cancelled', 'Statut invalide');

  /// Crée une copie de cette course avec les champs donnés remplacés par les nouvelles valeurs.
  Ride copyWith({
    String? rideId,
    String? clientId,
    String? driverId,
    LatLng? pickupLocation,
    LatLng? destination,
    String? status,
    double? estimatedPrice,
    DateTime? requestTime,
    DateTime? acceptedTime,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return Ride(
      rideId: rideId ?? this.rideId,
      clientId: clientId ?? this.clientId,
      driverId: driverId ?? this.driverId,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destination: destination ?? this.destination,
      status: status ?? this.status,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      requestTime: requestTime ?? this.requestTime,
      acceptedTime: acceptedTime ?? this.acceptedTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  List<Object?> get props => [
    rideId,
    clientId,
    driverId,
    pickupLocation,
    destination,
    status,
    estimatedPrice,
    requestTime,
    acceptedTime,
    startTime,
    endTime
  ];

  @override
  String toString() {
    return 'Ride{rideId: $rideId, clientId: $clientId, driverId: $driverId, pickupLocation: $pickupLocation, destination: $destination, status: $status, estimatedPrice: $estimatedPrice, requestTime: $requestTime, acceptedTime: $acceptedTime, startTime: $startTime, endTime: $endTime}';
  }
}