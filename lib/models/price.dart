import 'package:equatable/equatable.dart';

/// Représente la structure de tarification des courses.
class Price extends Equatable {
  /// Le tarif de base d'une course.
  final double baseFare;

  /// Le coût par kilomètre pour une course.
  final double perKilometer;

  /// Le coût par minute pour une course.
  final double perMinute;

  /// Les frais facturés si une course est annulée.
  final double cancellationFee;

  const Price({
    required this.baseFare,
    required this.perKilometer,
    required this.perMinute,
    required this.cancellationFee,
  })  : assert(baseFare >= 0, 'Le tarif de base doit être non négatif'),
        assert(perKilometer >= 0, 'Le coût par kilomètre doit être non négatif'),
        assert(perMinute >= 0, 'Le coût par minute doit être non négatif'),
        assert(cancellationFee >= 0, 'Les frais d\'annulation doivent être non négatifs');

  /// Crée une copie de ce prix avec les champs donnés remplacés par les nouvelles valeurs.
  Price copyWith({
    double? baseFare,
    double? perKilometer,
    double? perMinute,
    double? cancellationFee,
  }) {
    return Price(
      baseFare: baseFare ?? this.baseFare,
      perKilometer: perKilometer ?? this.perKilometer,
      perMinute: perMinute ?? this.perMinute,
      cancellationFee: cancellationFee ?? this.cancellationFee,
    );
  }

  @override
  List<Object?> get props => [baseFare, perKilometer, perMinute, cancellationFee];

  @override
  String toString() {
    return 'Price{baseFare: $baseFare, perKilometer: $perKilometer, perMinute: $perMinute, cancellationFee: $cancellationFee}';
  }
}