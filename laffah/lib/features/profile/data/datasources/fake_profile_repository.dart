import 'package:flutter/material.dart';

/// Preset type for saved places
enum PlaceType {
  home,        // المنزل
  work,        // العمل
  university,  // الجامعة / الكلية
  shopping,    // مركز تجاري / تسوق
  historic,    // معلم تاريخي / سياحي
  custom,      // مخصص
}

/// Model class representing a Saved Destination for Laffah Passengers
class SavedPlaceModel {
  final String id;
  final String name;
  final String addressDetails;
  final double latitude;
  final double longitude;
  final PlaceType type;
  final IconData icon;

  SavedPlaceModel({
    required this.id,
    required this.name,
    required this.addressDetails,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.icon,
  });

  SavedPlaceModel copyWith({
    String? id,
    String? name,
    String? addressDetails,
    double? latitude,
    double? longitude,
    PlaceType? type,
    IconData? icon,
  }) {
    return SavedPlaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      addressDetails: addressDetails ?? this.addressDetails,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      icon: icon ?? this.icon,
    );
  }
}

/// FakeProfileRepository — Isolates mock profile data and saved places list.
/// Prepared for REST API integration with Laravel backend.
class FakeProfileRepository {
  FakeProfileRepository._();

  static Map<String, dynamic> getUserProfile() {
    return {
      'id': 'user_101',
      'name': 'سارة العامري',
      'phone': '+967 777 123 456',
      'email': 'sara.alamri@laffah.com',
      'avatarUrl': 'assets/images/user_avatar.png',
      'rating': 4.95,
      'totalRides': 48,
      'rewardPoints': 1250,
      'membershipTier': 'عضو ذهبي',
    };
  }

  static List<SavedPlaceModel> getInitialSavedPlaces() {
    return [
      SavedPlaceModel(
        id: 'place_1',
        name: 'المنزل (بيت العائلة)',
        addressDetails: 'صنعاء، حي حدة، خلف بريد حدة السكني',
        latitude: 15.3585,
        longitude: 44.1872,
        type: PlaceType.home,
        icon: Icons.home_rounded,
      ),
      SavedPlaceModel(
        id: 'place_2',
        name: 'مقر العمل الحالي',
        addressDetails: 'شارع الزبيري، برج الأمل التجاري، الطابق الرابع',
        latitude: 15.3712,
        longitude: 44.1954,
        type: PlaceType.work,
        icon: Icons.business_center_rounded,
      ),
      SavedPlaceModel(
        id: 'place_3',
        name: 'بوابة جامعة صنعاء الرئيسية',
        addressDetails: 'شارع الدائري الغربي، البوابة الغربية المقابلة للمكتبة',
        latitude: 15.3782,
        longitude: 44.1804,
        type: PlaceType.university,
        icon: Icons.school_rounded,
      ),
      SavedPlaceModel(
        id: 'place_4',
        name: 'مركز الكميم التجاري',
        addressDetails: 'شارع حدة العام، بجانب كافيه رويال',
        latitude: 15.3605,
        longitude: 44.1852,
        type: PlaceType.shopping,
        icon: Icons.local_mall_rounded,
      ),
      SavedPlaceModel(
        id: 'place_5',
        name: 'مزار باب اليمن التاريخي',
        addressDetails: 'صنعاء القديمة، أمام ساحة باب اليمن الرئيسية',
        latitude: 15.3524,
        longitude: 44.2140,
        type: PlaceType.historic,
        icon: Icons.castle_rounded,
      ),
    ];
  }
}
