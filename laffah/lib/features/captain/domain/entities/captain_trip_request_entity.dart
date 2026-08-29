import 'package:equatable/equatable.dart';

class CaptainTripRequestEntity extends Equatable {
  final String id;
  final String title;
  final String passengerName;
  final String passengerPhone;
  final String receiverName;
  final String receiverPhone;
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
  final String? parcelType;
  final String? size;
  final String? trackingCode;
  final List<String> stops;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;

  const CaptainTripRequestEntity({
    required this.id,
    required this.title,
    required this.passengerName,
    required this.passengerPhone,
    this.receiverName = 'المستلم',
    this.receiverPhone = '',
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
    this.parcelType,
    this.size,
    this.trackingCode,
    required this.stops,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        passengerName,
        passengerPhone,
        receiverName,
        receiverPhone,
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
        parcelType,
        size,
        trackingCode,
        stops,
        pickupLat,
        pickupLng,
        dropoffLat,
        dropoffLng,
      ];
}
