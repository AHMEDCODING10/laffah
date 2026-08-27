import 'package:equatable/equatable.dart';

abstract class ParcelEvent extends Equatable {
  const ParcelEvent();

  @override
  List<Object?> get props => [];
}

class SubmitParcelEvent extends ParcelEvent {
  final String senderName;
  final String senderPhone;
  final String receiverName;
  final String receiverPhone;
  final String? pickupAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final String? dropoffAddress;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final String parcelType;
  final String size;
  final String notes;
  final double? price;

  const SubmitParcelEvent({
    required this.senderName,
    required this.senderPhone,
    required this.receiverName,
    required this.receiverPhone,
    this.pickupAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffAddress,
    this.dropoffLatitude,
    this.dropoffLongitude,
    required this.parcelType,
    required this.size,
    required this.notes,
    this.price,
  });

  @override
  List<Object?> get props => [
        senderName,
        senderPhone,
        receiverName,
        receiverPhone,
        pickupAddress,
        pickupLatitude,
        pickupLongitude,
        dropoffAddress,
        dropoffLatitude,
        dropoffLongitude,
        parcelType,
        size,
        notes,
        price,
      ];
}

class TrackParcelEvent extends ParcelEvent {
  final String identifier;

  const TrackParcelEvent({required this.identifier});

  @override
  List<Object?> get props => [identifier];
}


