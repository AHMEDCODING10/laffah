import 'package:equatable/equatable.dart';

class ParcelEntity extends Equatable {
  final String id;
  final String senderName;
  final String senderPhone;
  final String receiverName;
  final String receiverPhone;
  final String parcelType;
  final String size;
  final String notes;
  final String status;
  final double price;

  const ParcelEntity({
    required this.id,
    required this.senderName,
    required this.senderPhone,
    required this.receiverName,
    required this.receiverPhone,
    required this.parcelType,
    required this.size,
    required this.notes,
    required this.status,
    required this.price,
  });

  @override
  List<Object?> get props => [
        id,
        senderName,
        senderPhone,
        receiverName,
        receiverPhone,
        parcelType,
        size,
        notes,
        status,
        price,
      ];
}
