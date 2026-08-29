import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/captain_status_entity.dart';
import '../entities/captain_trip_entity.dart';
import '../entities/captain_wallet_entity.dart';
import '../entities/captain_notification_entity.dart';
import '../entities/captain_trip_request_entity.dart';

abstract class CaptainRepository {
  Future<Either<Failure, CaptainStatusEntity>> toggleOnlineStatus({
    required bool isOnline,
    required double lat,
    required double lng,
  });

  Future<Either<Failure, void>> updateLocation({
    required String captainId,
    required double lat,
    required double lng,
    required double heading,
  });

  Future<Either<Failure, void>> respondToTripRequest({
    required String tripId,
    required bool accept,
    bool isParcel = false,
  });

  Future<Either<Failure, void>> updateTripStatus({
    required String tripId,
    required String status,
  });

  Future<Either<Failure, void>> requestPayout(

      double amount, String method, String accountNumber);

  // Future<Either<Failure, BonusDataEntity>> fetchBonusData(); // Assuming we had an entity
  // For now returning dynamic or Map
  Future<Either<Failure, Map<String, dynamic>>> fetchBonusData();

  Future<Either<Failure, List<CaptainTripEntity>>> getCaptainTrips({
    required int page,
    String statusFilter = 'الكل',
  });

  Future<Either<Failure, CaptainWalletEntity>> getWalletDetails();

  Future<Either<Failure, List<CaptainNotificationEntity>>> getNotifications();
  Future<Either<Failure, List<CaptainTripRequestEntity>>> getNearbyRequests();
  Future<Either<Failure, Map<String, dynamic>>> uploadDocument(
      File file, String type);
}
