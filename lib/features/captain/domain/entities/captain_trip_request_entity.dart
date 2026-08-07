import 'package:equatable/equatable.dart';

class CaptainTripRequestEntity extends Equatable {
  final String id;
  final String title;
  final String passengerName;
  final String passengerPhone;
  final double passengerRating;
  final String description;
  final String pickup;
  final String dropoff;
  final String distance;
  final String eta;
  final String duration;
  final String price;
  final double grossFare;
  final String timeTag;
  final bool isParcel;
  final List<String> stops;

  const CaptainTripRequestEntity({
    required this.id,
    required this.title,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerRating,
    required this.description,
    required this.pickup,
    required this.dropoff,
    required this.distance,
    required this.eta,
    required this.duration,
    required this.price,
    required this.grossFare,
    required this.timeTag,
    required this.isParcel,
    required this.stops,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        passengerName,
        passengerPhone,
        passengerRating,
        description,
        pickup,
        dropoff,
        distance,
        eta,
        duration,
        price,
        grossFare,
        timeTag,
        isParcel,
        stops,
      ];
}
