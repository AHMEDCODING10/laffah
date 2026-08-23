import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laffah/core/router/app_router.dart';
import 'package:laffah/features/captain/domain/entities/captain_trip_entity.dart';
import 'package:laffah/features/parcel/domain/entities/parcel_entity.dart';
import 'package:laffah/features/passenger/data/models/notification_item_model.dart';

void main() {
  group('Laffah Core Routes & Model Integrations', () {
    test('Verify All Core App Routes Are Defined and Unique', () {
      const routes = [
        LaffahRoutes.splash,
        LaffahRoutes.onboarding,
        LaffahRoutes.authLanding,
        LaffahRoutes.authPhone,
        LaffahRoutes.authRegisterPassenger,
        LaffahRoutes.authRegisterCaptain,
        LaffahRoutes.forgotPassword,
        LaffahRoutes.passengerHome,
        LaffahRoutes.passengerHistory,
        LaffahRoutes.passengerNotifications,
        LaffahRoutes.passengerWallet,
        LaffahRoutes.passengerRideTracking,
        LaffahRoutes.passengerParcelSend,
        LaffahRoutes.passengerParcelTracking,
        LaffahRoutes.passengerProfile,
        LaffahRoutes.captainHome,
        LaffahRoutes.captainNavigation,
        LaffahRoutes.captainHistory,
        LaffahRoutes.captainPayout,
      ];

      // Ensure no empty routes
      for (final r in routes) {
        expect(r.isNotEmpty, isTrue);
        expect(r.startsWith('/'), isTrue);
      }

      // Ensure all routes are unique
      final uniqueRoutes = routes.toSet();
      expect(uniqueRoutes.length, equals(routes.length));
    });

    test('Verify CaptainTripEntity State and Serialization', () {
      const trip = CaptainTripEntity(
        id: 'TRIP-100',
        status: 'accepted',
        statusColor: Colors.blue,
        passengerName: 'محمد أحمد',
        passengerPhone: '770000001',
        rating: 4.9,
        pickup: 'ميدان السبعين',
        dropoff: 'شارع حدة',
        price: '850 ر.ي',
        grossFare: 850.0,
        date: 'اليوم',
        distance: '2.4 كم',
        duration: '6 د',
        paymentMethod: 'نقداً',
      );

      expect(trip.id, equals('TRIP-100'));
      expect(trip.status, equals('accepted'));
      expect(trip.grossFare, equals(850.0));
      expect(trip.pickup, equals('ميدان السبعين'));
      expect(trip.toMap()['passengerName'], equals('محمد أحمد'));
    });

    test('Verify ParcelEntity Serialization & Fields', () {
      const parcel = ParcelEntity(
        id: 'PARCEL-200',
        trackingCode: 'LF-P12345',
        senderName: 'ياسر',
        senderPhone: '771111111',
        receiverName: 'خالد',
        receiverPhone: '772222222',
        pickupAddress: 'صنعاء - نقم',
        dropoffAddress: 'صنعاء - بيت بوس',
        parcelType: 'طرد صغير / هدايا',
        size: 'صغير',
        notes: 'يرجى الحذر عند النقل',
        status: 'in_transit',
        price: 1200.0,
        captainName: 'أحمد منصور',
        captainPhone: '773333333',
      );

      expect(parcel.id, equals('PARCEL-200'));
      expect(parcel.trackingCode, equals('LF-P12345'));
      expect(parcel.status, equals('in_transit'));
      expect(parcel.price, equals(1200.0));
      expect(parcel.captainName, equals('أحمد منصور'));
    });

    test('Verify NotificationItemModel Json Mapping', () {
      final json = {
        'id': 'notif-1',
        'title': 'تم قبول المشوار 🛵',
        'description': 'الكابتن وصل إلى نقطة الانطلاق',
        'timeTag': 'منذ دقيقتين',
        'isRead': false,
        'type': 'rides',
        'captainName': 'أحمد منصور',
        'tripId': 'TRIP-99',
      };

      final notif = NotificationItemModel.fromJson(json);

      expect(notif.id, equals('notif-1'));
      expect(notif.title, equals('تم قبول المشوار 🛵'));
      expect(notif.isUnread, isTrue);
      expect(notif.category, equals('rides'));
      expect(notif.captainName, equals('أحمد منصور'));
    });
  });
}
