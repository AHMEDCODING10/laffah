import '../../domain/entities/parcel_entity.dart';

class ParcelModel extends ParcelEntity {
  const ParcelModel({
    required super.id,
    super.trackingCode,
    super.captainProfileId,
    required super.senderName,
    required super.senderPhone,
    required super.receiverName,
    required super.receiverPhone,
    super.pickupAddress = '',
    super.pickupLatitude,
    super.pickupLongitude,
    super.dropoffAddress = '',
    super.dropoffLatitude,
    super.dropoffLongitude,
    required super.parcelType,
    required super.size,
    required super.notes,
    required super.status,
    required super.price,
    super.captainName,
    super.captainPhone,
  });

  factory ParcelModel.fromJson(Map<String, dynamic> json) {
    return ParcelModel(
      id: json['id'].toString(),
      trackingCode: json['tracking_code']?.toString(),
      captainProfileId: json['captain_profile_id']?.toString(),
      senderName: json['sender_name'] ?? '',
      senderPhone: json['sender_phone'] ?? '',
      receiverName: json['receiver_name'] ?? '',
      receiverPhone: json['receiver_phone'] ?? '',
      pickupAddress: (json['pickup_address'] ?? '').toString(),
      pickupLatitude: (json['pickup_latitude'] as num?)?.toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num?)?.toDouble(),
      dropoffAddress: (json['dropoff_address'] ?? '').toString(),
      dropoffLatitude: (json['dropoff_latitude'] as num?)?.toDouble(),
      dropoffLongitude: (json['dropoff_longitude'] as num?)?.toDouble(),
      parcelType: json['parcel_type'] ?? '',
      size: json['size'] ?? '',
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'pending',
      price: (json['price'] != null ? (json['price'] as num).toDouble() : 0.0),
      captainName: json['captain_name'] ??
          (json['captain'] is Map && json['captain']['user'] is Map
              ? json['captain']['user']['name']
              : null),
      captainPhone: json['captain_phone'] ??
          (json['captain'] is Map && json['captain']['user'] is Map
              ? json['captain']['user']['phone']
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tracking_code': trackingCode,
      'captain_profile_id': captainProfileId,
      'sender_name': senderName,
      'sender_phone': senderPhone,
      'receiver_name': receiverName,
      'receiver_phone': receiverPhone,
      'pickup_address': pickupAddress,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'dropoff_address': dropoffAddress,
      'dropoff_latitude': dropoffLatitude,
      'dropoff_longitude': dropoffLongitude,
      'parcel_type': parcelType,
      'size': size,
      'notes': notes,
      'status': status,
      'price': price,
      'captain_name': captainName,
      'captain_phone': captainPhone,
    };
  }
}

