import 'package:equatable/equatable.dart';

class ParcelEntity extends Equatable {
  final String id;
  final String? trackingCode;
  final String? captainProfileId;
  final String senderName;
  final String senderPhone;
  final String receiverName;
  final String receiverPhone;
  final String pickupAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final String dropoffAddress;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final String parcelType;
  final String size;
  final String notes;
  final String status;
  final double price;
  final String? captainName;
  final String? captainPhone;

  const ParcelEntity({
    required this.id,
    this.trackingCode,
    this.captainProfileId,
    required this.senderName,
    required this.senderPhone,
    required this.receiverName,
    required this.receiverPhone,
    this.pickupAddress = '',
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffAddress = '',
    this.dropoffLatitude,
    this.dropoffLongitude,
    required this.parcelType,
    required this.size,
    required this.notes,
    required this.status,
    required this.price,
    this.captainName,
    this.captainPhone,
  });

  @override
  List<Object?> get props => [
        id,
        trackingCode,
        captainProfileId,
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
        status,
        price,
        captainName,
        captainPhone,
      ];
}

