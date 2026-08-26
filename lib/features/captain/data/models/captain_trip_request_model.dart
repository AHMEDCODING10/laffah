import '../../domain/entities/captain_trip_request_entity.dart';

class CaptainTripRequestModel extends CaptainTripRequestEntity {
  const CaptainTripRequestModel({
    required super.id,
    required super.title,
    required super.passengerName,
    required super.passengerPhone,
    super.receiverName = 'المستلم',
    super.receiverPhone = '',
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
    super.parcelType,
    super.size,
    super.trackingCode,
    required super.stops,
  });

  factory CaptainTripRequestModel.fromJson(Map<String, dynamic> json) {
    // Safely extract passenger details if nested or flat
    final passengerMap = json['passenger'] is Map ? json['passenger'] as Map<String, dynamic> : null;
    final String pName = json['passengerName'] as String? ??
        json['sender_name'] as String? ??
        passengerMap?['name'] as String? ??
        'عميل';
    final String pPhone = json['passengerPhone'] as String? ??
        json['sender_phone'] as String? ??
        passengerMap?['phone'] as String? ??
        '';

    final String rName = json['receiverName'] as String? ??
        json['receiver_name'] as String? ??
        'المستلم';
    final String rPhone = json['receiverPhone'] as String? ??
        json['receiver_phone'] as String? ??
        '';

    // Safely parse stops whether they are list of strings or list of maps
    final rawStops = json['stops'] as List<dynamic>?;
    final List<String> stopsList = rawStops
            ?.map((e) {
              if (e is Map) {
                return (e['address'] ?? e['name'] ?? '').toString();
              }
              return e.toString();
            })
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];

    final priceVal = json['price'] ?? json['estimated_price'] ?? json['final_price'];
    final priceStr = priceVal != null ? priceVal.toString() : '0';

    final distVal = json['distance'] ?? (json['distance_km'] != null ? "${json['distance_km']} كم" : '');
    final distStr = distVal != null ? distVal.toString() : '';

    return CaptainTripRequestModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'طلب مشوار جديد',
      passengerName: pName,
      passengerPhone: pPhone,
      receiverName: rName,
      receiverPhone: rPhone,
      passengerRating: (json['passengerRating'] as num?)?.toDouble() ?? 5.0,
      description: json['description'] as String? ??
          "${json['pickup'] ?? json['pickup_address'] ?? ''} ← ${json['dropoff'] ?? json['dropoff_address'] ?? ''}",
      pickup: json['pickup'] as String? ??
          json['pickup_address'] as String? ??
          json['pickup_location'] as String? ??
          'موقع الاستلام',
      dropoff: json['dropoff'] as String? ??
          json['dropoff_address'] as String? ??
          json['dropoff_location'] as String? ??
          'موقع الوصول',
      distance: distStr,
      eta: json['eta'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      price: priceStr,
      grossFare: (json['grossFare'] as num?)?.toDouble() ??
          (json['final_price'] as num?)?.toDouble() ??
          (json['estimated_price'] as num?)?.toDouble() ??
          (priceVal is num ? priceVal.toDouble() : double.tryParse(priceStr) ?? 0.0),
      timeTag: json['timeTag'] as String? ??
          json['time_tag'] as String? ??
          'الآن',
      isParcel: json['isParcel'] == true ||
          json['is_parcel'] == true ||
          json['type'] == 'delivery',
      parcelType: json['parcel_type'] as String? ??
          json['parcelType'] as String? ??
          json['notes'] as String?,
      size: json['size'] as String? ?? 'متوسط',
      trackingCode: json['trackingCode'] as String? ??
          json['tracking_code'] as String?,
      stops: stopsList,
    );
  }
}
