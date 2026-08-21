import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/captain_status_entity.dart';
import '../../domain/entities/captain_trip_entity.dart';
import '../../domain/entities/captain_wallet_entity.dart';
import '../../domain/entities/captain_notification_entity.dart';
import '../../domain/entities/captain_trip_request_entity.dart';
import '../../domain/repositories/captain_repository.dart';
import '../datasources/captain_remote_data_source.dart';
import '../models/captain_wallet_model.dart';
import '../models/captain_notification_model.dart';
import '../models/captain_trip_request_model.dart';

class CaptainRepositoryImpl implements CaptainRepository {
  final CaptainRemoteDataSource remoteDataSource;

  CaptainRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CaptainStatusEntity>> toggleOnlineStatus({
    required bool isOnline,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await remoteDataSource.toggleOnlineStatus(
        isOnline: isOnline,
        lat: lat,
        lng: lng,
      );

      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(
          'تعذر تحديث الحالة. يرجى التحقق من اتصالك بالإنترنت. $e'));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateLocation({
    required String captainId,
    required double lat,
    required double lng,
    required double heading,
  }) async {
    try {
      await remoteDataSource.updateLocation(
        captainId: captainId,
        lat: lat,
        lng: lng,
        heading: heading,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('حدث خطأ أثناء تحديث الموقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> respondToTripRequest({
    required String tripId,
    required bool accept,
  }) async {
    try {
      final response = await remoteDataSource.respondToTripRequest(
        tripId: tripId,
        accept: accept,
      );

      if (response.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409 || e.response?.statusCode == 400) {
        final serverMsg = e.response?.data is Map && e.response?.data['message'] != null
            ? e.response?.data['message'].toString()
            : 'عذراً، سبقك كابتن آخر بقبول هذا المشوار.';
        return Left(ServerFailure(serverMsg ?? 'عذراً، سبقك كابتن آخر بقبول هذا المشوار.'));
      }
      return const Left(
          ServerFailure('حدث خطأ أثناء الرد على طلب المشوار.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTripStatus({
    required String tripId,
    required String status,
  }) async {
    try {
      final response = await remoteDataSource.updateTripStatus(
        tripId: tripId,
        status: status,
      );

      if (response.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message'].toString()
          : 'حدث خطأ أثناء تحديث حالة المشوار مع الخادم.';
      return Left(ServerFailure(serverMsg!));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestPayout(
      double amount, String method, String accountNumber) async {
    try {
      final response =
          await remoteDataSource.requestPayout(amount, method, accountNumber);
      if (response.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (_) {
      return const Left(ServerFailure('حدث خطأ أثناء طلب السحب'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> fetchBonusData() async {
    try {
      final response = await remoteDataSource.fetchBonusData();
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (_) {
      return const Left(ServerFailure('حدث خطأ أثناء جلب بيانات المكافآت'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CaptainTripEntity>>> getCaptainTrips({
    required int page,
    String statusFilter = 'الكل',
  }) async {
    try {
      final response =
          await remoteDataSource.getCaptainTrips(page, statusFilter);
      if (response.success && response.data != null) {
        final trips = response.data!
            .map((e) => CaptainTripEntity(
                  id: e['id']?.toString() ?? '',
                  status: e['status'] ?? 'غير معروف',
                  statusColor: _getStatusColor(e['status'] ?? ''),
                  passengerName: e['passenger_name'] ?? 'راكب',
                  passengerPhone: e['passenger_phone'] ?? '',
                  rating: (e['passenger_rating'] as num?)?.toDouble() ?? 5.0,
                  pickup: e['pickup_location'] ?? '',
                  dropoff: e['dropoff_location'] ?? '',
                  price: '${e['price'] ?? 0} ر.ي',
                  grossFare: (e['price'] as num?)?.toDouble() ?? 0.0,
                  date: e['created_at'] ?? '',
                  distance: '${e['distance_km'] ?? 0} كم',
                  duration: '${e['duration_mins'] ?? 0} دقيقة',
                  paymentMethod: e['payment_method'] ?? 'نقداً',
                ))
            .toList();
        return Right(trips);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (_) {
      return const Left(ServerFailure('فشل جلب سجل الرحلات.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
      case 'مكتملة':
        return const Color(0xFF16A34A);
      case 'cancelled':
      case 'ملغاة':
        return const Color(0xFFDC2626);
      case 'active':
      case 'قيد التنفيذ':
        return const Color(0xFFFFB020);
      default:
        return Colors.grey;
    }
  }

  @override
  Future<Either<Failure, CaptainWalletEntity>> getWalletDetails() async {
    try {
      final response = await remoteDataSource.getWalletDetails();
      if (response.success && response.data != null) {
        final wallet = CaptainWalletModel.fromJson(response.data!);
        return Right(wallet);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (_) {
      return const Left(ServerFailure(
          'تعذر جلب تفاصيل المحفظة. يرجى التحقق من اتصالك بالإنترنت.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CaptainNotificationEntity>>>
      getNotifications() async {
    try {
      final response = await remoteDataSource.getNotifications();
      if (response.success && response.data != null) {
        final notifications = response.data!
            .map((e) =>
                CaptainNotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return Right(notifications);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (_) {
      return const Left(ServerFailure(
          'تعذر جلب التنبيهات. يرجى التحقق من اتصالك بالإنترنت.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CaptainTripRequestEntity>>>
      getNearbyRequests() async {
    try {
      final response = await remoteDataSource.getNearbyRequests();
      if (response.success && response.data != null) {
        final requests = response.data!
            .map((e) =>
                CaptainTripRequestModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return Right(requests);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (_) {
      return const Left(ServerFailure(
          'تعذر جلب الطلبات القريبة. يرجى التحقق من اتصالك بالإنترنت.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadDocument(
      File file, String type) async {
    try {
      final response = await remoteDataSource.uploadDocument(file, type);
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'حدث خطأ أثناء رفع المستند'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
