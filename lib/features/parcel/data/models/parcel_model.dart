import '../../domain/entities/parcel_entity.dart';

class ParcelModel extends ParcelEntity {
  const ParcelModel({
    required super.id,
    required super.senderName,
    required super.senderPhone,
    required super.receiverName,
    required super.receiverPhone,
    required super.parcelType,
    required super.size,
    required super.notes,
    required super.status,
    required super.price,
  });

  factory ParcelModel.fromJson(Map<String, dynamic> json) {
    return ParcelModel(
      id: json['id'].toString(),
      senderName: json['sender_name'] ?? '',
      senderPhone: json['sender_phone'] ?? '',
      receiverName: json['receiver_name'] ?? '',
      receiverPhone: json['receiver_phone'] ?? '',
      parcelType: json['parcel_type'] ?? '',
      size: json['size'] ?? '',
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'pending',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_name': senderName,
      'sender_phone': senderPhone,
      'receiver_name': receiverName,
      'receiver_phone': receiverPhone,
      'parcel_type': parcelType,
      'size': size,
      'notes': notes,
      'status': status,
      'price': price,
    };
  }
}
