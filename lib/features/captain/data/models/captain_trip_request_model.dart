import '../../domain/entities/captain_trip_request_entity.dart';

class CaptainTripRequestModel extends CaptainTripRequestEntity {
  const CaptainTripRequestModel({
    required super.id,
    required super.title,
    required super.passengerName,
    required super.passengerPhone,
    required super.passengerRating,
    required super.description,
    required super.pickup,
    required super.dropoff,
    required super.distance,
    required super.eta,
    required super.duration,
    required super.price,
    required super.grossFare,
    required super.timeTag,
    required super.isParcel,
    required super.stops,
  });

  factory CaptainTripRequestModel.fromJson(Map<String, dynamic> json) {
    return CaptainTripRequestModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'طلب مشوار جديد',
      passengerName: json['passengerName'] as String? ?? 'عميل',
      passengerPhone: json['passengerPhone'] as String? ?? '',
      passengerRating: (json['passengerRating'] as num?)?.toDouble() ?? 5.0,
      description: json['description'] as String? ?? '',
      pickup: json['pickup'] as String? ?? 'موقع الاستلام',
      dropoff: json['dropoff'] as String? ?? 'موقع الوصول',
      distance: json['distance'] as String? ?? '',
      eta: json['eta'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      price: json['price'] as String? ?? '',
      grossFare: (json['grossFare'] as num?)?.toDouble() ?? 0.0,
      timeTag: json['timeTag'] as String? ?? 'الآن',
      isParcel: json['isParcel'] as bool? ?? false,
      stops: (json['stops'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
