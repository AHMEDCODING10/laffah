import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CaptainTripEntity extends Equatable {
  final String id;
  final String status;
  final Color statusColor;
  final String passengerName;
  final String passengerPhone;
  final double rating;
  final String pickup;
  final String dropoff;
  final String price;
  final double grossFare;
  final String date;
  final String distance;
  final String duration;
  final String paymentMethod;
  final bool isParcel;

  const CaptainTripEntity({
    required this.id,
    required this.status,
    required this.statusColor,
    required this.passengerName,
    required this.passengerPhone,
    required this.rating,
    required this.pickup,
    required this.dropoff,
    required this.price,
    required this.grossFare,
    required this.date,
    required this.distance,
    required this.duration,
    required this.paymentMethod,
    this.isParcel = false,
  });

  @override
  List<Object?> get props => [
        id,
        status,
        statusColor,
        passengerName,
        passengerPhone,
        rating,
        pickup,
        dropoff,
        price,
        grossFare,
        date,
        distance,
        duration,
        paymentMethod,
        isParcel,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
      'statusColor': statusColor,
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'rating': rating,
      'pickup': pickup,
      'dropoff': dropoff,
      'price': price,
      'grossFare': grossFare,
      'date': date,
      'distance': distance,
      'duration': duration,
      'paymentMethod': paymentMethod,
      'isParcel': isParcel,
    };
  }
}
