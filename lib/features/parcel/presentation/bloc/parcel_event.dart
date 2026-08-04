import 'package:equatable/equatable.dart';

abstract class ParcelEvent extends Equatable {
  const ParcelEvent();

  @override
  List<Object> get props => [];
}

class SubmitParcelEvent extends ParcelEvent {
  final String senderName;
  final String senderPhone;
  final String receiverName;
  final String receiverPhone;
  final String parcelType;
  final String size;
  final String notes;

  const SubmitParcelEvent({
    required this.senderName,
    required this.senderPhone,
    required this.receiverName,
    required this.receiverPhone,
    required this.parcelType,
    required this.size,
    required this.notes,
  });

  @override
  List<Object> get props => [
        senderName,
        senderPhone,
        receiverName,
        receiverPhone,
        parcelType,
        size,
        notes,
      ];
}
